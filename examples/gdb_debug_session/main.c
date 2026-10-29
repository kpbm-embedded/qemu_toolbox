/* Target for the scripted debug session: a global the debugger reads and watches change. */
#include <stdint.h>
#include "semihost.h"

volatile uint32_t counter = 7;

static void bump(void) { counter += 10; }

int main(void)
{
    bump();          /* debugger: break at main, read counter (7), step over -> 17 */
    bump();
    sh_write0("debugme finished\n");
    return counter == 27 ? 0 : 1;
}
