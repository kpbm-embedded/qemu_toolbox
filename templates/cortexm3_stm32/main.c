/* STM32F100 (QEMU stm32vldiscovery, Cortex-M3) USART1 polling output. Same SR/DR/BRR/CR1 layout
 * as STM32F1 (BluePill F103) and the STM32F4 parts; USART1 sits at 0x40013800 on F1. */
#include <stdint.h>
#include "mini.h"

#define USART1_BASE 0x40013800u
#define USART_SR   (*(volatile uint32_t *)(USART1_BASE + 0x00))
#define USART_DR   (*(volatile uint32_t *)(USART1_BASE + 0x04))
#define USART_BRR  (*(volatile uint32_t *)(USART1_BASE + 0x08))
#define USART_CR1  (*(volatile uint32_t *)(USART1_BASE + 0x0C))
#define SR_TXE  (1u << 7)
#define CR1_UE  (1u << 13)
#define CR1_TE  (1u << 3)
#define SCB_CPUID (*(volatile uint32_t *)0xE000ED00u)

static void uart_init(void) { USART_BRR = 0xD0; /* 115200 @ 24 MHz */ USART_CR1 = CR1_UE | CR1_TE; }
static void uart_putc(char c) { while (!(USART_SR & SR_TXE)) { } USART_DR = (uint32_t)c; }
static void uart_puts(const char *s) { while (*s) { if (*s == '\n') uart_putc('\r'); uart_putc(*s++); } }

int main(void)
{
    char buf[12];
    uart_init();
    uart_puts("@NAME@: hello from STM32F100 USART1 (Cortex-M3)\n");
    uint32_t cpuid = SCB_CPUID;
    uart_puts("CPUID = "); uart_puts(u32_to_hex(cpuid, buf));
    uart_puts(((cpuid >> 4) & 0xfff) == 0xC23 ? " (Cortex-M3)\n" : " (unexpected)\n");
    uint32_t q = 1000000u / 7u;   /* M3 has a hardware divider (M0 does not) */
    uart_puts("1000000/7 = "); uart_puts(u32_to_dec(q, buf)); uart_puts("\n");
    int ok = ((cpuid >> 4) & 0xfff) == 0xC23 && q == 142857;
    uart_puts(ok ? "@NAME@: PASS\n" : "@NAME@: FAIL\n");
    return ok ? 0 : 1;
}
