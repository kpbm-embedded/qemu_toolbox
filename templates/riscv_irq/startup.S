/* RISC-V M-mode entry for QEMU (no OpenSBI): hart 0 runs, others park. */
    .section .text.start, "ax"
    .globl _start
_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    csrr t0, mhartid
    bnez t0, park
    la sp, _estack
    la t0, _sidata        /* .data: load image -> RAM */
    la t1, _sdata
    la t2, _edata
0:  bgeu t1, t2, 1f
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j 0b
1:
    la t0, _sbss
    la t1, _ebss
3:  bgeu t0, t1, 4f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 3b
4:  call main
    call sh_exit          /* a0 = main's return value */
park:
    wfi
    j park
