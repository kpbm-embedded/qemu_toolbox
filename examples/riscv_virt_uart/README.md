# riscv_virt_uart

One C file built for rv32imac (like CH32V/BL616-class MCUs) and rv64imac (like K210/K230
cores), run on QEMU's generic `virt` machine in M-mode with `-bios none` (no OpenSBI).
Output through the NS16550A UART at 0x10000000; exit through semihosting.

    ../../qemu-box examples run riscv_virt_uart rv64
