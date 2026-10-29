/* AArch64 bare-metal entry for QEMU virt (-kernel: entered at EL1, MMU off, other CPUs held off).
 * .data is loaded in place by QEMU (ELF load to RAM), so only .bss is zeroed. */
    .section .text.start, "ax"
    .globl _start
_start:
    mrs x0, mpidr_el1
    and x0, x0, #0xff
    cbnz x0, park
    ldr x0, =_estack
    mov sp, x0
    ldr x0, =_sbss
    ldr x1, =_ebss
0:  cmp x0, x1
    b.hs 1f
    str xzr, [x0], #8
    b 0b
1:  bl main
    bl sh_exit            /* w0 = main's return value */
park:
    wfe
    b park
