    # @NAME@

    Cortex-M3 firmware for QEMU `stm32vldiscovery` (STM32F100RB, the STM32F1/BluePill class): USART1
polling driver, SCB CPUID check.

    From `qemu-box new cortexm3_stm32 @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `stm32vldiscovery`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf stm32vldiscovery build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

On hardware also enable the GPIOA/USART1 clocks in RCC and set PA9 to alternate function.
