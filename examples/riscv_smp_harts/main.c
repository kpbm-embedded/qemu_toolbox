/* RISC-V virt rv64, -smp 4: hart 0 wakes harts 1..3 with CLINT software interrupts (IPIs); each
 * hart adds to a shared counter with amoadd.w and prints under an amoswap spinlock. Hart 0
 * waits for all of them and checks the sum. Pattern for K210 (2 harts) or any SMP RISC-V SoC. */
#include <stdint.h>
#include "ns16550.h"
#include "mini.h"

#define NHARTS 4
#define MSIP(h) (*(volatile uint32_t *)(uintptr_t)(0x02000000u + 4u * (h)))

static volatile uint32_t counter, done, lock;

static void lock_take(void) { uint32_t old; do { __asm__ volatile("amoswap.w.aq %0, %1, (%2)" : "=r"(old) : "r"(1), "r"(&lock) : "memory"); } while (old); }
static void lock_give(void) { __asm__ volatile("amoswap.w.rl zero, zero, (%0)" :: "r"(&lock) : "memory"); }
static void amoadd(volatile uint32_t *p, uint32_t v) { __asm__ volatile("amoadd.w zero, %1, (%0)" :: "r"(p), "r"(v) : "memory"); }

static void say(uint64_t hart, const char *what)
{
    char buf[12];
    lock_take();
    uart_puts("hart "); uart_puts(u32_to_dec((uint32_t)hart, buf)); uart_puts(what);
    lock_give();
}

void hart_main(uint64_t hart)
{
    say(hart, " up\n");
    amoadd(&counter, (uint32_t)(hart * 10));
    amoadd(&done, 1);
}

int main(void)
{
    char buf[12];
    say(0, " boots, waking the others\n");
    for (uint32_t h = 1; h < NHARTS; h++) MSIP(h) = 1;
    while (done < NHARTS - 1) { }
    uart_puts("all "); uart_puts(u32_to_dec(NHARTS, buf)); uart_puts(" harts done, counter = ");
    uart_puts(u32_to_dec(counter, buf)); uart_puts("\n");
    return counter == 60 ? 0 : 1;   /* 10 + 20 + 30 */
}
