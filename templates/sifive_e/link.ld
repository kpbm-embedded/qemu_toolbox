/* QEMU sifive_e (FE310, HiFive1): the mask ROM jumps to XIP flash at 0x20400000; 16 KB DTIM at 0x80000000 */
MEMORY { ROM (rx)  : ORIGIN = 0x20400000, LENGTH = 4M
         RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 16K }
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
