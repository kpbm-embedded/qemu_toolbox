    # @NAME@

    AArch64 bare metal (EL1) for QEMU `virt -cpu cortex-a53`: PL011 UART, system registers, generic timer.
A starting point for boot code on Cortex-A boards before U-Boot/Linux (Yocto SoCs).

    From `qemu-box new aarch64_virt @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `virt -cpu cortex-a53`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf virt build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

Built with `-mgeneral-regs-only` (FP/SIMD is off at reset until CPACR_EL1 enables it).
