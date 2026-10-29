    # @NAME@

    RISC-V machine-mode interrupts on QEMU `virt`: CLINT `mtimecmp`, `mtvec` pointing at a C handler
(`interrupt("machine")`), MTIE/MIE, WFI. Change PERIOD or add `mcause` cases for other interrupts.

    From `qemu-box new riscv_irq @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `virt`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf virt build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

