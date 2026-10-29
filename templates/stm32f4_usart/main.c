/* @NAME@: STM32F405 (QEMU netduinoplus2) - the same USART code runs on a BlackPill F411.
 * On hardware add: RCC clock enables for GPIOA + USART1, PA9/PA10 alternate function 7. */
#include <stdint.h>
#include "uart.h"
#include "mini.h"

int main(void)
{
    char buf[12];
    uart_init(USART1, 16000000u, 115200u);   /* HSI 16 MHz after reset */
    uart_puts(USART1, "@NAME@: hello from STM32F4 USART1\n");
    uint32_t brr = *(volatile uint32_t *)(USART1 + 0x08);
    uart_puts(USART1, "BRR = "); uart_puts(USART1, u32_to_hex(brr, buf)); uart_puts(USART1, "\n");
    uart_puts(USART1, brr == 139 ? "@NAME@: PASS\n" : "@NAME@: FAIL\n");
    return brr == 139 ? 0 : 1;
}
