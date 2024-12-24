#include "mm.h"
#include "defs.h"
#include "proc.h"
#include "stdlib.h"
#include "printk.h"
#include "string.h"
#include "elf.h"
#include "vm.h"

extern void __dummy();
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

// add in lab4
extern char swapper_pg_dir[];
extern char _sramdisk[], _eramdisk[], _sbss[];

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此
size_t nr_tasks = 1 + 1;                // 当前线程数

void task_init() {
    srand(2024);
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct *)kalloc();
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
    idle->priority = 0;
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    task[0] = idle;

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
    //     - counter  = 0;
    //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
    //     - ra 设置为 __dummy（见 4.2.2）的地址
    //     - sp 设置为该线程申请的物理页的高地址
    for (int i = 1; i < nr_tasks; ++i) {
        task[i] = (struct task_struct *)kalloc(); // allocate a page for each task
        task[i]->state = TASK_RUNNING; 
        task[i]->counter = 0;
        task[i]->priority = PRIORITY_MIN + rand() % (PRIORITY_MAX - PRIORITY_MIN + 1);
        task[i]->pid = i;
        task[i]->thread.ra = (uint64_t)__dummy;
        task[i]->thread.sp = (uint64_t)task[i] + PGSIZE; // high address of the page
        // 输出 sp 的初始化信息

        // add in lab4
        // 设置 sepc、sstatus 和 sscratch
        // task[i]->thread.sepc = USER_START;
        task[i]->thread.sscratch = USER_END; // 保存临时数据用的
        uint64_t val = csr_read(sstatus); // sstatus 是根据原本的值设置的，要先获取
        task[i]->thread.sstatus = val & (~SSTATUS_SPP) | SSTATUS_SUM; // 设置 sstatus 的 SUM 位

        // 创建页表
        uint64_t *uapp_pgb = (uint64_t *)alloc_pages(1);
        memset(uapp_pgb, 0, PGSIZE); // 先清空
        memcpy(uapp_pgb, swapper_pg_dir, PGSIZE); // 内核页表复制
        // printk("uapp_pgb = %p\n", uapp_pgb);
        task[i]->pgd = (uint64_t *)((uint64_t)uapp_pgb - PA2VA_OFFSET); // 保存用户态页表地址

        // add in lab5
        // // uint64_t uapp_page_number = (_eramdisk - _sramdisk + PGSIZE - 1) / PGSIZE; 
        // // uint64_t uapp_size = _sbss - _sramdisk;
        // // uint64_t *uapp_memory = (uint64_t *)alloc_pages(uapp_page_number);
        // // memset(uapp_memory, 0, uapp_page_number * PGSIZE);
        // // memcpy(uapp_memory, _sramdisk, uapp_size);
        // // // 建立进程页表到新内存地址的映射
        // // create_mapping(uapp_pgb, USER_START, (uint64_t)uapp_memory - PA2VA_OFFSET, uapp_page_number * PGSIZE, PTE_R | PTE_W | PTE_X | PTE_V | PTE_U);
        // // 加载程序
        // load_program(task[i]);
        // // 设置用户态栈
        // uint64_t *uapp_stack= (uint64_t *)alloc_pages(1);
        // create_mapping(uapp_pgb, USER_END - PGSIZE, (uint64_t)uapp_stack - PA2VA_OFFSET, PGSIZE, PTE_R | PTE_W | PTE_V | PTE_U);

        // // 输出调试信息
        // printk("task[%d] priority = %d ", i, task[i]->priority);
        // printk("pid = %d ", i, task[i]->pid);
        // printk("ra = %lx ", task[i]->thread.ra);
        // printk("sp = %lx ", task[i]->thread.sp);
        // printk("pgd = %p\n",task[i]->pgd);

        // 调用 do_mmap 函数，建立用户 task 的虚拟地址空间信息
        Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
        Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
        for (int j = 0; j < ehdr->e_phnum; ++j) {
            Elf64_Phdr *phdr = phdrs + j;
            if (phdr->p_type == PT_LOAD) {
                do_mmap(&(task[i]->mm), phdr->p_vaddr, phdr->p_memsz, (uint64_t)ehdr + (uint64_t)phdr->p_offset, phdr->p_filesz, VM_READ | VM_WRITE | VM_EXEC);
                task[i]->thread.sepc = ehdr->e_entry; // 设置 sepc
                // 输出日志信息, vm_area_struct
                Log("task[%d] mmap: start = %lx, end = %lx, pgoff = %lx, filesz = %lx, flags = %lx", i, task[i]->mm.mmap->vm_start, task[i]->mm.mmap->vm_end, (uint64_t)ehdr + task[i]->mm.mmap->vm_pgoff, task[i]->mm.mmap->vm_filesz, VM_READ | VM_WRITE | VM_EXEC);
            }
        }

        // 设置用户态栈
        do_mmap(&(task[i]->mm), USER_END - PGSIZE, PGSIZE, 0, 0, VM_READ | VM_WRITE | VM_ANON);

        // 创建文件表并保存在 task struct 中
        task[i]->files = (struct files_struct *)file_init();

        // 输出日志信息
        Log("task[%d] priority = %d pid = %d ra = %lx sp = %lx pgd = %p", i, task[i]->priority, task[i]->pid, task[i]->thread.ra, task[i]->thread.sp, task[i]->pgd);
        
    }
    printk("...task_init done!\n");
}

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    uint64_t MOD = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter = -1;
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk(BLUE "[PID = %d] is running. auto_inc_local_var = %d\n" CLEAR, current->pid, auto_inc_local_var);
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
    // YOUR CODE HERE
    if (current == next) {
        return; 
    } else { // switch to next
        struct task_struct *prev = current;
        current = next; // update current
        printk(YELLOW "Switch to [PID = %d PRIORITY = %d COUNTER = %d]\n" CLEAR, current->pid, current->priority, current->counter);
        __switch_to(prev, next);
    }
}

