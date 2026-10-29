/* Semihosting (Arm "bkpt 0xAB", RISC-V "slli/ebreak/srai"): console output and exit status. */
#ifndef SEMIHOST_H
#define SEMIHOST_H
void sh_write0(const char *s);        /* SYS_WRITE0: NUL-terminated string to the host's stdout */
void sh_exit(int code) __attribute__((noreturn)); /* SYS_EXIT: QEMU exits with code (0 / non-0) */
#endif
