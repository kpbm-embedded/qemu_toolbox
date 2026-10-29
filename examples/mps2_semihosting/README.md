# mps2_semihosting

Cortex-M4 on QEMU's `mps2-an386` (Arm MPS2+ AN386 FPGA image). No UART: output goes through
semihosting (`SYS_WRITE0`), and `main()`'s return value becomes QEMU's exit status (`SYS_EXIT`),
which makes this the fastest pattern for host-run unit tests of Cortex-M code.

    ../../qemu-box examples run mps2_semihosting
    ../../qemu-box examples test mps2_semihosting
