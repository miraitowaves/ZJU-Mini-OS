#include "stdint.h"
#include "defs.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    // 通过 `scause` 判断 trap 类型
    // 如果是 interrupt 判断是否是 timer interrupt
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    // interrupt
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
    // else {
    //         // exception
    //         printk("exception: %d\n", scause);
    //         while (1);
    // }
    return ;
}