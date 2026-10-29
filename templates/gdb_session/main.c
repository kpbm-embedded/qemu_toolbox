/* @NAME@: target for a scripted debugger session (session.lldb). */
#include <stdint.h>
#include "semihost.h"

volatile uint32_t state;
__attribute__((noinline)) void enter_state(uint32_t s) { state = s; }
__attribute__((noinline)) void step_machine(void) { enter_state(state + 1); }

int main(void)
{
    for (int i = 0; i < 5; i++) step_machine();
    sh_write0(state == 5 ? "@NAME@: PASS\n" : "@NAME@: FAIL\n");
    return state == 5 ? 0 : 1;
}
