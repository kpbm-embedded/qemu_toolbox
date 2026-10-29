#include "unity_mini.h"
uint32_t ut_run, ut_fail, ut_cur_failed;
void ut_report(const char *file, int line, const char *expr)
{
    char buf[12];
    ut_cur_failed = 1;
    sh_write0("  "); sh_write0(file); sh_write0(":"); sh_write0(u32_to_dec((uint32_t)line, buf));
    sh_write0(": CHECK("); sh_write0(expr); sh_write0(") failed\n");
}
int ut_summary(void)
{
    char buf[12];
    sh_write0(u32_to_dec(ut_run, buf)); sh_write0(" tests, ");
    sh_write0(u32_to_dec(ut_fail, buf)); sh_write0(" failures\n");
    return (int)ut_fail;
}