void do_timer() {
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度

    // YOUR CODE HERE
    if (current == idle || current->counter == 0) {
        schedule(); // schedule
    } else {
        --(current->counter); // decrease counter
        if (current->counter == 0) {
            schedule(); // schedule
        }
    }
}

void schedule() {
    // YOUR CODE HERE

    // 1. 选择下一个运行的线程
    struct task_struct *next = idle;

    while (true) {
        // 调度时选择 counter 最大的线程运行    
        for (int i = 1; i < nr_tasks; ++i) {
            if (task[i]->counter > next->counter) {
                next = task[i];
            }
        }

        // 如果所有线程 counter 都为 0，则令所有线程 counter = priority
        // 即优先级越高，运行的时间越长，且越先运行
        // 设置完后需要重新进行调度
        if (next->counter == 0) {
            for (int i = 1; i < nr_tasks; ++i) {
                task[i]->counter = task[i]->priority;
            }

        } else {
            break;
        }

    }
    // 最后通过 switch_to 切换到下一个线程
    switch_to(next);
}

// add in lab5

struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr) {
    struct vm_area_struct *vma = mm->mmap; // 获取 VMA 链表的头

    // 遍历 VMA 链表，找到 addr 对应的 VMA
    while (vma) {
        if (vma->vm_start <= addr && addr < vma->vm_end) {
            return vma;
        }
        vma = vma->vm_next;
    }

    // 没有找到对应的 VMA
    return NULL;
}

uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags) {
    // 新建 vm_area_struct 结构体，根据传入的参数对结构体赋值，并添加到 mm 指向的 VMA 链表中
    struct vm_area_struct *vma = (struct vm_area_struct *)alloc_pages(1);
    // 初始化 VMA
    vma->vm_start = addr;
    vma->vm_end = addr + len;
    vma->vm_pgoff = vm_pgoff;
    vma->vm_filesz = vm_filesz;
    vma->vm_flags = flags;
    vma->vm_mm = mm;
    vma->vm_next = NULL;
    vma->vm_prev = NULL;

    // 将 VMA 添加到 mm 指向的 VMA 链表中
    // 这里我们直接放在链表头部
    vma->vm_next = mm->mmap;
     if (mm->mmap) {
        mm->mmap->vm_prev = vma;

    }
    mm->mmap = vma;

    // 返回 addr
    return addr;
}

void do_page_fault(struct pt_regs *regs) {
    // 通过 stval 获得访问出错的虚拟内存地址（Bad Address）
    uint64_t bad_addr = csr_read(stval);
    // 获取 scause 的值
    uint64_t scause = csr_read(scause);

    // 通过 find_vma() 查找 bad address 是否在某个 vma 中
    struct vm_area_struct *vma = find_vma(&(current->mm), bad_addr);
    // 如果不在，则出现非预期错误，可以通过 Err 宏输出错误信息
    if (!vma) {
        Err("[trap.c,%d,do_page_fault] [S] Unexpected Error: bad_addr=%p", __LINE__, bad_addr);
    } else { // 如果在，则根据 vma 的 flags 权限判断当前 page fault 是否合法
        // 触发的是 instruction page fault 但 vma 权限不允许执行
        if (scause == 0x000000000000000c && !(vma->vm_flags & VM_EXEC)) {
            Err("[trap.c,%d,do_page_fault] [S] Instruction Page Fault: bad_addr=%p", __LINE__, bad_addr);
        }
        // 触发的是 load page fault 但 vma 权限不允许读
        else if (scause == 0x000000000000000d && !(vma->vm_flags & VM_READ)) {
            Err("[trap.c,%d,do_page_fault] [S] Load Page Fault: bad_addr=%p", __LINE__, bad_addr);
        }
        // 触发的是 store page fault 但 vma 权限不允许写
        else if (scause == 0x000000000000000f && !(vma->vm_flags & VM_WRITE)) {
            Err("[trap.c,%d,do_page_fault] [S] Store Page Fault: bad_addr=%p", __LINE__, bad_addr);
        }
        
        // [trap.c,59,do_page_fault] [PID = 2 PC = 0x100e8] valid page fault at `0x100e8` with cause 12
        Log("[trap.c,%d,do_page_fault] [PID = %d PC = %p] valid page fault at `%p` with cause %d", __LINE__, current->pid, regs->sepc, bad_addr, scause);

        // 否则，将 bad address 映射到物理内存
        // 分配一个页，接下来要将这个页映射到对应的用户地址空间
        uint64_t *page = (uint64_t *)alloc_pages(1);
        // 将这个页映射到对应的用户地址空间
        create_mapping((uint64_t *)((uint64_t)current->pgd + PA2VA_OFFSET), PGROUNDDOWN(bad_addr), (uint64_t)page - PA2VA_OFFSET, PGSIZE, (vma->vm_flags & 0xe)  | PTE_V | PTE_U);

        // 通过 (vma->vm_flags & VM_ANON) 获得当前的 VMA 是否是匿名空间
        if (vma->vm_flags & VM_ANON) {
            // 如果是匿名空间，则直接映射即可
            memset(page, 0, PGSIZE);
        } 
        else {
            // 如果不是，则需要根据 vma->vm_pgoff 等信息从 ELF 中读取数据，填充后映射到用户空间
            // 从 ELF 文件中读取数据
            uint64_t elf_page_start = PGROUNDDOWN(vma->vm_pgoff);
            uint64_t elf_page_end = PGROUNDUP(vma->vm_pgoff + vma->vm_filesz);
            // bad address 访问的文件地址
            uint64_t bad_addr_in_file = bad_addr - vma->vm_start + vma->vm_pgoff;
            // bad address 访问的页地址
            uint64_t bad_addr_page = PGROUNDDOWN(bad_addr_in_file);
            // // 输出调试信息
            // Log("elf_page_start = %p", elf_page_start);
            // Log("elf_page_end = %p", elf_page_end);
            // Log("bad_addr_in_file = %p", bad_addr_in_file);
            // Log("bad_addr_page = %p", bad_addr_page);

            // 如果 bad address 访问的页在 ELF 文件中，则将 ELF 文件中的内容复制到内存中
            if (elf_page_start <= bad_addr_page && bad_addr_page < elf_page_end - 1) {
                // 计算需要复制的字节数
                uint64_t copy_size = PGSIZE;
                // 从 ELF 文件中复制数据
                memcpy(page, (void *)bad_addr_page, copy_size);
                
            } else if (bad_addr_page == elf_page_end - 1) {
                // 如果 bad address 在文件的最后一页，需要特殊处理
                // 计算需要复制的字节数
                uint64_t copy_size = (vma->vm_filesz + vma->vm_pgoff) % PGSIZE;
                // 从 ELF 文件中复制数据
                memcpy(page, (void *)bad_addr_page, copy_size);
                // 清空剩余的内存
                memset((void *)((uint64_t)page + copy_size), 0, PGSIZE - copy_size);
            }
        }
    }
}

