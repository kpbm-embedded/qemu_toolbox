/* Target for the watchpoint session: who writes g_mode, and from where? */
#include <stdint.h>
#include "semihost.h"

volatile uint32_t g_mode = 1;
volatile uint32_t g_noise;

__attribute__((noinline)) static void busy(void) { for (int i = 0; i < 5; i++) g_noise += (uint32_t)i; }
__attribute__((noinline)) static void set_mode(uint32_t m) { g_mode = m; }   /* the write we look for */
__attribute__((noinline)) static void handle_command(int cmd) { busy(); if (cmd == 3) set_mode(42); }

int main(void)
{
    for (int c = 0; c < 5; c++) handle_command(c);
    sh_write0("watchme finished\n");
    return g_mode == 42 ? 0 : 1;
}
