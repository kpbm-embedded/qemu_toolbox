/* QEMU mps2-an386 (Arm MPS2+ AN386, Cortex-M4): 4 MB SSRAM1 at 0 (code), 4 MB SSRAM2/3 at 0x20000000 */
MEMORY { FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 4M
         RAM  (rwx) : ORIGIN = 0x20000000, LENGTH = 4M }
INCLUDE cortexm.ld.inc
