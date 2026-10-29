# examples/common: shared bare-metal support (not an example itself)

- `rules.mk`: clang/lld build rules for `ARCH = cm3 | cm4 | rv32 | rv64` (freestanding, no libc).
- `cortexm_start.c`: Cortex-M vector table + reset handler (copies .data, zeroes .bss, calls `main`, exits through semihosting).
- `riscv_start.S`: RISC-V M-mode entry (stack, .bss, `main`, semihosting exit).
- `semihost.c` / `semihost.h`: Arm and RISC-V semihosting (`SYS_WRITE0`, `SYS_EXIT`), so QEMU's exit status is the program's.
- `mini.c`: `memset`/`memcpy` and tiny print helpers (clang may emit calls to the first two).
- `ld/`: one linker script per QEMU machine.
