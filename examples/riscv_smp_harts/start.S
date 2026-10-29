/* Multi-hart entry (QEMU virt -smp N, -bios none: every hart starts here with a0 = hartid).
 * Hart 0 sets up .data/.bss, then wakes the others with a CLINT software interrupt (msip);
 * they wait in WFI with only MSIE enabled (mstatus.MIE stays off, so no trap is taken). */
    .section .text.start, "ax"
    .globl _start
_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    csrr a0, mhartid
    la sp, _estack
    slli t0, a0, 12          /* 4 KB stack per hart */
    sub sp, sp, t0
    bnez a0, secondary
    la t0, _sidata
    la t1, _sdata
    la t2, _edata
0:  bgeu t1, t2, 1f
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j 0b
1:  la t0, _sbss
    la t1, _ebss
2:  bgeu t0, t1, 3f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 2b
3:  call main               /* a0 = 0 */
    call sh_exit
secondary:
    li t0, 8                 /* MSIE */
    csrw mie, t0
4:  wfi
    csrr t0, mip
    andi t0, t0, 8
    beqz t0, 4b
    li t1, 0x02000000        /* CLINT msip[hartid] = 0 */
    slli t2, a0, 2
    add t1, t1, t2
    sw zero, 0(t1)
    call hart_main
5:  wfi
    j 5b
