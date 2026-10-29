/* RISC-V virt (rv32, M-mode, no OpenSBI): machine timer interrupts from the CLINT. mtvec points at
 * a C handler (clang's interrupt("machine") saves registers and returns with mret); each interrupt
 * re-arms mtimecmp 10 ms later. The same CLINT layout is in the K210 and most RISC-V MCUs/SoCs. */
#include <stdint.h>
#include "ns16550.h"
#include "mini.h"

#define CLINT       0x02000000u
#define MTIMECMP_LO (*(volatile uint32_t *)(CLINT + 0x4000))
#define MTIMECMP_HI (*(volatile uint32_t *)(CLINT + 0x4004))
#define MTIME_LO    (*(volatile uint32_t *)(CLINT + 0xBFF8))
#define MTIME_HI    (*(volatile uint32_t *)(CLINT + 0xBFFC))
#define TIMEBASE_HZ 10000000u      /* virt: 10 MHz */
#define PERIOD      (TIMEBASE_HZ / 100u)

static volatile uint32_t ticks;
static volatile uint32_t last_cause;

static uint64_t mtime(void) { uint32_t hi, lo; do { hi = MTIME_HI; lo = MTIME_LO; } while (hi != MTIME_HI); return (uint64_t)hi << 32 | lo; }
static void set_cmp(uint64_t t) { MTIMECMP_HI = 0xFFFFFFFFu; MTIMECMP_LO = (uint32_t)t; MTIMECMP_HI = (uint32_t)(t >> 32); }

__attribute__((interrupt("machine"), aligned(4))) static void trap(void)
{
    uint32_t cause; __asm__ volatile("csrr %0, mcause" : "=r"(cause));
    last_cause = cause;
    if (cause == 0x80000007u) { ticks++; set_cmp(mtime() + PERIOD); }   /* machine timer interrupt */
}

int main(void)
{
    char buf[12];
    __asm__ volatile("csrw mtvec, %0" :: "r"(trap));
    uint64_t t0 = mtime();
    set_cmp(t0 + PERIOD);
    __asm__ volatile("csrs mie, %0" :: "r"(1u << 7));       /* MTIE */
    __asm__ volatile("csrs mstatus, %0" :: "r"(1u << 3));   /* MIE */
    while (ticks < 5) __asm__ volatile("wfi");
    __asm__ volatile("csrc mstatus, %0" :: "r"(1u << 3));
    uint32_t ms = (uint32_t)(mtime() - t0) / (TIMEBASE_HZ / 1000u);   /* 32-bit divide: no libgcc */
    uart_puts("timer irq: "); uart_puts(u32_to_dec(ticks, buf));
    uart_puts(" ticks, mcause "); uart_puts(u32_to_hex(last_cause, buf));
    uart_puts(", elapsed "); uart_puts(u32_to_dec(ms, buf)); uart_puts(" ms\n");
    return (ticks == 5 && last_cause == 0x80000007u && ms >= 50) ? 0 : 1;
}
