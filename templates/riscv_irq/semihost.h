/* Semihosting (Arm "bkpt 0xAB", AArch64 "hlt 0xf000", RISC-V "slli/ebreak/srai"): console, files, exit status. */
#ifndef SEMIHOST_H
#define SEMIHOST_H
#define SYS_OPEN   0x01
#define SYS_CLOSE  0x02
#define SYS_WRITE0 0x04
#define SYS_WRITE  0x05
#define SYS_READ   0x06
#define SYS_FLEN   0x0C
#define SYS_CLOCK  0x10
#define SYS_TIME   0x11
#define SYS_EXIT   0x18
long sh_call(long op, long arg);      /* raw call: op number, argument (often a pointer to a block) */
void sh_write0(const char *s);        /* SYS_WRITE0: NUL-terminated string to the host's stdout */
void sh_exit(int code) __attribute__((noreturn)); /* SYS_EXIT: QEMU exits with code (0 / non-0) */
#endif
