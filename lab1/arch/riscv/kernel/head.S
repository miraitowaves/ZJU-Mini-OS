    .extern start_kernel
    .section .text.init 
    .globl _start
_start:
    # ------------------
    # - your code here -
    # ------------------

    # (previous) initialize stack
    la sp, boot_stack_top # load stack pointer

    # set stvec = _traps
    la t0, _traps # load address
    csrw stvec, t0 # set trap vector base

    # set sie[STIE] = 1
    csrr t0, sie # load value of sie
    li t1, 0b100000
    or t0, t0, t1 # set STIE 1
    csrw sie, t0 # write back to stvec

    # set first time interrupt
    rdtime a0
    li t0, 10000000 # same in clock.c
    add a0, a0, t0
    call sbi_set_timer

    # set sstatus[SIE] = 1
    csrr t0, sstatus # get value of sie
    li t1, 0b10 # mask
    or t0, t0, t1
    csrw sstatus, t0 # write back to sstatus

    # (previous) jump to start_kernel
    call start_kernel # call start_kernel



    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size

    .globl boot_stack_top
boot_stack_top: