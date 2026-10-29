/* tiny freestanding helpers: number formatting into a caller buffer */
#ifndef MINI_H
#define MINI_H
#include <stddef.h>
#include <stdint.h>
char *u32_to_dec(uint32_t v, char *buf);   /* buf >= 11 bytes; returns buf */
char *u32_to_hex(uint32_t v, char *buf);   /* buf >= 11 bytes, "0x" + 8 digits */
#endif
