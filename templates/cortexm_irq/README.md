    # @NAME@

    Cortex-M interrupts on QEMU `mps2-an386`: SysTick at 1 ms, WFI, an NVIC interrupt pended from
software. `startup.c` declares every handler weak; define `SysTick_Handler`, `HardFault_Handler`,
`IRQ_Handler` (all external IRQs, number from IPSR) ... to override.

    From `qemu-box new cortexm_irq @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `mps2-an386`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf mps2-an386 build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

