/* Cortex-M startup: vector table, .data copy, .bss zero, main(), semihosting exit. */
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

__attribute__((section(".isr_vector"), used))
const void *const vectors[16] = {
    &_estack, Reset_Handler,
    Default_Handler, Default_Handler, Default_Handler, Default_Handler, Default_Handler, /* NMI..UsageFault */
    0, 0, 0, 0,
    Default_Handler, Default_Handler, 0, Default_Handler, Default_Handler,            /* SVC, DebugMon, PendSV, SysTick */
};
