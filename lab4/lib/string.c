#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    char *s = (char *)dest;
    for (uint64_t i = 0; i < n; ++i) {
        s[i] = c;
    }
    return dest;
}

void *memcpy(void *dest, const void *src, uint64_t n) {
    // 将指针转换为 unsigned char* 类型，以便逐字节复制
    unsigned char *d = (unsigned char *)dest;
    const unsigned char *s = (const unsigned char *)src;

    // 逐字节复制
    for (uint64_t i = 0; i < n; i++) {
        d[i] = s[i];
    }

    return dest;
}
