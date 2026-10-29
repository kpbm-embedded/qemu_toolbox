/* @NAME@: RISC-V rv32 on QEMU virt (M-mode, -bios none), NS16550 UART at 0x10000000. */
#include <stdint.h>
#include "mini.h"

#define THR (*(volatile uint8_t *)0x10000000u)
#define LSR (*(volatile uint8_t *)0x10000005u)

static void puts_(const char *s) { while (*s) { while (!(LSR & 0x20)) { } THR = (uint8_t)*s++; } }

int main(void)
{
    char buf[12];
    puts_("@NAME@: hello from RISC-V virt\n");
    puts_("answer = ");
    puts_(u32_to_dec(42, buf));
    puts_("\n");
    return 0;   /* startup.S exits through semihosting with this status */
}
