#include "syscall.h"
#include "printk.h" 
#include "proc.h"   
#include "sbi.h"

extern struct task_struct *current;

size_t sys_write(unsigned int fd, const char *buf, size_t count) {
    if (fd == 1) { // stdout
        for (size_t i = 0; i < count; i++) {
            sbi_debug_console_write_byte(buf[i]);
        }

        return count;
    } else {
        printk("sys_write: not support fd = %d\n", fd);
        return -1; // error
    }
}

uint64_t sys_getpid() {
    return current->pid;
}