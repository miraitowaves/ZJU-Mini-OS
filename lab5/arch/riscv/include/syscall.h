#ifndef SYSCALL_H
#define SYSCALL_H

#include <stddef.h>
#include <stdint.h>
#include "proc.h"

// 定义宏
#define SYS_WRITE 64
#define SYS_GETPID 172
#define SYS_CLONE 220 // add in lab5

size_t sys_write(unsigned int fd, const char *buf, size_t count);
uint64_t sys_getpid();
uint64_t do_fork(struct pt_regs *regs);

#endif // SYSCALL_H