/* QEMU mps2-an386 (Arm MPS2+ AN386, Cortex-M4): 4 MB SSRAM1 at 0 (code), 4 MB SSRAM2/3 at 0x20000000 */
MEMORY { FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 4M
         RAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 4M }
/* common Cortex-M sections; the machine script defines FLASH and RAM */
ENTRY(Reset_Handler)
SECTIONS
{
    .isr_vector : { KEEP(*(.isr_vector)) } > FLASH
    .text : { *(.text*) *(.rodata*) . = ALIGN(4); } > FLASH
    _sidata = LOADADDR(.data);
    .data : { _sdata = .; *(.data*) . = ALIGN(4); _edata = .; } > RAM AT > FLASH
    .bss (NOLOAD) : { _sbss = .; *(.bss*) *(COMMON) . = ALIGN(4); _ebss = .; } > RAM
    _estack = ORIGIN(RAM) + LENGTH(RAM);
    /DISCARD/ : { *(.ARM.exidx*) *(.comment) }
}
