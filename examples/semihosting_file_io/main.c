/* Cortex-M4 (mps2-an386): semihosting file I/O on the host. Reads numbers from in.txt (in QEMU's
 * working directory), writes their sum to out.txt, and reports SYS_CLOCK / SYS_TIME. Handy to feed
 * test vectors to firmware and collect results without a UART. */
#include <stdint.h>
#include "semihost.h"
#include "mini.h"

static long sh_open(const char *name, long mode)
{
    long n = 0; while (name[n]) n++;
    long blk[3] = { (long)name, mode, n };
    return sh_call(SYS_OPEN, (long)blk);
}
static long sh_rw(long op, long fd, void *buf, long len) { long blk[3] = { fd, (long)buf, len }; return sh_call(op, (long)blk); }
static long sh_close(long fd) { return sh_call(SYS_CLOSE, (long)&fd); }

int main(void)
{
    char buf[12], data[256];
    long fd = sh_open("in.txt", 0 /* "r" */);
    if (fd < 0) { sh_write0("cannot open in.txt\n"); return 1; }
    long len = sh_call(SYS_FLEN, (long)&fd);
    if (len <= 0 || len >= (long)sizeof data) return 1;
    long left = sh_rw(SYS_READ, fd, data, len);          /* returns bytes NOT read */
    sh_close(fd);
    data[len - left] = 0;

    uint32_t sum = 0, cur = 0, count = 0; int in_num = 0;
    for (char *p = data; ; p++) {
        if (*p >= '0' && *p <= '9') { cur = cur * 10 + (uint32_t)(*p - '0'); in_num = 1; }
        else { if (in_num) { sum += cur; count++; } cur = 0; in_num = 0; if (!*p) break; }
    }
    sh_write0("read "); sh_write0(u32_to_dec(count, buf)); sh_write0(" numbers, sum ");
    sh_write0(u32_to_dec(sum, buf)); sh_write0("\n");

    fd = sh_open("out.txt", 4 /* "w" */);
    if (fd < 0) return 1;
    const char *s = u32_to_dec(sum, buf); long n = 0; while (s[n]) n++;
    sh_rw(SYS_WRITE, fd, (void *)s, n);
    sh_rw(SYS_WRITE, fd, "\n", 1);
    sh_close(fd);

    sh_write0("clock "); sh_write0(u32_to_dec((uint32_t)sh_call(SYS_CLOCK, 0), buf));
    sh_write0(" cs, host time "); sh_write0(u32_to_dec((uint32_t)sh_call(SYS_TIME, 0), buf)); sh_write0("\n");
    return 0;
}
