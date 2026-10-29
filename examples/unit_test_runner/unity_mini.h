/* A tiny on-target unit test runner: TEST() registers nothing, RUN() calls a test and counts it;
 * CHECK*() report file:line on failure. main() returns the failure count = QEMU exit status. */
#ifndef UNITY_MINI_H
#define UNITY_MINI_H
#include <stdint.h>
#include "semihost.h"
#include "mini.h"
extern uint32_t ut_run, ut_fail, ut_cur_failed;
void ut_report(const char *file, int line, const char *expr);
#define STR_(x) #x
#define STR(x) STR_(x)
#define CHECK(e) do { if (!(e)) ut_report(__FILE__, __LINE__, #e); } while (0)
#define CHECK_EQ(a, b) CHECK((a) == (b))
#define RUN(fn) do { ut_cur_failed = 0; fn(); ut_run++; if (ut_cur_failed) ut_fail++; \
    sh_write0(ut_cur_failed ? "FAIL " : "ok   "); sh_write0(#fn); sh_write0("\n"); } while (0)
int ut_summary(void);
#endif
