/* QEMU riscv virt with -bios none: DRAM at 0x80000000; -kernel loads the ELF there (code and data in RAM) */
MEMORY { ROM (rwx) : ORIGIN = 0x80000000, LENGTH = 1M
         RAM (rwx) : ORIGIN = 0x80100000, LENGTH = 1M }
/* common RISC-V sections; the machine script defines ROM (code) and RAM */
ENTRY(_start)
SECTIONS
{
    .text : { KEEP(*(.text.start)) *(.text*) } > ROM
    .rodata : { *(.rodata*) *(.srodata*) . = ALIGN(8); } > ROM
    _sidata = LOADADDR(.data);
    .data : { _sdata = .; *(.data*) __global_pointer$ = . + 0x800; *(.sdata*) . = ALIGN(8); _edata = .; } > RAM AT > ROM
    .bss (NOLOAD) : { _sbss = .; *(.sbss*) *(.bss*) *(COMMON) . = ALIGN(8); _ebss = .; } > RAM
    _estack = ORIGIN(RAM) + LENGTH(RAM);
    /DISCARD/ : { *(.comment) *(.riscv.attributes) }
}
