/* RISC-V virt rv64: QEMU passes the device tree blob in a1 (-bios none). The firmware walks the
 * flattened tree (big-endian tokens), finds /memory and the first serial node, prints their reg
 * values, then prints through the UART at the address it found. This is how one image can serve
 * several boards (Linux, U-Boot and Zephyr on RISC-V all start from this a0/a1 convention). */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

#define FDT_MAGIC 0xd00dfeedu
#define FDT_BEGIN_NODE 1u
#define FDT_END_NODE   2u
#define FDT_PROP       3u
#define FDT_NOP        4u
#define FDT_END        9u

static uint32_t be32(const void *p) { const uint8_t *b = p; return (uint32_t)b[0] << 24 | (uint32_t)b[1] << 16 | (uint32_t)b[2] << 8 | b[3]; }
static uint64_t be64(const void *p) { return (uint64_t)be32(p) << 32 | be32((const uint8_t *)p + 4); }
static int starts(const char *s, const char *p) { while (*p) if (*s++ != *p++) return 0; return 1; }
static int streq(const char *a, const char *b) { while (*a && *a == *b) { a++; b++; } return *a == *b; }

static void put_hex64(uint64_t v) { char b[12]; sh_write0(u32_to_hex((uint32_t)(v >> 32), b)); sh_write0(u32_to_hex((uint32_t)v, b) + 2); }

int main(uint64_t hartid, const uint8_t *fdt)
{
    char buf[12];
    (void)hartid;
    if (be32(fdt) != FDT_MAGIC) { sh_write0("no device tree in a1\n"); return 1; }
    const uint8_t *st = fdt + be32(fdt + 8);          /* off_dt_struct */
    const char *strs = (const char *)fdt + be32(fdt + 12);
    uint64_t mem_base = 0, mem_size = 0, uart = 0;
    uint32_t nodes = 0, depth = 0, in_mem = 0, in_uart = 0;
    for (const uint8_t *p = st;;) {
        uint32_t tok = be32(p); p += 4;
        if (tok == FDT_BEGIN_NODE) {
            const char *name = (const char *)p; uint32_t n = 0; while (name[n]) n++;
            p += (n + 4) & ~3u;
            nodes++; depth++;
            in_mem = starts(name, "memory@");
            in_uart = (!uart && starts(name, "serial@"));
        } else if (tok == FDT_PROP) {
            uint32_t len = be32(p), nameoff = be32(p + 4); const uint8_t *val = p + 8;
            p += 8 + ((len + 3) & ~3u);
            if (streq(strs + nameoff, "reg") && len >= 16) {   /* #address-cells = #size-cells = 2 on virt */
                if (in_mem) { mem_base = be64(val); mem_size = be64(val + 8); }
                if (in_uart) uart = be64(val);
            }
        } else if (tok == FDT_END_NODE) { depth--; in_mem = in_uart = 0; }
        else if (tok == FDT_NOP) { }
        else break;                                        /* FDT_END */
    }
    sh_write0("fdt: "); sh_write0(u32_to_dec(be32(fdt + 4), buf)); sh_write0(" bytes, ");
    sh_write0(u32_to_dec(nodes, buf)); sh_write0(" nodes\n");
    sh_write0("memory base "); put_hex64(mem_base); sh_write0(" size "); put_hex64(mem_size); sh_write0("\n");
    sh_write0("serial at "); put_hex64(uart); sh_write0("\n");
    if (!uart) return 1;
    const char *msg = "hello through the UART found in the device tree\n";
    while (*msg) { while (!(*(volatile uint8_t *)(uintptr_t)(uart + 5) & 0x20)) { } *(volatile uint8_t *)(uintptr_t)uart = (uint8_t)*msg++; }
    return depth == 0 ? 0 : 1;
}
