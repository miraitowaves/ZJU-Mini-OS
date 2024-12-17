#ifndef SYSCALL_H
#define SYSCALL_H

#include <stddef.h>
#include <stdint.h>

// 定义宏
#define SYS_WRITE 64
#define SYS_GETPID 172

size_t sys_write(unsigned int fd, const char *buf, size_t count);
uint64_t sys_getpid();

#endif // SYSCALL_H