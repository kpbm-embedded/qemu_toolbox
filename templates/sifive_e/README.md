    # @NAME@

    rv32imac firmware for QEMU `sifive_e` (FE310, HiFive1): code in XIP flash at 0x20400000, `.data` copied
to the 16 KB DTIM, SiFive UART0.

    From `qemu-box new sifive_e @NAME@` (32_10_qemu). Freestanding C (no libc), clang + ld.lld; every file it
    needs is in this folder.

        qemu-box shell -- make test      # build, run headless on `sifive_e`, check the output
        qemu-box shell -- make run       # just run
        qemu-box run-elf sifive_e build/@NAME@.elf --gdb=1234   # halted, gdbstub on :1234

Closest QEMU machine to small RISC-V MCUs with flash + SRAM (CH32V, GD32VF103 class) at ISA level.
