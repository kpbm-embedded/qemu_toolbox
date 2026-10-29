/* Unit tests that run on the target CPU (Cortex-M4, mps2-an386): same compiler, ABI and
 * alignment as the board. Build with -DINJECT_FAILURE to see a failing run (exit status 1). */
#include "unity_mini.h"
#include "ring.h"

static void test_ring_empty(void) { ring_t r; uint8_t b; ring_init(&r); CHECK_EQ(ring_count(&r), 0u); CHECK(!ring_get(&r, &b)); }
static void test_ring_fifo(void)
{
    ring_t r; uint8_t b; ring_init(&r);
    for (int i = 0; i < 5; i++) CHECK(ring_put(&r, (uint8_t)(i + 1)));
    for (int i = 0; i < 5; i++) { CHECK(ring_get(&r, &b)); CHECK_EQ(b, i + 1); }
}
static void test_ring_full(void)
{
    ring_t r; ring_init(&r);
    for (int i = 0; i < RING_SIZE; i++) CHECK(ring_put(&r, 0xAA));
    CHECK(!ring_put(&r, 0xBB));
    CHECK_EQ(ring_count(&r), (unsigned)RING_SIZE);
}
static void test_ring_wrap(void)
{
    ring_t r; uint8_t b; ring_init(&r);
    for (int i = 0; i < 300; i++) { CHECK(ring_put(&r, (uint8_t)i)); CHECK(ring_get(&r, &b)); CHECK_EQ(b, (uint8_t)i); }
}
static void test_crc16(void)
{
    static const uint8_t v[] = "123456789";
    CHECK_EQ(crc16_ccitt(v, 9), 0x29B1);   /* CRC-16/CCITT-FALSE check value */
#ifdef INJECT_FAILURE
    CHECK_EQ(crc16_ccitt(v, 9), 0x1234);
#endif
}

int main(void)
{
    RUN(test_ring_empty);
    RUN(test_ring_fifo);
    RUN(test_ring_full);
    RUN(test_ring_wrap);
    RUN(test_crc16);
    return ut_summary();
}
