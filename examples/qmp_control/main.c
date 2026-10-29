/* Target for QMP control: an endless loop that counts in a RAM variable and reports through the
 * NS16550 UART every 2^20 iterations. The host stops, inspects and resumes it over QMP. */
#include <stdint.h>
#include "ns16550.h"

volatile uint32_t heartbeat;
volatile uint32_t magic = 0xC0FFEE11u;   /* found by the host with pmemsave + the ELF symbol */

int main(void)
{
    uart_puts(magic == 0xC0FFEE11u ? "qmp target running\n" : "bad .data copy\n");   /* also keeps magic in the image */
    for (;;) {
        heartbeat++;
        if ((heartbeat & 0xFFFFF) == 0) uart_puts(".");
    }
}
