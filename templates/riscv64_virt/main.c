/* @NAME@: RISC-V rv64 on QEMU virt (M-mode, -bios none). a0 = hart id, a1 = device tree. */
#include <stdint.h>
#include "mini.h"

#define THR (*(volatile uint8_t *)0x10000000u)
#define LSR (*(volatile uint8_t *)0x10000005u)
static void puts_(const char *s) { while (*s) { while (!(LSR & 0x20)) { } THR = (uint8_t)*s++; } }

int main(uint64_t hartid, const uint8_t *fdt)
{
    char buf[12];
    uint32_t magic = (uint32_t)fdt[0] << 24 | (uint32_t)fdt[1] << 16 | (uint32_t)fdt[2] << 8 | fdt[3];
    puts_("@NAME@: hello from RISC-V rv64 virt, hart "); puts_(u32_to_dec((uint32_t)hartid, buf));
    puts_("\ndevice tree magic "); puts_(u32_to_hex(magic, buf)); puts_("\n");
    uint64_t f = 1; for (int i = 2; i <= 20; i++) f *= (uint64_t)i;   /* 20! needs 64 bits */
    int ok = magic == 0xd00dfeedu && f == 2432902008176640000ull;
    puts_(ok ? "@NAME@: PASS\n" : "@NAME@: FAIL\n");
    return ok ? 0 : 1;
}
