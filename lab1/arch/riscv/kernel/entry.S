.extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 1. save 32 registers and sepc to stack
    # x0不作处理 sp特殊处理
    sd x1, -1*8(sp) # ra
    sd x3, -2*8(sp) 
    sd x4, -3*8(sp) 
    sd x5, -4*8(sp) # t0
    sd x6, -5*8(sp) 
    sd x7, -6*8(sp)
    sd x8, -7*8(sp)
    sd x9, -8*8(sp)
    sd x10, -9*8(sp) # a0
    sd x11, -10*8(sp)
    sd x12, -11*8(sp) # a2
    sd x13, -12*8(sp)
    sd x14, -13*8(sp) 
    sd x15, -14*8(sp)
    sd x16, -15*8(sp) # a6
    sd x17, -16*8(sp)
    sd x18, -17*8(sp) # s2
    sd x19, -18*8(sp)
    sd x20, -19*8(sp)
    sd x21, -20*8(sp)
    sd x22, -21*8(sp) # s6
    sd x23, -22*8(sp)
    sd x24, -23*8(sp)
    sd x25, -24*8(sp)
    sd x26, -25*8(sp)
    sd x27, -26*8(sp) # s11
    sd x28, -27*8(sp) # t3
    sd x29, -28*8(sp)
    sd x30, -29*8(sp)
    sd x31, -30*8(sp)

    csrr t0, sepc # load value of sepc
    sd t0, -31*8(sp)
    sd sp, -32*8(sp) # sp
    addi sp, sp, -32 * 8 # 在栈上分配了32*8字节的空间（32个通用寄存器 + sepc, 但x0不作处理）

    # 2. call trap_handler
    csrr a0, scause
    csrr a1, sepc
    call trap_handler

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, 1*8(sp)
    csrw sepc, t0
    ld x1, 31*8(sp) # ra
    ld x3, 30*8(sp)
    ld x4, 29*8(sp)
    ld x5, 28*8(sp) # t0
    ld x6, 27*8(sp)
    ld x7, 26*8(sp)
    ld x8, 25*8(sp)
    ld x9, 24*8(sp)
    ld x10, 23*8(sp) # a0
    ld x11, 22*8(sp)
    ld x12, 21*8(sp) # a2
    ld x13, 20*8(sp)
    ld x14, 19*8(sp)
    ld x15, 18*8(sp)
    ld x16, 17*8(sp) # a6
    ld x17, 16*8(sp)
    ld x18, 15*8(sp) # s2
    ld x19, 14*8(sp)
    ld x20, 13*8(sp)
    ld x21, 12*8(sp)
    ld x22, 11*8(sp) # s6
    ld x23, 10*8(sp)
    ld x24, 9*8(sp)
    ld x25, 8*8(sp)
    ld x26, 7*8(sp)
    ld x27, 6*8(sp) # s11
    ld x28, 5*8(sp) # t3
    ld x29, 4*8(sp)
    ld x30, 3*8(sp)
    ld x31, 2*8(sp)
    ld x2, 0*8(sp)  # restore sp last

    # 4. return from trap
    sret