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
    asm volatile(
            "mv a7, %[eid]\n"         // Move EID to a7
            "mv a6, %[fid]\n"         // Move FID to a6
            "mv a0, %[arg0]\n"        // Move arg0 to a0
            "mv a1, %[arg1]\n"        // Move arg1 to a1
            "mv a2, %[arg2]\n"        // Move arg2 to a2
            "mv a3, %[arg3]\n"        // Move arg3 to a3
            "mv a4, %[arg4]\n"        // Move arg4 to a4
            "mv a5, %[arg5]\n"        // Move arg5 to a5
            "ecall\n"                 // Issue the ecall
            "mv %[err], a0\n"         // Move return error code to ret.err
            "mv %[value], a1\n"       // Move return value to ret.value
            : [err] "=r" (ret.error), [value] "=r" (ret.value)  // Output
            : [eid] "r" (eid), [fid] "r" (fid),                // Input
            [arg0] "r" (arg0), [arg1] "r" (arg1),
            [arg2] "r" (arg2), [arg3] "r" (arg3),
            [arg4] "r" (arg4), [arg5] "r" (arg5)
            : "memory"
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