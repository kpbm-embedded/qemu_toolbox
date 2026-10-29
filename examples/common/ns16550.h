/* NS16550A UART of QEMU's riscv virt machine (0x10000000; QEMU needs no baud setup). Header-only. */
#ifndef NS16550_H
#define NS16550_H
#include <stdint.h>
#ifndef NS16550_BASE
#define NS16550_BASE 0x10000000u
#endif
static inline void uart_putc_at(uintptr_t base, char c)
{
    while (!(*(volatile uint8_t *)(base + 5) & 0x20)) { }   /* LSR.THRE */
    *(volatile uint8_t *)base = (uint8_t)c;
}
static inline void uart_puts_at(uintptr_t base, const char *s) { while (*s) uart_putc_at(base, *s++); }
static inline void uart_puts(const char *s) { uart_puts_at(NS16550_BASE, s); }
#endif
