#include "mini.h"

/* clang may lower struct copies / zeroing to these calls even with -fno-builtin */
void *memset(void *d, int c, size_t n) { unsigned char *p = d; while (n--) *p++ = (unsigned char)c; return d; }
void *memcpy(void *d, const void *s, size_t n) { unsigned char *p = d; const unsigned char *q = s; while (n--) *p++ = *q++; return d; }

char *u32_to_dec(uint32_t v, char *buf)
{
    char t[11]; int i = 0, j = 0;
    do { t[i++] = (char)('0' + v % 10); v /= 10; } while (v);
    while (i) buf[j++] = t[--i];
    buf[j] = 0;
    return buf;
}

char *u32_to_hex(uint32_t v, char *buf)
{
    static const char hx[] = "0123456789abcdef";
    buf[0] = '0'; buf[1] = 'x';
    for (int i = 0; i < 8; i++) buf[2 + i] = hx[(v >> (28 - 4 * i)) & 0xf];
    buf[10] = 0;
    return buf;
}

#if defined(__ARM_ARCH_6M__)
/* Cortex-M0 has no divide instruction: the AEABI helpers clang calls for / and % (no libgcc here) */
static uint32_t udiv(uint32_t n, uint32_t d, uint32_t *rem)
{
    uint32_t q = 0, r = 0;
    for (int i = 31; i >= 0; i--) { r = (r << 1) | ((n >> i) & 1u); if (r >= d) { r -= d; q |= 1u << i; } }
    *rem = r;
    return q;
}
uint32_t __aeabi_uidiv(uint32_t n, uint32_t d) { uint32_t r; return udiv(n, d, &r); }
uint64_t __aeabi_uidivmod(uint32_t n, uint32_t d) { uint32_t r, q = udiv(n, d, &r); return (uint64_t)r << 32 | q; }
#endif
