/* @NAME@: unit tests run on the target CPU (Cortex-M4, QEMU mps2-an386). Add RUN(test_x) lines;
 * the failure count is QEMU's exit status, so `make test` fails when a check fails. */
#include "unity_mini.h"
#include "@NAME@_lib.h"

static void test_clamp(void) { CHECK_EQ(clamp_i32(5, 0, 10), 5); CHECK_EQ(clamp_i32(-3, 0, 10), 0); CHECK_EQ(clamp_i32(99, 0, 10), 10); }
static void test_avg(void) { const int32_t v[] = { 2, 4, 6, 8 }; CHECK_EQ(avg_i32(v, 4), 5); CHECK_EQ(avg_i32(v, 0), 0); }

int main(void)
{
    RUN(test_clamp);
    RUN(test_avg);
    int f = ut_summary();
    sh_write0(f ? "@NAME@: FAIL\n" : "@NAME@: PASS\n");
    return f;
}
