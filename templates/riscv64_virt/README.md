    # @NAME@

    RISC-V rv64imac bare metal for QEMU `virt` in M-mode (no OpenSBI): NS16550 UART, the hart id and
device tree pointer QEMU passes in a0/a1. Matches the K210/K230 core class at ISA level.

    From `qemu-box new riscv64_virt @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `virt`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf virt build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

