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
