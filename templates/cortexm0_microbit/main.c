/* nRF51822 (QEMU microbit, Cortex-M0) UART0 polling output. nRF UARTs are task/event based:
 * write TASKS_STARTTX, put a byte in TXD, wait for EVENTS_TXDRDY. The nRF52840 (nice!nano,
 * Pro Micro nRF52840) keeps the same legacy UART block at 0x40002000 with the same offsets. */
#include <stdint.h>
#include "mini.h"

#define UART0 0x40002000u
#define REG(o) (*(volatile uint32_t *)(UART0 + (o)))
#define TASKS_STARTTX  REG(0x008)
#define EVENTS_TXDRDY  REG(0x11C)
#define ENABLE         REG(0x500)
#define PSELTXD        REG(0x50C)
#define TXD            REG(0x51C)
#define BAUDRATE       REG(0x524)
#define FICR_CODESIZE  (*(volatile uint32_t *)0x10000014u)   /* flash pages */
#define FICR_CODEPAGESIZE (*(volatile uint32_t *)0x10000010u)

static void uart_init(void) { PSELTXD = 24; BAUDRATE = 0x01D7E000u; /* 115200 */ ENABLE = 4; TASKS_STARTTX = 1; }
static void uart_putc(char c) { EVENTS_TXDRDY = 0; TXD = (uint8_t)c; while (!EVENTS_TXDRDY) { } }
static void uart_puts(const char *s) { while (*s) { if (*s == '\n') uart_putc('\r'); uart_putc(*s++); } }

int main(void)
{
    char buf[12];
    uart_init();
    uart_puts("@NAME@: hello from nRF51822 UART0 (Cortex-M0)\n");
    uart_puts("flash = ");
    uart_puts(u32_to_dec(FICR_CODESIZE * FICR_CODEPAGESIZE / 1024, buf));
    uart_puts(" KB\n");
    uint32_t x = 1; for (int i = 0; i < 10; i++) x *= 3;   /* M0 has a 32-bit multiplier only */
    uart_puts("3^10 = "); uart_puts(u32_to_dec(x, buf)); uart_puts("\n");
    uart_puts(x == 59049 ? "@NAME@: PASS\n" : "@NAME@: FAIL\n");
    return x == 59049 ? 0 : 1;
}
