/* STM32F4 USART polling driver (same registers on F401/F405/F411: BlackPill). */
#ifndef UART_H
#define UART_H
#include <stdint.h>
void uart_init(uint32_t base, uint32_t pclk_hz, uint32_t baud);
void uart_putc(uint32_t base, char c);
void uart_puts(uint32_t base, const char *s);
#define USART1 0x40011000u
#define USART2 0x40004400u
#endif
