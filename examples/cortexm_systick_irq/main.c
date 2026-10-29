/* Cortex-M4 (mps2-an386, 25 MHz): SysTick every 1 ms counts ticks while the core sleeps in WFI,
 * then an external interrupt is raised from software through the NVIC (ISPR) and its number is
 * read from IPSR. Handlers override the weak ones in common/cortexm_start.c. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

#define SYST_CSR  (*(volatile uint32_t *)0xE000E010u)
#define SYST_RVR  (*(volatile uint32_t *)0xE000E014u)
#define SYST_CVR  (*(volatile uint32_t *)0xE000E018u)
#define NVIC_ISER0 (*(volatile uint32_t *)0xE000E100u)
#define NVIC_ISPR0 (*(volatile uint32_t *)0xE000E200u)
#define CPU_HZ 25000000u
#define TEST_IRQ 7

static volatile uint32_t ticks, irq_seen = 0xffffffffu;

void SysTick_Handler(void) { ticks++; }
void IRQ_Handler(void)
{
    uint32_t ipsr; __asm__ volatile("mrs %0, ipsr" : "=r"(ipsr));
    irq_seen = ipsr - 16;          /* exception number 16 + n = IRQ n */
}

int main(void)
{
    char buf[12];
    SYST_RVR = CPU_HZ / 1000u - 1u;  /* 1 ms */
    SYST_CVR = 0;
    SYST_CSR = 7;                    /* processor clock, TICKINT, ENABLE */
    while (ticks < 10) __asm__ volatile("wfi");
    SYST_CSR = 0;
    sh_write0("systick: "); sh_write0(u32_to_dec(ticks, buf)); sh_write0(" ticks of 1 ms\n");

    NVIC_ISER0 = 1u << TEST_IRQ;
    NVIC_ISPR0 = 1u << TEST_IRQ;     /* pend it from software: taken at once */
    __asm__ volatile("dsb; isb");
    sh_write0("nvic: IRQ "); sh_write0(u32_to_dec(irq_seen, buf)); sh_write0(" handled\n");
    return (ticks == 10 && irq_seen == TEST_IRQ) ? 0 : 1;
}