/*
* Private Functions
*/

void load_program(struct task_struct *task) {
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    // // 输出调试信息
    // printk("ehdr = %p\n", ehdr);
    // printk("phdrs = %p\n", phdrs);
    // // 输出调试信息
    // printk("ehdr->e_entry = %p\n", ehdr->e_entry);

    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // alloc space and copy content
            // do mapping
            // code...
            
            // 获取 ELF 文件中需要 Load 的 Segment 的信息
            uint64_t file_seg_start = (uint64_t) _sramdisk + phdr->p_offset;
            uint64_t file_seg_size = phdr->p_filesz;
            uint64_t file_privilege = phdr->p_flags;
            uint64_t file_seg_start_offset = file_seg_start % PGSIZE;
            // // 输出 ELF 打印信息
            // printk("file_seg_start = %p\n", file_seg_start);
            // printk("file_seg_size = %p\n", file_seg_size);
            // printk("file_privilege = %p\n", file_privilege);
            // printk("file_seg_start_offset = %p\n", file_seg_start_offset);

            // 获取内存对应的信息
            uint64_t mem_seg_start = phdr->p_vaddr;
            uint64_t mem_seg_size = phdr->p_memsz;
            // 计算需要分配的页数
            uint64_t page_number = (mem_seg_size + PGSIZE - 1) / PGSIZE;
            // 为 Segment 分配内存
            uint64_t *mem_seg = (uint64_t *)alloc_pages(page_number);
            // // 输出打印信息
            // printk("mem_seg_start = %p\n", mem_seg_start);
            // printk("mem_seg_size = %p\n", mem_seg_size);
            // printk("page_number = %p\n", page_number);
            // printk("mem_seg = %p\n", mem_seg);
            

            // 将 ELF 文件中的内容复制到内存中
            memset(mem_seg, 0, page_number * PGSIZE);
            memcpy(mem_seg, (uint64_t *)(file_seg_start - file_seg_start_offset), file_seg_size + file_seg_start_offset);
            memset((void *)((uint64_t)mem_seg + file_seg_size + file_seg_start_offset), 0, page_number * PGSIZE - file_seg_start_offset - file_seg_size);
            // 建立映射
            create_mapping((uint64_t *)((uint64_t)task->pgd + PA2VA_OFFSET), mem_seg_start, (uint64_t)mem_seg - PA2VA_OFFSET, page_number * PGSIZE, file_privilege | PTE_U | PTE_X);

        }
    }
    task->thread.sepc = ehdr->e_entry;
    // printk("load program done!\n");
}