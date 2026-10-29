# @NAME@

Bare-metal firmware project from `qemu-box new riscv_virt @NAME@` (32_10_qemu). Freestanding C
(no libc), clang + ld.lld, startup code and semihosting exit included; no file outside this
folder is needed.

    qemu-box shell -- make run        # build + run headless
    qemu-box run-elf virt build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

Change `link.ld` (memory map), `TARGET` in the Makefile (CPU) and the machine name to retarget.
