/* AArch64 bare metal on QEMU virt (-cpu cortex-a53, the core of many Yocto boards such as the
 * Allwinner H5/H6/A64 and RK3328): PL011 UART at 0x09000000, system registers CurrentEL and
 * MIDR_EL1, generic timer frequency; semihosting ends the run with main's return value. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

#define PL011 0x09000000u
#define UARTDR (*(volatile uint32_t *)(PL011 + 0x00))
#define UARTFR (*(volatile uint32_t *)(PL011 + 0x18))
#define FR_TXFF (1u << 5)

static void putc_(char c) { while (UARTFR & FR_TXFF) { } UARTDR = (uint32_t)c; }
static void puts_(const char *s) { while (*s) putc_(*s++); }
#define SYSREG(r) ({ uint64_t v_; __asm__ volatile("mrs %0, " #r : "=r"(v_)); v_; })

int main(void)
{
    char buf[12];
    uint64_t el = (SYSREG(CurrentEL) >> 2) & 3, midr = SYSREG(MIDR_EL1), cntfrq = SYSREG(CNTFRQ_EL0);
    puts_("hello from AArch64 (virt, PL011)\n");
    puts_("CurrentEL = EL"); puts_(u32_to_dec((uint32_t)el, buf));
    puts_("\nMIDR_EL1 = "); puts_(u32_to_hex((uint32_t)midr, buf));
    puts_(((midr >> 4) & 0xfff) == 0xD03 ? " (Cortex-A53)\n" : " (other core)\n");
    puts_("CNTFRQ_EL0 = "); puts_(u32_to_dec((uint32_t)cntfrq, buf)); puts_(" Hz\n");
    uint64_t t0 = SYSREG(CNTVCT_EL0), x = 0;
    for (uint64_t i = 1; i <= 1000000; i++) x += i * i;
    uint64_t dt = SYSREG(CNTVCT_EL0) - t0;
    puts_("sum of squares 1..1e6 = 0x"); puts_(u32_to_hex((uint32_t)(x >> 32), buf) + 2); puts_(u32_to_hex((uint32_t)x, buf) + 2);
    puts_(", "); puts_(u32_to_dec((uint32_t)dt, buf)); puts_(" timer ticks\n");
    return (x == 333333833333500000ull && ((midr >> 4) & 0xfff) == 0xD03) ? 0 : 1;
}
