/* QEMU riscv virt with -bios none: DRAM at 0x80000000; -kernel loads the ELF there (code and data in RAM) */
MEMORY { ROM (rwx) : ORIGIN = 0x80000000, LENGTH = 1M
         RAM (rwx) : ORIGIN = 0x80100000, LENGTH = 1M }
INCLUDE riscv.ld.inc
