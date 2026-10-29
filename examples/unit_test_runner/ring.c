/* code under test: a byte ring buffer (power-of-two size), as used by UART RX interrupts */
#include "ring.h"
void ring_init(ring_t *r) { r->head = r->tail = 0; }
int ring_put(ring_t *r, uint8_t b) { if ((uint8_t)(r->head - r->tail) == RING_SIZE) return 0; r->buf[r->head++ & (RING_SIZE - 1)] = b; return 1; }
int ring_get(ring_t *r, uint8_t *b) { if (r->head == r->tail) return 0; *b = r->buf[r->tail++ & (RING_SIZE - 1)]; return 1; }
unsigned ring_count(const ring_t *r) { return (uint8_t)(r->head - r->tail); }
uint16_t crc16_ccitt(const uint8_t *p, unsigned n)
{
    uint16_t c = 0xFFFF;
    while (n--) { c ^= (uint16_t)(*p++ << 8); for (int i = 0; i < 8; i++) c = (c & 0x8000) ? (uint16_t)((c << 1) ^ 0x1021) : (uint16_t)(c << 1); }
    return c;
}
