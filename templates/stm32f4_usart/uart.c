#include "uart.h"
#define R(b, o) (*(volatile uint32_t *)((b) + (o)))
#define SR 0x00
#define DR 0x04
#define BRR 0x08
#define CR1 0x0C
void uart_init(uint32_t base, uint32_t pclk_hz, uint32_t baud)
{
    R(base, BRR) = (pclk_hz + baud / 2) / baud;      /* oversampling by 16: BRR = fck / baud */
    R(base, CR1) = (1u << 13) | (1u << 3) | (1u << 2); /* UE, TE, RE */
}
void uart_putc(uint32_t base, char c) { while (!(R(base, SR) & (1u << 7))) { } R(base, DR) = (uint32_t)c; }
void uart_puts(uint32_t base, const char *s) { while (*s) { if (*s == '\n') uart_putc(base, '\r'); uart_putc(base, *s++); } }
