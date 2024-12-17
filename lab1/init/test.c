#include "sbi.h"
#include "defs.h"

void test() {
    // sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
    // __builtin_unreachable();
    // int i = 0;
    // while (1) {
    //     if ((++i) % 100000000 == 0) {
    //         printk("kernel is running!\n");
    //         i = 0;
    //     }
    // }

    // uint64_t read_val = csr_read(sstatus);
    // printk("sstatus: 0x%lx\n", read_val);

    // 向 sscratch 寄存器写入数据
    uint64_t write_val = 0x12345678;
    csr_write(sscratch, write_val);

    // 读取 sscratch 寄存器的值
    uint64_t read_val = csr_read(sscratch);
    printk("sscratch: 0x%lx\n", read_val);

    return 0;

}
