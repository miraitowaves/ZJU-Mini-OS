#include "stdint.h"
#include "defs.h"
#include "syscall.h"
#include "sbi.h"
#include "proc.h"
#include "clock.h"
#include "printk.h"

struct pt_regs {
    uint64_t ra;
    uint64_t sp;
    uint64_t gp;
    uint64_t tp;
    uint64_t t0;
    uint64_t t1;
    uint64_t t2;
    uint64_t s0;
    uint64_t s1;
    uint64_t a0;
    uint64_t a1;
    uint64_t a2;
    uint64_t a3;
    uint64_t a4;
    uint64_t a5;
    uint64_t a6;
    uint64_t a7;
    uint64_t s2;
    uint64_t s3;
    uint64_t s4;
    uint64_t s5;
    uint64_t s6;
    uint64_t s7;
    uint64_t s8;
    uint64_t s9;
    uint64_t s10;
    uint64_t s11;
    uint64_t t3;
    uint64_t t4;
    uint64_t t5;
    uint64_t t6;
    uint64_t sepc;
    uint64_t sstatus;
};

// add in lab4
void trap_handler(uint64_t scause, uint64_t sepc, struct pt_regs *regs) {
    if (scause & 0x8000000000000000) {
        // timer interrupt
        // print out the timer interrupt information
        // set the next timer interrupt
        switch (scause & 0x7FFFFFFFFFFFFFFF) {
            case 0x000000000000005:
                // printk("[S] Supervisor Mode Timer Interrupt\n");
                clock_set_next_event();
                do_timer();
                break;
            default:
                // other interrupts
                // print out the interrupt information
                printk("other interrupt: %d\n", scause & 0x7FFFFFFFFFFFFFFF);
                break;
        } 
    } 
    else {
        // ecall from U-mode
        if (scause & 0x0000000000000008) {
            // printk("[U] User Mode Environment Call from U-mode\n");
            // 获取 ecall 参数
            uint64_t ecall_num = regs->a7; // a7 寄存器中存放 ecall number
            uint64_t arg0 = regs->a0; // a0 寄存器中存放第一个参数
            uint64_t arg1 = regs->a1; // a1 寄存器中存放第二个参数
            uint64_t arg2 = regs->a2; 
            uint64_t arg3 = regs->a3;
            uint64_t arg4 = regs->a4;
            uint64_t arg5 = regs->a5;
            uint64_t ret = 0;
            switch (ecall_num) {
                case SYS_WRITE: // 64
                    ret = sys_write(arg0, (const char *)arg1, arg2); // fd, buf, count
                    break;
                case SYS_GETPID: // 172
                    ret = sys_getpid();
                    break;
                default:
                    printk("ecall from U-mode: unknown ecall number %lx\n", ecall_num);
                    ret = -1; // error
                    break;
            }
            regs->a0 = ret;

            // 设置 sepc 指向 ecall 指令的下一条指令
            regs->sepc += 4;
        } else {
            // exception
            printk("exception: %d\n", scause);
            while (1);
        }
    }
}


// void trap_handler(uint64_t scause, uint64_t sepc) {
//     // 通过 `scause` 判断 trap 类型
//     // 如果是 interrupt 判断是否是 timer interrupt
//     // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
//     // `clock_set_next_event()` 见 4.3.4 节
//     // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

//     // interrupt
//     if (scause & 0x8000000000000000) {
//         // timer interrupt
//         // print out the timer interrupt information
//         // set the next timer interrupt
//         switch (scause & 0x7FFFFFFFFFFFFFFF) {
//             case 0x000000000000005:
//                 // printk("[S] Supervisor Mode Timer Interrupt\n");
//                 clock_set_next_event();
//                 do_timer();
//                 break;
//             default:
//                 // other interrupts
//                 // print out the interrupt information
//                 printk("other interrupt: %d\n", scause & 0x7FFFFFFFFFFFFFFF);
//                 break;
//         } 
//     } 
//     // else {
//     //         // exception
//     //         printk("exception: %d\n", scause);
//     //         while (1);
//     // }
//     return ;
// }

