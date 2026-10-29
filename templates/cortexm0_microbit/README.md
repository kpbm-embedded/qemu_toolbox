    # @NAME@

    Cortex-M0 firmware for QEMU `microbit` (nRF51822): UART0 task/event driver, FICR read, software
divide helpers for M0 (`mini.c`).

    From `qemu-box new cortexm0_microbit @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `microbit`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf microbit build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

The nRF52840 boards (nice!nano, Pro Micro nRF52840) keep the same legacy UART block at 0x40002000; QEMU has
no nRF52 machine (use Renode, 32_06_renode, for those).
