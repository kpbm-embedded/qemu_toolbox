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
