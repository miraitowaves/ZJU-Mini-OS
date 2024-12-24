#include "stdint.h"
#include "sbi.h"

/*
当处理器执行 ecall 指令时，
会触发一个陷阱（trap），
将控制权转移到特权模式的陷阱处理程序。
陷阱处理程序根据调用的环境和传递的参数，
执行相应的服务并返回结果。
*/


struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    struct sbiret ret;
    // 使用内联汇编将参数传递给相应的寄存器，并执行 ecall
    __asm__ volatile (
        "mv a7, %[eid]\n"      // 将 eid 放入 a7 寄存器
        "mv a6, %[fid]\n"      // 将 fid 放入 a6 寄存器
        "mv a0, %[arg0]\n"     // 将 arg0 放入 a0 寄存器
        "mv a1, %[arg1]\n"     // 将 arg1 放入 a1 寄存器
        "mv a2, %[arg2]\n"     // 将 arg2 放入 a2 寄存器
        "mv a3, %[arg3]\n"     // 将 arg3 放入 a3 寄存器
        "mv a4, %[arg4]\n"     // 将 arg4 放入 a4 寄存器
        "mv a5, %[arg5]\n"     // 将 arg5 放入 a5 寄存器
        "ecall\n"              // 执行 ecall 指令
        "mv %[error], a0\n"    // 将返回值 a0 放入 ret.error
        "mv %[value], a1\n"    // 将返回值 a1 放入 ret.value
        : [error] "=r" (ret.error), [value] "=r" (ret.value)
        : [eid] "r" (eid), [fid] "r" (fid), 
          [arg0] "r" (arg0), [arg1] "r" (arg1), 
          [arg2] "r" (arg2), [arg3] "r" (arg3),
          [arg4] "r" (arg4), [arg5] "r" (arg5)
        : "memory", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );
    return ret;
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
        return sbi_ecall(0x4442434e, 0x2, (uint64_t) byte, 0, 0, 0, 0, 0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
        return sbi_ecall(0x53525354, 0x0, (uint64_t) reset_type, (uint64_t) reset_reason, 0, 0, 0, 0);
}

struct sbiret sbi_set_timer(uint64_t stime_value) {
        return sbi_ecall(0x54494d45, 0x0, (uint64_t) stime_value, 0, 0, 0, 0, 0);
}

// add in bonus
struct sbiret sbi_debug_console_read(uint64_t num_bytes, uint64_t base_addr_lo, uint64_t base_addr_hi) {
    return sbi_ecall(0x4442434e, 0x1, num_bytes, base_addr_lo, base_addr_hi, 0, 0, 0);
}