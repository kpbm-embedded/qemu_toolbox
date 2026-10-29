/* STM32F405 (QEMU netduinoplus2) USART1 polling output. The STM32F4 USART register layout
 * (SR/DR/BRR/CR1) is the same on the user's BlackPill STM32F411, so this driver ports as is
 * (on hardware: also enable the GPIOA/USART1 clocks in RCC and set PA9/PA10 to AF7). */
#include <stdint.h>
#include "mini.h"

#define USART1_BASE 0x40011000u
#define USART_SR   (*(volatile uint32_t *)(USART1_BASE + 0x00))
#define USART_DR   (*(volatile uint32_t *)(USART1_BASE + 0x04))
#define USART_BRR  (*(volatile uint32_t *)(USART1_BASE + 0x08))
#define USART_CR1  (*(volatile uint32_t *)(USART1_BASE + 0x0C))
#define SR_TXE  (1u << 7)
#define CR1_UE  (1u << 13)
#define CR1_TE  (1u << 3)
#define CR1_RE  (1u << 2)

static void uart_init(void) { USART_BRR = 0x8B; /* 115200 @ 16 MHz HSI */ USART_CR1 = CR1_UE | CR1_TE | CR1_RE; }
static void uart_putc(char c) { while (!(USART_SR & SR_TXE)) { } USART_DR = (uint32_t)c; }
static void uart_puts(const char *s) { while (*s) { if (*s == '\n') uart_putc('\r'); uart_putc(*s++); } }

int main(void)
{
    char buf[12];
    uart_init();
    uart_puts("hello from STM32F405 USART1 (netduinoplus2)\n");
    uint32_t idcode = *(volatile uint32_t *)0xE0042000u;   /* DBGMCU_IDCODE (0 in QEMU) */
    uart_puts("DBGMCU_IDCODE = ");
    uart_puts(u32_to_hex(idcode, buf));
    uart_puts("\n");
    for (uint32_t i = 1; i <= 3; i++) { uart_puts("tick "); uart_puts(u32_to_dec(i, buf)); uart_puts("\n"); }
    uart_puts("done\n");
    return 0;   /* the startup code ends the run through semihosting SYS_EXIT */
}
