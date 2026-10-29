#include "semihost.h"

#define SYS_WRITE0 0x04
#define SYS_EXIT   0x18
#define ADP_Stopped_ApplicationExit 0x20026
#define ADP_Stopped_RunTimeErrorUnknown 0x20023

static long sh_call(long op, long arg)
{
#if defined(__arm__)
    register long r0 __asm__("r0") = op;
    register long r1 __asm__("r1") = arg;
    __asm__ volatile("bkpt 0xAB" : "+r"(r0) : "r"(r1) : "memory");
    return r0;
#elif defined(__riscv)
    register long a0 __asm__("a0") = op;
    register long a1 __asm__("a1") = arg;
    /* the three instructions must be uncompressed and in one page (semihosting spec) */
    __asm__ volatile(".option push\n .option norvc\n .balign 16\n"
                     "slli x0, x0, 0x1f\n ebreak\n srai x0, x0, 7\n .option pop"
                     : "+r"(a0) : "r"(a1) : "memory");
    return a0;
#else
#error "unsupported architecture"
#endif
}

void sh_write0(const char *s) { sh_call(SYS_WRITE0, (long)s); }

void sh_exit(int code)
{
#if (defined(__riscv) && __riscv_xlen == 64)
    /* 64-bit semihosting: SYS_EXIT takes a {reason, subcode} block, subcode = exit status */
    static long block[2];
    block[0] = ADP_Stopped_ApplicationExit; block[1] = code;
    sh_call(SYS_EXIT, (long)block);
#else
    sh_call(SYS_EXIT, code == 0 ? ADP_Stopped_ApplicationExit : ADP_Stopped_RunTimeErrorUnknown);
#endif
    for (;;) { }
}
