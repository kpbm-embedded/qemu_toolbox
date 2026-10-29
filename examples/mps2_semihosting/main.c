/* Cortex-M4 on QEMU mps2-an386: output and exit status through semihosting only. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

static uint32_t fib(uint32_t n) { uint32_t a = 0, b = 1; while (n--) { uint32_t t = a + b; a = b; b = t; } return a; }

int main(void)
{
    char buf[12];
    sh_write0("hello from Cortex-M4 (mps2-an386) via semihosting\n");
    sh_write0("fib(30) = ");
    sh_write0(u32_to_dec(fib(30), buf));
    sh_write0("\n");
    return fib(30) == 832040 ? 0 : 1;   /* becomes QEMU's exit status */
}
