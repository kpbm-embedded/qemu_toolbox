/* @NAME@: a guest that runs forever; qmp_client.py controls it from the host. */
#include <stdint.h>

#define THR (*(volatile uint8_t *)0x10000000u)
#define LSR (*(volatile uint8_t *)0x10000005u)
static void puts_(const char *s) { while (*s) { while (!(LSR & 0x20)) { } THR = (uint8_t)*s++; } }

volatile uint32_t counter;

int main(void)
{
    puts_("@NAME@: guest running\n");
    for (;;) counter++;
}
