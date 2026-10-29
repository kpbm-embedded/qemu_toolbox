/* SiFive FE310 (HiFive1) on QEMU sifive_e: code in XIP flash, data in DTIM, UART0 at 0x10013000. */
#include <stdint.h>
#include "mini.h"

#define UART0 0x10013000u
#define TXDATA (*(volatile uint32_t *)(UART0 + 0x00))
#define TXCTRL (*(volatile uint32_t *)(UART0 + 0x08))
#define TX_FULL (1u << 31)

static void putc_(char c) { while (TXDATA & TX_FULL) { } TXDATA = (uint8_t)c; }
static void puts_(const char *s) { while (*s) putc_(*s++); }

static uint32_t counter = 41;   /* in .data: checks the flash -> DTIM copy */

int main(void)
{
    char buf[12];
    TXCTRL = 1;   /* txen */
    puts_("hello from SiFive FE310 (sifive_e) UART0\n");
    counter++;
    puts_("counter = ");
    puts_(u32_to_dec(counter, buf));
    puts_("\n");
    return counter == 42 ? 0 : 1;
}
