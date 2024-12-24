#include "stdint.h"
#include "defs.h"
#include "syscall.h"
#include "sbi.h"
#include "proc.h"
#include "clock.h"
#include "printk.h"

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
                Err("[trap.c,%d,trap_handler] [S] Unhandled Interrupt: scause=%d, sepc=%p", __LINE__, scause, sepc);
                break;
        } 
    } else if (scause == 0x0000000000000008) {
        // ecall from U-mode
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
            case SYS_CLONE: // 220
                ret = do_fork(regs);
                break;
            case SYS_READ: // 63
                ret = sys_read(arg0, (char *)arg1, arg2);
                break;
            default:
                // 输出 scause 和 sepc 和 ecall_num
                Err("[trap.c,%d,trap_handler] [U] Unhandled Ecall: scause=%d, sepc=%p, ecall_num=%d", __LINE__, scause, sepc, ecall_num);
                break;
        }
        regs->a0 = ret;
        // 设置 sepc 指向 ecall 指令的下一条指令
        regs->sepc += 4;

    } else if (scause == 0x000000000000000c | scause == 0x000000000000000d | scause == 0x000000000000000f) {
        do_page_fault(regs);
    }
    else {
        // [trap.c,129,trap_handler] [S] Unhandled Exception: scause=12, sepc=0x100e8, stval=0x100e8
        Err("[trap.c,%d,trap_handler] [S] Unhandled Exception: scause=%d, sepc=%p, stval=%p", __LINE__, scause, sepc, regs->a0);
    }
}

// used in lab1-3
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

