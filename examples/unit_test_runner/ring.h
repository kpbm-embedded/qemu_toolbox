#ifndef RING_H
#define RING_H
#include <stdint.h>
#define RING_SIZE 16
typedef struct { uint8_t buf[RING_SIZE]; uint8_t head, tail; } ring_t;
void ring_init(ring_t *r);
int ring_put(ring_t *r, uint8_t b);
int ring_get(ring_t *r, uint8_t *b);
unsigned ring_count(const ring_t *r);
uint16_t crc16_ccitt(const uint8_t *p, unsigned n);
#endif
