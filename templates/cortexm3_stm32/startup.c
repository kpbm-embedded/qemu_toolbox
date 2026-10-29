/* Cortex-M startup: vector table, .data copy, .bss zero, main(), semihosting exit.
 * Every handler is weak: an example overrides one by defining a function of the same name. */
#include <stdint.h>
#include "semihost.h"

extern uint32_t _sidata, _sdata, _edata, _sbss, _ebss, _estack;
int main(void);

void Reset_Handler(void)
{
    uint32_t *s = &_sidata, *d = &_sdata;
    while (d < &_edata) *d++ = *s++;
    for (d = &_sbss; d < &_ebss;) *d++ = 0;
    sh_exit(main());
}

void Default_Handler(void)
{
    sh_write0("unexpected exception\n");
    sh_exit(99);
}

#define WEAK __attribute__((weak, alias("Default_Handler")))
void NMI_Handler(void) WEAK;
void HardFault_Handler(void) WEAK;
void MemManage_Handler(void) WEAK;
void BusFault_Handler(void) WEAK;
void UsageFault_Handler(void) WEAK;
void SVC_Handler(void) WEAK;
void DebugMon_Handler(void) WEAK;
void PendSV_Handler(void) WEAK;
void SysTick_Handler(void) WEAK;
void IRQ_Handler(void) WEAK;          /* every external interrupt (read IPSR for the number) */

__attribute__((section(".isr_vector"), used))
const void *const vectors[16 + 32] = {
    &_estack, Reset_Handler, NMI_Handler, HardFault_Handler,
    MemManage_Handler, BusFault_Handler, UsageFault_Handler,
    0, 0, 0, 0,
    SVC_Handler, DebugMon_Handler, 0, PendSV_Handler, SysTick_Handler,
    [16 ... 47] = IRQ_Handler,
};
