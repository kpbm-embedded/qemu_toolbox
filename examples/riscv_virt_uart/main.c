/* RISC-V QEMU virt, M-mode without OpenSBI: NS16550A UART at 0x10000000. */
#include <stdint.h>
#include "mini.h"

#define UART0 0x10000000u
#define THR (*(volatile uint8_t *)(UART0 + 0))
#define LSR (*(volatile uint8_t *)(UART0 + 5))
#define LSR_THRE 0x20

static void putc_(char c) { while (!(LSR & LSR_THRE)) { } THR = (uint8_t)c; }
static void puts_(const char *s) { while (*s) putc_(*s++); }

static uintptr_t read_misa(void) { uintptr_t v; __asm__ volatile("csrr %0, misa" : "=r"(v)); return v; }

int main(void)
{
    char buf[12];
    uintptr_t misa = read_misa();
    puts_("hello from RISC-V virt NS16550 (");
    puts_(__riscv_xlen == 64 ? "rv64" : "rv32");
    puts_(")\nmisa extensions: ");
    for (int i = 0; i < 26; i++) if (misa & ((uintptr_t)1 << i)) putc_((char)('A' + i));
    puts_("\nmhartid 0, sum 1..100 = ");
    uint32_t s = 0; for (uint32_t i = 1; i <= 100; i++) s += i;
    puts_(u32_to_dec(s, buf));
    puts_("\n");
    return s == 5050 ? 0 : 1;
}
