#include "stdint.h"
#include "defs.h"

extern char _stext[], _etext[], _srodata[], _erodata[], _sdata[], _edata[], _sbss[], _ebss[];

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
    /* 
     * 1. 由于是进行 1GiB 的映射，这里不需要使用多级页表 
     * 2. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    memset(early_pgtbl, 0, sizeof(early_pgtbl));  

    // 设置等值映射
    early_pgtbl[(((uint64_t)VM_START - (uint64_t)PA2VA_OFFSET) >> 30) & 0x1FF] = (((PHY_START >> 30) & 0x3FFFFFF) << 28) | PTE_V | PTE_R | PTE_W | PTE_X;

    // 设置  direct mapping (PHY_START == VM_START)
    early_pgtbl[((uint64_t)(VM_START) >> 30) & 0x1FF] = (((PHY_START >> 30) & 0x3FFFFFF) << 28) | PTE_V | PTE_R | PTE_W | PTE_X;
}

/* swapper_pg_dir: kernel pagetable 根目录，在 setup_vm_final 进行映射 */
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm_final() {
    memset(swapper_pg_dir, 0x0, sizeof(PGSIZE));

    // No OpenSBI mapping required

    uint64_t va = VM_START + OPENSBI_SIZE; // 0xffffffe002000000
    uint64_t pa = PHY_START + OPENSBI_SIZE; 
    uint64_t size = 0;

    // mapping kernel text X|-|R|V
    size = _srodata - _stext;
    create_mapping(swapper_pg_dir, va, pa, size, PTE_X | PTE_R | PTE_V);
    va += size;
    pa += size;
    // mapping kernel rodata -|-|R|V
    size = _sdata - _srodata;
    create_mapping(swapper_pg_dir, va, pa, size, PTE_R | PTE_V);
    va += size;
    pa += size;
    // mapping other memory -|W|R|V
    size = PHY_END - (uint64_t)_sdata;
    create_mapping(swapper_pg_dir, va, pa, size, PTE_W | PTE_R | PTE_V);

    // set satp with swapper_pg_dir
    uint64_t mode = 0x8000000000000000; // Sv39
    uint64_t PPN = ((uint64_t)swapper_pg_dir - (uint64_t)PA2VA_OFFSET) >> 12; // 
    uint64_t satp_value = mode | PPN; 
    csr_write(satp, satp_value);

    // flush TLB
    asm volatile("sfence.vma zero, zero");


    return;
}


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
    /*
     * pgtbl 为根页表的基地址
     * va, pa 为需要映射的虚拟地址、物理地址
     * sz 为映射的大小，单位为字节
     * perm 为映射的权限（即页表项的低 8 位）
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/

    uint64_t va_end = va + sz;
    uint64_t *tbl; // 页表
    uint64_t vpn, pte; // 虚拟页号，页表项
    while (va < va_end) {
        // 第一级页表
        tbl = pgtbl;
        vpn = ((uint64_t)va >> 30) & 0x1FF;
        pte = tbl[vpn];
        // 如果页表不存在，分配一个新的页表
        if ((pte & PTE_V) == 0) {
            uint64_t new_page = (uint64_t)kalloc() - PA2VA_OFFSET;
            pte = ((uint64_t)new_page >> 12) << 10 | PTE_V;
            tbl[vpn] = pte;
        }

        // 第二级页表
        tbl = (uint64_t*)(((pte >> 10) << 12) + PA2VA_OFFSET);
        vpn = ((uint64_t)va >> 21) & 0x1FF;
        pte = tbl[vpn];
        // 如果页表不存在，分配一个新的页表
        if ((pte & PTE_V) == 0) {
            uint64_t new_page = (uint64_t)kalloc() - PA2VA_OFFSET;
            pte = ((uint64_t)new_page >> 12) << 10 | PTE_V;
            tbl[vpn] = pte;
        }

        // 第三级页表
        tbl = (uint64_t*)(((pte >> 10) << 12) + PA2VA_OFFSET);
        vpn = ((uint64_t)va >> 12) & 0x1FF;
        pte = ((pa >> 12) << 10) | perm | PTE_V;
        tbl[vpn] = pte;

        // 更新虚拟地址和物理地址
        va += PGSIZE;
        pa += PGSIZE;
    }
}