/* QEMU netduinoplus2 (STM32F405RG): 1 MB flash at 0x08000000 (aliased at 0), 128 KB SRAM */
MEMORY { FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 1M
         RAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 128K }
INCLUDE cortexm.ld.inc
