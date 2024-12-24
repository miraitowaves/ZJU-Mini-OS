#ifndef __STRING_H__
#define __STRING_H__

#include "stdint.h"

void *memset(void *dest, int c, uint64_t n);

void *memcpy(void *dest, const void * src, uint64_t n);

// add in bonus
int memcmp(const void *, const void *, uint64_t);
int strlen(const char *);

#endif
