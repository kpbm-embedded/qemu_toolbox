/* QEMU virt (AArch64, e.g. -cpu cortex-a53): RAM at 0x40000000; -kernel loads the ELF there */
ENTRY(_start)
MEMORY { ROM (rwx) : ORIGIN = 0x40000000, LENGTH = 1M
         RAM (rwx) : ORIGIN = 0x40100000, LENGTH = 1M }
SECTIONS
{
    .text : { KEEP(*(.text.start)) *(.text*) } > ROM
    .rodata : { *(.rodata*) . = ALIGN(16); } > ROM
    .data : { *(.data*) . = ALIGN(16); } > RAM
    .bss (NOLOAD) : { _sbss = .; *(.bss*) *(COMMON) . = ALIGN(16); _ebss = .; } > RAM
    _estack = ORIGIN(RAM) + LENGTH(RAM);
    /DISCARD/ : { *(.comment) }
}
