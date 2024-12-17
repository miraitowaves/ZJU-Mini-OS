        .extern start_kernel
    .section .text.init
    .globl _start
_start:
    # (previous) initialize stack
    la sp, boot_stack_top # load address of top to stack_pointer

    # (lab3) setup virtual memory
    call setup_vm
    call relocate

    # (lab2) initialize
    call mm_init

    # (lab3) call setup_vm_final
    call setup_vm_final

    # (lab2) initialize
    call task_init
    
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
    j start_kernel

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    li t0, 0xffffffdf80000000
    add ra, ra, t0
    add sp, sp, t0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    ## lab3 思考题
    #li t0, 0xffffffdf80000000
    #la t1, 1f
    #add t1, t1, t0
    #csrw stvec, t1 

    # set satp with early_pgtbl

    la t0, early_pgtbl
    li t1, 0x8000000000000000 # set mode to 8  
    srli t0, t0, 12     # PA >> 12 == PPN
    or t0, t0, t1
    csrw satp, t0

#1:
    ret

    .section .bss.stack
    .globl boot_stack # 声明全局变量 boot_stack
boot_stack:
    .space 4096 # <-- change to your stack size 预留 4kiB的空间

    .globl boot_stack_top
boot_stack_top: