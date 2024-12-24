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

int memcmp(const void *s1, const void *s2, uint64_t n) {
    const unsigned char *p1 = s1, *p2 = s2;
    for (uint64_t i = 0; i < n; i++) {
        if (p1[i] != p2[i]) {
            return p1[i] - p2[i];
        }
    }
    return 0;
}

int strlen(const char *s) {
    int len = 0;
    while (s[len] != '\0') {
        len++;
    }
    return len;
}