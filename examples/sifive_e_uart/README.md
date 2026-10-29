# sifive_e_uart

QEMU's `sifive_e` models the FE310-G000/G002 (HiFive1). The mask ROM jumps to XIP flash at
0x20400000, so code links there and `.data` is copied into the 16 KB DTIM at 0x80000000 by the
startup code (the same flash/RAM split real RISC-V MCUs such as CH32V and BL616 use).
