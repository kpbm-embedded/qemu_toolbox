/* @NAME@: Cortex-M4 on QEMU mps2-an386. Output via semihosting; return value = exit status. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

int main(void)
{
    char buf[12];
    sh_write0("@NAME@: hello from Cortex-M4\n");
    sh_write0("answer = ");
    sh_write0(u32_to_dec(42, buf));
    sh_write0("\n");
    return 0;
}
