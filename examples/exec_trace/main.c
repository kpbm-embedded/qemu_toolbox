/* Target for instruction tracing: a checksum loop whose length is set at build time (ITER).
 * The host counts the instructions QEMU executed inside checksum() from the exec log. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

#ifndef ITER
#define ITER 16
#endif

__attribute__((noinline)) uint32_t checksum(const volatile uint8_t *p, uint32_t n)
{
    uint32_t s = 0;
    for (uint32_t i = 0; i < n; i++) s = (s << 1 | s >> 31) ^ p[i];
    return s;
}

static volatile uint8_t data[64];

int main(void)
{
    char buf[12];
    for (uint32_t i = 0; i < sizeof data; i++) data[i] = (uint8_t)(i * 7);
    uint32_t c = checksum(data, ITER);
    sh_write0("checksum("); sh_write0(u32_to_dec(ITER, buf)); sh_write0(") = "); sh_write0(u32_to_hex(c, buf)); sh_write0("\n");
    return 0;
}
