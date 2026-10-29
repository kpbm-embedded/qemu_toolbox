/* QEMU sifive_e (FE310, HiFive1): the mask ROM jumps to XIP flash at 0x20400000; 16 KB DTIM at 0x80000000 */
MEMORY { ROM (rx)  : ORIGIN = 0x20400000, LENGTH = 4M
         RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 16K }
INCLUDE riscv.ld.inc
