#include "syscall.h"
#include "printk.h" 
#include "proc.h"   
#include "sbi.h"
#include "defs.h"

extern struct task_struct *current;
extern uint64_t nr_tasks;
extern uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));
extern struct task_struct *task[];
extern void __ret_from_fork();

size_t sys_write(unsigned int fd, const char *buf, size_t count) {
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        printk("file not opened\n");
        return ERROR_FILE_NOT_OPEN;
    } else {
        // check perms and call write function of file
        if (file->perms & FILE_WRITABLE) {
            ret = file->write(file, buf, count);
        } else {
            printk("file not writable\n");
            return -1;
        }
    }
    return ret;
}

uint64_t sys_getpid() {
    return current->pid;
}

uint64_t do_fork(struct pt_regs *regs) {
    // 创建一个新进程
    struct task_struct *p;
    p = (struct task_struct *)alloc_pages(1); // 为新进程分配一页内存

    // 拷贝内核栈（包括了 task_struct 等信息）
    memcpy((void*)p, (void*)current, PGSIZE);
    // 略微修改 task_init 的内容
    p->pid = nr_tasks;
    nr_tasks++;
    p->mm.mmap = NULL;

    // 创建一个新的页表
    p->pgd = (uint64_t *)((uint64_t)alloc_pages(1) - PA2VA_OFFSET);
    // 拷贝内核页表 swapper_pg_dir
    memcpy((void *)((uint64_t)p->pgd + PA2VA_OFFSET), swapper_pg_dir, PGSIZE);
    // 遍历父进程 vma, 并遍历父进程页表，将父进程的 vma 复制到子进程
    struct vm_area_struct *vma_parent = current->mm.mmap;
    while (vma_parent) {
        // 创建新进程的 vma
        struct vm_area_struct *vma = (struct vm_area_struct *)alloc_pages(1);
        // 复制 vma
        vma->vm_start = vma_parent->vm_start;   
        vma->vm_end = vma_parent->vm_end;
        vma->vm_pgoff = vma_parent->vm_pgoff;
        vma->vm_filesz = vma_parent->vm_filesz;
        vma->vm_flags = vma_parent->vm_flags;
        vma->vm_mm = &(p->mm);
        vma->vm_next = NULL;
        vma->vm_prev = NULL;    

        // 将 vma 添加到子进程的 vma 链表中
        if (p->mm.mmap) {
            p->mm.mmap->vm_prev = vma;
        }
        vma->vm_next = p->mm.mmap;
        p->mm.mmap = vma;   

        // 处理新进程的页表项
        uint64_t page_start = PGROUNDDOWN(vma->vm_start);
        uint64_t page_end = PGROUNDUP(vma->vm_end);
        // 获取父进程的页表
        uint64_t *pgd_parent = (uint64_t *)((uint64_t)current->pgd + PA2VA_OFFSET);
        // 遍历父进程页表
        for (uint64_t va = page_start; va < page_end; va += PGSIZE) {
            // 获取页表项
            uint64_t vpn1 = (va >> 30) & (uint64_t)0x1FF;
            uint64_t vpn2 = (va >> 21) & (uint64_t)0x1FF;
            uint64_t vpn3 = (va >> 12) & (uint64_t)0x1FF;
            uint64_t pte1 = pgd_parent[vpn1];   
            // 如果页表不存在，跳过
            if ((pte1 & PTE_V) == 0) {
                continue;
            }
            uint64_t *pud = (uint64_t *)(((pte1 >> 10) << 12) + PA2VA_OFFSET);
            uint64_t pte2 = pud[vpn2];
            // 如果页表不存在，跳过
            if ((pte2 & PTE_V) == 0) {
                continue;
            }
            uint64_t *pmd = (uint64_t *)(((pte2 >> 10) << 12) + PA2VA_OFFSET);
            uint64_t pte3 = pmd[vpn3];
            // 如果页表不存在，跳过
            if ((pte3 & PTE_V) == 0) {
                continue;
            }
            // 创建新页表项
            uint64_t *page = (uint64_t *)alloc_pages(1);
            // 将页表项添加到新进程的页表中
            // 输出拷贝标志调试信息
            printk(DEEPGREEN "copy page: va = %p, pa = %p, flags = %p\n" CLEAR, va, (uint64_t)page - PA2VA_OFFSET, vma->vm_flags | PTE_V | PTE_U);
            create_mapping((uint64_t *)((uint64_t)p->pgd + PA2VA_OFFSET), va, (uint64_t)page - PA2VA_OFFSET, PGSIZE, vma->vm_flags | PTE_V | PTE_U);
            // 复制父进程的数据到新页表中
            memcpy((void *)page, va, PGSIZE);
        }

        // 下一个 vma
        vma_parent = vma_parent->vm_next;
    }

    // 将新进程加入调度队列
    task[nr_tasks - 1] = p;

    // 设置新进程的信息
    // 设置新进程的 ra 和 sp
    p->thread.ra = __ret_from_fork;
    p->thread.sp = (uint64_t)p + regs->sp - (uint64_t)current;

    // 设置新进程的 sscratch, 为当前的 sscratch 寄存器的值
    uint64_t val = csr_read(sscratch);
    p->thread.sscratch = val;
    
    // 设置新进程中的 pt_regs 中的 regs->sp
    struct pt_regs *child_regs = (struct pt_regs *)(p->thread.sp);
    child_regs->sp = p->thread.sp;

    // 设置新进程的返回值
    child_regs->a0 = (uint64_t)0;

    // sepc 手动加 4
    child_regs->sepc = regs->sepc + 4;

    //输出日志信息
    // [PID = 2] forked from [PID = 1]
    printk(DEEPGREEN "[PID = %d] forked from [PID = %d]\n" CLEAR, p->pid, current->pid);
    printk(DEEPGREEN "the current sp is %p, PCB is %p, offset is %p\n" CLEAR, regs->sp, (uint64_t)current, regs->sp - (uint64_t)current);
    printk(DEEPGREEN "the child sp is %p, PCB is %p, offset is %p\n" CLEAR, child_regs->sp, p, child_regs->sp - (uint64_t)p);

    // 返回子进程的 pid
    return p->pid;
}

// add in bonus
int64_t sys_read(unsigned int fd, char *buf, size_t count) {
    int64_t ret;
    struct file *file = &(current->files->fd_array[fd]);
    if (file->opened == 0) {
        printk("file not opened\n");
        return ERROR_FILE_NOT_OPEN;
    } else {
        // check perms and call read function of file
        if (file->perms & FILE_READABLE) {
            ret = file->read(file, buf, count);
        } else {
            printk("file not readable\n");
            return -1;
        }
    }
    return ret;
}