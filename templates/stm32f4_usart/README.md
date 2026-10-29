    # @NAME@

    STM32F405 firmware for QEMU `netduinoplus2` with a reusable USART driver (`uart.c`/`uart.h`, BRR from
the bus clock). The register layout is the BlackPill F411's.

    From `qemu-box new stm32f4_usart @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `netduinoplus2`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf netduinoplus2 build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

QEMU does not model RCC or GPIO in depth: clock and pin setup are left out here and needed on hardware.
