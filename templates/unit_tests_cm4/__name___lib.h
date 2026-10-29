/* code under test */
#ifndef @NAME_UPPER@_LIB_H
#define @NAME_UPPER@_LIB_H
#include <stdint.h>
int32_t clamp_i32(int32_t v, int32_t lo, int32_t hi);
int32_t avg_i32(const int32_t *v, uint32_t n);
#endif
