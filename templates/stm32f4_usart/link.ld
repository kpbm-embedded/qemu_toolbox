/* QEMU netduinoplus2 (STM32F405RG): 1 MB flash at 0x08000000 (aliased at 0), 128 KB SRAM */
MEMORY { FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1M
         RAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 128K }
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
