.extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps
_traps:

    # add in lab4
    csrrw t0, sscratch, t0
    beqz t0, 1f
    # 否则，切换为内核栈
    csrrw t0, sscratch, t0
    csrrw sp, sscratch, sp
    jal x0, 2f

1:
    csrrw t0, sscratch, t0
2:
    # adjust in lab4
    # 1. save 32 registers and sepc to stack
    # addi sp, sp, -32*8
    addi sp, sp, -33*8 # 还要多存一个 sstatus
    sd x1, 0(sp)
    sd x2, 8(sp)
    sd x3, 16(sp)
    sd x4, 24(sp)
    sd x5, 32(sp)
    sd x6, 40(sp)
    sd x7, 48(sp)
    sd x8, 56(sp)
    sd x9, 64(sp)
    sd x10, 72(sp)
    sd x11, 80(sp)
    sd x12, 88(sp)
    sd x13, 96(sp)
    sd x14, 104(sp)
    sd x15, 112(sp)
    sd x16, 120(sp)
    sd x17, 128(sp)
    sd x18, 136(sp)
    sd x19, 144(sp)
    sd x20, 152(sp)
    sd x21, 160(sp)
    sd x22, 168(sp)
    sd x23, 176(sp)
    sd x24, 184(sp)
    sd x25, 192(sp)
    sd x26, 200(sp)
    sd x27, 208(sp)
    sd x28, 216(sp)
    sd x29, 224(sp)
    sd x30, 232(sp)
    sd x31, 240(sp)
    csrr t0, sepc
    sd t0, 248(sp)
    csrr t0, sstatus # add in lab4
    sd t0, 256(sp)

    # 2. call trap_handler
    csrr a0, scause # check which are the argument registers
    csrr a1, sepc
    mv a2, sp
    call trap_handler

    # adjust in lab4
    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, 256(sp)
    csrw sstatus, t0 # add in lab4
    ld t0, 248(sp)
    csrw sepc, t0
    ld x1, 0(sp)
    ld x2, 8(sp)
    ld x3, 16(sp)
    ld x4, 24(sp)
    ld x5, 32(sp)
    ld x6, 40(sp)
    ld x7, 48(sp)
    ld x8, 56(sp)
    ld x9, 64(sp)
    ld x10, 72(sp)
    ld x11, 80(sp)
    ld x12, 88(sp)
    ld x13, 96(sp)
    ld x14, 104(sp)
    ld x15, 112(sp)
    ld x16, 120(sp)
    ld x17, 128(sp)
    ld x18, 136(sp)
    ld x19, 144(sp)
    ld x20, 152(sp)
    ld x21, 160(sp)
    ld x22, 168(sp)
    ld x23, 176(sp)
    ld x24, 184(sp)
    ld x25, 192(sp)
    ld x26, 200(sp)
    ld x27, 208(sp)
    ld x28, 216(sp)
    ld x29, 224(sp)
    ld x30, 232(sp)
    ld x31, 240(sp)
    addi sp, sp, 264

    # add in lab4
    csrrw t0, sscratch, t0
    beqz t0, 3f
    # 否则，切换为用户态栈
    csrrw t0, sscratch, t0
    csrrw sp, sscratch, sp
    jal x0, 4f

3:
    csrrw t0, sscratch, t0
4:
    # 4. return from trap
    sret


    .globl __switch_to
__switch_to:
    # save state to prev process
    # 保存当前线程的寄存器状态到 prev 线程结构体中
    sd ra, 32(a0)           # 保存返回地址 
    sd sp, 40(a0)           # 保存栈指针    
    sd s0, 48(a0)          # 保存 s0
    sd s1, 56(a0)          # 保存 s1
    sd s2, 64(a0)          # 保存 s2
    sd s3, 72(a0)          # 保存 s3
    sd s4, 80(a0)          # 保存 s4
    sd s5, 88(a0)          # 保存 s5
    sd s6, 96(a0)          # 保存 s6
    sd s7, 104(a0)          # 保存 s7
    sd s8, 112(a0)          # 保存 s8
    sd s9, 120(a0)          # 保存 s9
    sd s10, 128(a0)         # 保存 s10
    sd s11, 136(a0)        # 保存 s11
    # add in lab4
    csrr t0, sepc
    sd t0, 144(a0) # 保存 sepc
    csrr t0, sstatus 
    sd t0, 152(a0) # 保存 sstatus
    csrr t0, sscratch
    sd t0, 160(a0) # 保存 sscratch
     


    # restore state from next process
    # 恢复 next 线程结构体中的寄存器状态到当前寄存器
    ld ra, 32(a1)           # 恢复返回地址
    ld sp, 40(a1)           # 恢复栈指针
    ld s0, 48(a1)          # 恢复 s0
    ld s1, 56(a1)          # 恢复 s1
    ld s2, 64(a1)          # 恢复 s2
    ld s3, 72(a1)          # 恢复 s3
    ld s4, 80(a1)          # 恢复 s4
    ld s5, 88(a1)          # 恢复 s5
    ld s6, 96(a1)          # 恢复 s6
    ld s7, 104(a1)          # 恢复 s7
    ld s8, 112(a1)          # 恢复 s8
    ld s9, 120(a1)          # 恢复 s9
    ld s10, 128(a1)         # 恢复 s10
    ld s11, 136(a1)        # 恢复 s11
    # add in lab4
    ld t0, 144(a1) # 恢复 sepc
    csrw sepc, t0
    ld t0, 152(a1) # 恢复 sstatus
    csrw sstatus, t0
    ld t0, 160(a1) # 恢复 sscratch
    csrw sscratch, t0

    # 切换页表
    ld t0, 168(a1) # 加载页表地址
    li t1, 0x8000000000000000 # set mode to 8  
    srli t0, t0, 12     # PA >> 12 == PPN
    or t0, t0, t1
    csrw satp, t0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    ret


    .extern __dummy
    .globl __dummy
__dummy:
    # add in lab4
    # 读取旧值到 sscratch，写 sscratch 到 sp
    csrrw sp, sscratch, sp
    
    # # 确保 sepc 地址对齐
    # la t0, dummy  # 加载 dummy 函数的地址
    # csrw sepc, t0

    # return from __dummy
    sret