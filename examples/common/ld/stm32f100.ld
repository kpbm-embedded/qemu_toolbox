/* QEMU stm32vldiscovery (STM32F100RB, Cortex-M3): 128 KB flash at 0x08000000, 8 KB RAM */
MEMORY { FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
         RAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 8K }
INCLUDE cortexm.ld.inc
