#include "@NAME@_lib.h"
int32_t clamp_i32(int32_t v, int32_t lo, int32_t hi) { return v < lo ? lo : v > hi ? hi : v; }
int32_t avg_i32(const int32_t *v, uint32_t n) { int32_t s = 0; if (!n) return 0; for (uint32_t i = 0; i < n; i++) s += v[i]; return s / (int32_t)n; }
