/* Cortex-M4 (mps2-an386): an undefined instruction escalates to HardFault (UsageFault is not
 * enabled). The handler finds the stacked exception frame, prints the faulting PC, CFSR and HFSR,
 * and ends the run with exit status 1 - the pattern for a crash report on real boards. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

#define SCB_CFSR (*(volatile uint32_t *)0xE000ED28u)
#define SCB_HFSR (*(volatile uint32_t *)0xE000ED2Cu)

__attribute__((noinline, used)) void fault_here(void) { __asm__ volatile("udf #0"); }

__attribute__((used)) void hardfault_report(uint32_t *frame)   /* frame: r0 r1 r2 r3 r12 lr pc xpsr */
{
    char buf[12];
    sh_write0("HardFault\n  pc   = "); sh_write0(u32_to_hex(frame[6], buf));
    sh_write0("\n  lr   = "); sh_write0(u32_to_hex(frame[5], buf));
    sh_write0("\n  CFSR = "); sh_write0(u32_to_hex(SCB_CFSR, buf));
    sh_write0("\n  HFSR = "); sh_write0(u32_to_hex(SCB_HFSR, buf));
    sh_write0((SCB_CFSR & (1u << 16)) ? "\n  cause: UNDEFINSTR\n" : "\n  cause: other\n");
    sh_exit(3);
}

__attribute__((naked)) void HardFault_Handler(void)
{
    __asm__ volatile("tst lr, #4\n ite eq\n mrseq r0, msp\n mrsne r0, psp\n b hardfault_report");
}

int main(void)
{
    sh_write0("about to fault\n");
    fault_here();
    sh_write0("not reached\n");
    return 0;
}
