#include "sbi.h"
#include "defs.h"
#include "proc.h"

extern char _stext[], _etext[], _srodata[], _erodata[], _sdata[], _edata[], _sbss[], _ebss[];

void test() {
    // for test
    
    // 测试是否能读和写 text 段
    // printk("text: %p %p\n", _stext, _etext);
    // *_stext = 0;

    // // 测试是否能读和写 rodata 段
    // printk("rodata: %p %p\n", _srodata, _erodata);
    // *_srodata = 0;

    while (1) {}
}
