
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    # ------------------
    # - your code here -
    # ------------------

    # (previous) initialize stack
    la sp, boot_stack_top # load stack pointer
    80200000:	00003117          	auipc	sp,0x3
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>

    # set stvec = _traps
    la t0, _traps # load address
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec, t0 # set trap vector base
    80200010:	10529073          	csrw	stvec,t0

    # set sie[STIE] = 1
    csrr t0, sie # load value of sie
    80200014:	104022f3          	csrr	t0,sie
    li t1, 0b100000
    80200018:	02000313          	li	t1,32
    or t0, t0, t1 # set STIE 1
    8020001c:	0062e2b3          	or	t0,t0,t1
    csrw sie, t0 # write back to stvec
    80200020:	10429073          	csrw	sie,t0

    # set first time interrupt
    rdtime a0
    80200024:	c0102573          	rdtime	a0
    li t0, 10000000 # same in clock.c
    80200028:	009892b7          	lui	t0,0x989
    8020002c:	6802829b          	addiw	t0,t0,1664 # 989680 <_skernel-0x7f876980>
    add a0, a0, t0
    80200030:	00550533          	add	a0,a0,t0
    call sbi_set_timer
    80200034:	38c000ef          	jal	802003c0 <sbi_set_timer>

    # set sstatus[SIE] = 1
    csrr t0, sstatus # get value of sie
    80200038:	100022f3          	csrr	t0,sstatus
    li t1, 0b10 # mask
    8020003c:	00200313          	li	t1,2
    or t0, t0, t1
    80200040:	0062e2b3          	or	t0,t0,t1
    csrw sstatus, t0 # write back to sstatus
    80200044:	10029073          	csrw	sstatus,t0

    # (previous) jump to start_kernel
    call start_kernel # call start_kernel
    80200048:	48c000ef          	jal	802004d4 <start_kernel>

000000008020004c <_traps>:
    .align 2
    .globl _traps 
_traps:
    # 1. save 32 registers and sepc to stack
    # x0不作处理 sp特殊处理
    sd x1, -1*8(sp) # ra
    8020004c:	fe113c23          	sd	ra,-8(sp)
    sd x3, -2*8(sp) 
    80200050:	fe313823          	sd	gp,-16(sp)
    sd x4, -3*8(sp) 
    80200054:	fe413423          	sd	tp,-24(sp)
    sd x5, -4*8(sp) # t0
    80200058:	fe513023          	sd	t0,-32(sp)
    sd x6, -5*8(sp) 
    8020005c:	fc613c23          	sd	t1,-40(sp)
    sd x7, -6*8(sp)
    80200060:	fc713823          	sd	t2,-48(sp)
    sd x8, -7*8(sp)
    80200064:	fc813423          	sd	s0,-56(sp)
    sd x9, -8*8(sp)
    80200068:	fc913023          	sd	s1,-64(sp)
    sd x10, -9*8(sp) # a0
    8020006c:	faa13c23          	sd	a0,-72(sp)
    sd x11, -10*8(sp)
    80200070:	fab13823          	sd	a1,-80(sp)
    sd x12, -11*8(sp) # a2
    80200074:	fac13423          	sd	a2,-88(sp)
    sd x13, -12*8(sp)
    80200078:	fad13023          	sd	a3,-96(sp)
    sd x14, -13*8(sp) 
    8020007c:	f8e13c23          	sd	a4,-104(sp)
    sd x15, -14*8(sp)
    80200080:	f8f13823          	sd	a5,-112(sp)
    sd x16, -15*8(sp) # a6
    80200084:	f9013423          	sd	a6,-120(sp)
    sd x17, -16*8(sp)
    80200088:	f9113023          	sd	a7,-128(sp)
    sd x18, -17*8(sp) # s2
    8020008c:	f7213c23          	sd	s2,-136(sp)
    sd x19, -18*8(sp)
    80200090:	f7313823          	sd	s3,-144(sp)
    sd x20, -19*8(sp)
    80200094:	f7413423          	sd	s4,-152(sp)
    sd x21, -20*8(sp)
    80200098:	f7513023          	sd	s5,-160(sp)
    sd x22, -21*8(sp) # s6
    8020009c:	f5613c23          	sd	s6,-168(sp)
    sd x23, -22*8(sp)
    802000a0:	f5713823          	sd	s7,-176(sp)
    sd x24, -23*8(sp)
    802000a4:	f5813423          	sd	s8,-184(sp)
    sd x25, -24*8(sp)
    802000a8:	f5913023          	sd	s9,-192(sp)
    sd x26, -25*8(sp)
    802000ac:	f3a13c23          	sd	s10,-200(sp)
    sd x27, -26*8(sp) # s11
    802000b0:	f3b13823          	sd	s11,-208(sp)
    sd x28, -27*8(sp) # t3
    802000b4:	f3c13423          	sd	t3,-216(sp)
    sd x29, -28*8(sp)
    802000b8:	f3d13023          	sd	t4,-224(sp)
    sd x30, -29*8(sp)
    802000bc:	f1e13c23          	sd	t5,-232(sp)
    sd x31, -30*8(sp)
    802000c0:	f1f13823          	sd	t6,-240(sp)

    csrr t0, sepc # load value of sepc
    802000c4:	141022f3          	csrr	t0,sepc
    sd t0, -31*8(sp)
    802000c8:	f0513423          	sd	t0,-248(sp)
    sd sp, -32*8(sp) # sp
    802000cc:	f0213023          	sd	sp,-256(sp)
    addi sp, sp, -32 * 8 # 在栈上分配了32*8字节的空间（32个通用寄存器 + sepc, 但x0不作处理）
    802000d0:	f0010113          	addi	sp,sp,-256

    # 2. call trap_handler
    csrr a0, scause
    802000d4:	14202573          	csrr	a0,scause
    csrr a1, sepc
    802000d8:	141025f3          	csrr	a1,sepc
    call trap_handler
    802000dc:	370000ef          	jal	8020044c <trap_handler>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, 1*8(sp)
    802000e0:	00813283          	ld	t0,8(sp)
    csrw sepc, t0
    802000e4:	14129073          	csrw	sepc,t0
    ld x1, 31*8(sp) # ra
    802000e8:	0f813083          	ld	ra,248(sp)
    ld x3, 30*8(sp)
    802000ec:	0f013183          	ld	gp,240(sp)
    ld x4, 29*8(sp)
    802000f0:	0e813203          	ld	tp,232(sp)
    ld x5, 28*8(sp) # t0
    802000f4:	0e013283          	ld	t0,224(sp)
    ld x6, 27*8(sp)
    802000f8:	0d813303          	ld	t1,216(sp)
    ld x7, 26*8(sp)
    802000fc:	0d013383          	ld	t2,208(sp)
    ld x8, 25*8(sp)
    80200100:	0c813403          	ld	s0,200(sp)
    ld x9, 24*8(sp)
    80200104:	0c013483          	ld	s1,192(sp)
    ld x10, 23*8(sp) # a0
    80200108:	0b813503          	ld	a0,184(sp)
    ld x11, 22*8(sp)
    8020010c:	0b013583          	ld	a1,176(sp)
    ld x12, 21*8(sp) # a2
    80200110:	0a813603          	ld	a2,168(sp)
    ld x13, 20*8(sp)
    80200114:	0a013683          	ld	a3,160(sp)
    ld x14, 19*8(sp)
    80200118:	09813703          	ld	a4,152(sp)
    ld x15, 18*8(sp)
    8020011c:	09013783          	ld	a5,144(sp)
    ld x16, 17*8(sp) # a6
    80200120:	08813803          	ld	a6,136(sp)
    ld x17, 16*8(sp)
    80200124:	08013883          	ld	a7,128(sp)
    ld x18, 15*8(sp) # s2
    80200128:	07813903          	ld	s2,120(sp)
    ld x19, 14*8(sp)
    8020012c:	07013983          	ld	s3,112(sp)
    ld x20, 13*8(sp)
    80200130:	06813a03          	ld	s4,104(sp)
    ld x21, 12*8(sp)
    80200134:	06013a83          	ld	s5,96(sp)
    ld x22, 11*8(sp) # s6
    80200138:	05813b03          	ld	s6,88(sp)
    ld x23, 10*8(sp)
    8020013c:	05013b83          	ld	s7,80(sp)
    ld x24, 9*8(sp)
    80200140:	04813c03          	ld	s8,72(sp)
    ld x25, 8*8(sp)
    80200144:	04013c83          	ld	s9,64(sp)
    ld x26, 7*8(sp)
    80200148:	03813d03          	ld	s10,56(sp)
    ld x27, 6*8(sp) # s11
    8020014c:	03013d83          	ld	s11,48(sp)
    ld x28, 5*8(sp) # t3
    80200150:	02813e03          	ld	t3,40(sp)
    ld x29, 4*8(sp)
    80200154:	02013e83          	ld	t4,32(sp)
    ld x30, 3*8(sp)
    80200158:	01813f03          	ld	t5,24(sp)
    ld x31, 2*8(sp)
    8020015c:	01013f83          	ld	t6,16(sp)
    ld x2, 0*8(sp)  # restore sp last
    80200160:	00013103          	ld	sp,0(sp)

    # 4. return from trap
    80200164:	10200073          	sret

0000000080200168 <get_cycles>:
#include "stdint.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    80200168:	fe010113          	addi	sp,sp,-32
    8020016c:	00813c23          	sd	s0,24(sp)
    80200170:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    uint64_t cycles; // 存储返回值
    asm volatile("rdtime %0" : "=r" (cycles));
    80200174:	c01027f3          	rdtime	a5
    80200178:	fef43423          	sd	a5,-24(s0)
    return cycles;
    8020017c:	fe843783          	ld	a5,-24(s0)
}
    80200180:	00078513          	mv	a0,a5
    80200184:	01813403          	ld	s0,24(sp)
    80200188:	02010113          	addi	sp,sp,32
    8020018c:	00008067          	ret

0000000080200190 <clock_set_next_event>:

void clock_set_next_event() {
    80200190:	fe010113          	addi	sp,sp,-32
    80200194:	00113c23          	sd	ra,24(sp)
    80200198:	00813823          	sd	s0,16(sp)
    8020019c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    802001a0:	fc9ff0ef          	jal	80200168 <get_cycles>
    802001a4:	00050713          	mv	a4,a0
    802001a8:	00003797          	auipc	a5,0x3
    802001ac:	e5878793          	addi	a5,a5,-424 # 80203000 <TIMECLOCK>
    802001b0:	0007b783          	ld	a5,0(a5)
    802001b4:	00f707b3          	add	a5,a4,a5
    802001b8:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    802001bc:	fe843503          	ld	a0,-24(s0)
    802001c0:	200000ef          	jal	802003c0 <sbi_set_timer>
    802001c4:	00000013          	nop
    802001c8:	01813083          	ld	ra,24(sp)
    802001cc:	01013403          	ld	s0,16(sp)
    802001d0:	02010113          	addi	sp,sp,32
    802001d4:	00008067          	ret

00000000802001d8 <sbi_ecall>:
*/


struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001d8:	f9010113          	addi	sp,sp,-112
    802001dc:	06813423          	sd	s0,104(sp)
    802001e0:	07010413          	addi	s0,sp,112
    802001e4:	fca43423          	sd	a0,-56(s0)
    802001e8:	fcb43023          	sd	a1,-64(s0)
    802001ec:	fac43c23          	sd	a2,-72(s0)
    802001f0:	fad43823          	sd	a3,-80(s0)
    802001f4:	fae43423          	sd	a4,-88(s0)
    802001f8:	faf43023          	sd	a5,-96(s0)
    802001fc:	f9043c23          	sd	a6,-104(s0)
    80200200:	f9143823          	sd	a7,-112(s0)
    struct sbiret ret;
    asm volatile(
    80200204:	fc843783          	ld	a5,-56(s0)
    80200208:	fc043703          	ld	a4,-64(s0)
    8020020c:	fb843683          	ld	a3,-72(s0)
    80200210:	fb043603          	ld	a2,-80(s0)
    80200214:	fa843583          	ld	a1,-88(s0)
    80200218:	fa043503          	ld	a0,-96(s0)
    8020021c:	f9843803          	ld	a6,-104(s0)
    80200220:	f9043883          	ld	a7,-112(s0)
    80200224:	00078893          	mv	a7,a5
    80200228:	00070813          	mv	a6,a4
    8020022c:	00068513          	mv	a0,a3
    80200230:	00060593          	mv	a1,a2
    80200234:	00058613          	mv	a2,a1
    80200238:	00050693          	mv	a3,a0
    8020023c:	00080713          	mv	a4,a6
    80200240:	00088793          	mv	a5,a7
    80200244:	00000073          	ecall
    80200248:	00050713          	mv	a4,a0
    8020024c:	00058793          	mv	a5,a1
    80200250:	fce43823          	sd	a4,-48(s0)
    80200254:	fcf43c23          	sd	a5,-40(s0)
            [arg0] "r" (arg0), [arg1] "r" (arg1),
            [arg2] "r" (arg2), [arg3] "r" (arg3),
            [arg4] "r" (arg4), [arg5] "r" (arg5)
            : "memory"
    );
    return ret;
    80200258:	fd043783          	ld	a5,-48(s0)
    8020025c:	fef43023          	sd	a5,-32(s0)
    80200260:	fd843783          	ld	a5,-40(s0)
    80200264:	fef43423          	sd	a5,-24(s0)
    80200268:	fe043703          	ld	a4,-32(s0)
    8020026c:	fe843783          	ld	a5,-24(s0)
    80200270:	00070313          	mv	t1,a4
    80200274:	00078393          	mv	t2,a5
    80200278:	00030713          	mv	a4,t1
    8020027c:	00038793          	mv	a5,t2
}
    80200280:	00070513          	mv	a0,a4
    80200284:	00078593          	mv	a1,a5
    80200288:	06813403          	ld	s0,104(sp)
    8020028c:	07010113          	addi	sp,sp,112
    80200290:	00008067          	ret

0000000080200294 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200294:	fc010113          	addi	sp,sp,-64
    80200298:	02113c23          	sd	ra,56(sp)
    8020029c:	02813823          	sd	s0,48(sp)
    802002a0:	03213423          	sd	s2,40(sp)
    802002a4:	03313023          	sd	s3,32(sp)
    802002a8:	04010413          	addi	s0,sp,64
    802002ac:	00050793          	mv	a5,a0
    802002b0:	fcf407a3          	sb	a5,-49(s0)
        return sbi_ecall(0x4442434e, 0x2, (uint64_t) byte, 0, 0, 0, 0, 0);
    802002b4:	fcf44603          	lbu	a2,-49(s0)
    802002b8:	00000893          	li	a7,0
    802002bc:	00000813          	li	a6,0
    802002c0:	00000793          	li	a5,0
    802002c4:	00000713          	li	a4,0
    802002c8:	00000693          	li	a3,0
    802002cc:	00200593          	li	a1,2
    802002d0:	44424537          	lui	a0,0x44424
    802002d4:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    802002d8:	f01ff0ef          	jal	802001d8 <sbi_ecall>
    802002dc:	00050713          	mv	a4,a0
    802002e0:	00058793          	mv	a5,a1
    802002e4:	fce43823          	sd	a4,-48(s0)
    802002e8:	fcf43c23          	sd	a5,-40(s0)
    802002ec:	fd043703          	ld	a4,-48(s0)
    802002f0:	fd843783          	ld	a5,-40(s0)
    802002f4:	00070913          	mv	s2,a4
    802002f8:	00078993          	mv	s3,a5
    802002fc:	00090713          	mv	a4,s2
    80200300:	00098793          	mv	a5,s3
}
    80200304:	00070513          	mv	a0,a4
    80200308:	00078593          	mv	a1,a5
    8020030c:	03813083          	ld	ra,56(sp)
    80200310:	03013403          	ld	s0,48(sp)
    80200314:	02813903          	ld	s2,40(sp)
    80200318:	02013983          	ld	s3,32(sp)
    8020031c:	04010113          	addi	sp,sp,64
    80200320:	00008067          	ret

0000000080200324 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200324:	fc010113          	addi	sp,sp,-64
    80200328:	02113c23          	sd	ra,56(sp)
    8020032c:	02813823          	sd	s0,48(sp)
    80200330:	03213423          	sd	s2,40(sp)
    80200334:	03313023          	sd	s3,32(sp)
    80200338:	04010413          	addi	s0,sp,64
    8020033c:	00050793          	mv	a5,a0
    80200340:	00058713          	mv	a4,a1
    80200344:	fcf42623          	sw	a5,-52(s0)
    80200348:	00070793          	mv	a5,a4
    8020034c:	fcf42423          	sw	a5,-56(s0)
        return sbi_ecall(0x53525354, 0x0, (uint64_t) reset_type, (uint64_t) reset_reason, 0, 0, 0, 0);
    80200350:	fcc46603          	lwu	a2,-52(s0)
    80200354:	fc846683          	lwu	a3,-56(s0)
    80200358:	00000893          	li	a7,0
    8020035c:	00000813          	li	a6,0
    80200360:	00000793          	li	a5,0
    80200364:	00000713          	li	a4,0
    80200368:	00000593          	li	a1,0
    8020036c:	53525537          	lui	a0,0x53525
    80200370:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200374:	e65ff0ef          	jal	802001d8 <sbi_ecall>
    80200378:	00050713          	mv	a4,a0
    8020037c:	00058793          	mv	a5,a1
    80200380:	fce43823          	sd	a4,-48(s0)
    80200384:	fcf43c23          	sd	a5,-40(s0)
    80200388:	fd043703          	ld	a4,-48(s0)
    8020038c:	fd843783          	ld	a5,-40(s0)
    80200390:	00070913          	mv	s2,a4
    80200394:	00078993          	mv	s3,a5
    80200398:	00090713          	mv	a4,s2
    8020039c:	00098793          	mv	a5,s3
}
    802003a0:	00070513          	mv	a0,a4
    802003a4:	00078593          	mv	a1,a5
    802003a8:	03813083          	ld	ra,56(sp)
    802003ac:	03013403          	ld	s0,48(sp)
    802003b0:	02813903          	ld	s2,40(sp)
    802003b4:	02013983          	ld	s3,32(sp)
    802003b8:	04010113          	addi	sp,sp,64
    802003bc:	00008067          	ret

00000000802003c0 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value) {
    802003c0:	fc010113          	addi	sp,sp,-64
    802003c4:	02113c23          	sd	ra,56(sp)
    802003c8:	02813823          	sd	s0,48(sp)
    802003cc:	03213423          	sd	s2,40(sp)
    802003d0:	03313023          	sd	s3,32(sp)
    802003d4:	04010413          	addi	s0,sp,64
    802003d8:	fca43423          	sd	a0,-56(s0)
        return sbi_ecall(0x54494d45, 0x0, (uint64_t) stime_value, 0, 0, 0, 0, 0);
    802003dc:	00000893          	li	a7,0
    802003e0:	00000813          	li	a6,0
    802003e4:	00000793          	li	a5,0
    802003e8:	00000713          	li	a4,0
    802003ec:	00000693          	li	a3,0
    802003f0:	fc843603          	ld	a2,-56(s0)
    802003f4:	00000593          	li	a1,0
    802003f8:	54495537          	lui	a0,0x54495
    802003fc:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200400:	dd9ff0ef          	jal	802001d8 <sbi_ecall>
    80200404:	00050713          	mv	a4,a0
    80200408:	00058793          	mv	a5,a1
    8020040c:	fce43823          	sd	a4,-48(s0)
    80200410:	fcf43c23          	sd	a5,-40(s0)
    80200414:	fd043703          	ld	a4,-48(s0)
    80200418:	fd843783          	ld	a5,-40(s0)
    8020041c:	00070913          	mv	s2,a4
    80200420:	00078993          	mv	s3,a5
    80200424:	00090713          	mv	a4,s2
    80200428:	00098793          	mv	a5,s3
    8020042c:	00070513          	mv	a0,a4
    80200430:	00078593          	mv	a1,a5
    80200434:	03813083          	ld	ra,56(sp)
    80200438:	03013403          	ld	s0,48(sp)
    8020043c:	02813903          	ld	s2,40(sp)
    80200440:	02013983          	ld	s3,32(sp)
    80200444:	04010113          	addi	sp,sp,64
    80200448:	00008067          	ret

000000008020044c <trap_handler>:
#include "stdint.h"

void trap_handler(uint64_t scause, uint64_t sepc) {
    8020044c:	fe010113          	addi	sp,sp,-32
    80200450:	00113c23          	sd	ra,24(sp)
    80200454:	00813823          	sd	s0,16(sp)
    80200458:	02010413          	addi	s0,sp,32
    8020045c:	fea43423          	sd	a0,-24(s0)
    80200460:	feb43023          	sd	a1,-32(s0)
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    // `clock_set_next_event()` 见 4.3.4 节
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试

    // interrupt
    if (scause & 0x8000000000000000) {
    80200464:	fe843783          	ld	a5,-24(s0)
    80200468:	0407dc63          	bgez	a5,802004c0 <trap_handler+0x74>
        // timer interrupt
        // print out the timer interrupt information
        // set the next timer interrupt
        switch (scause & 0x7FFFFFFFFFFFFFFF) {
    8020046c:	fe843703          	ld	a4,-24(s0)
    80200470:	fff00793          	li	a5,-1
    80200474:	0017d793          	srli	a5,a5,0x1
    80200478:	00f77733          	and	a4,a4,a5
    8020047c:	00500793          	li	a5,5
    80200480:	00f71c63          	bne	a4,a5,80200498 <trap_handler+0x4c>
            case 0x000000000000005:

                printk("[S] Supervisor Mode Timer Interrupt\n");
    80200484:	00002517          	auipc	a0,0x2
    80200488:	b7c50513          	addi	a0,a0,-1156 # 80202000 <_srodata>
    8020048c:	781000ef          	jal	8020140c <printk>
                clock_set_next_event();
    80200490:	d01ff0ef          	jal	80200190 <clock_set_next_event>
                break;
    80200494:	0280006f          	j	802004bc <trap_handler+0x70>
            default:
                // other interrupts
                // print out the interrupt information
                printk("other interrupt: %d\n", scause & 0x7FFFFFFFFFFFFFFF);
    80200498:	fe843703          	ld	a4,-24(s0)
    8020049c:	fff00793          	li	a5,-1
    802004a0:	0017d793          	srli	a5,a5,0x1
    802004a4:	00f777b3          	and	a5,a4,a5
    802004a8:	00078593          	mv	a1,a5
    802004ac:	00002517          	auipc	a0,0x2
    802004b0:	b7c50513          	addi	a0,a0,-1156 # 80202028 <_srodata+0x28>
    802004b4:	759000ef          	jal	8020140c <printk>
                break;
    802004b8:	00000013          	nop
        }
    }
    return ;
    802004bc:	00000013          	nop
    802004c0:	00000013          	nop
    802004c4:	01813083          	ld	ra,24(sp)
    802004c8:	01013403          	ld	s0,16(sp)
    802004cc:	02010113          	addi	sp,sp,32
    802004d0:	00008067          	ret

00000000802004d4 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel() {
    802004d4:	ff010113          	addi	sp,sp,-16
    802004d8:	00113423          	sd	ra,8(sp)
    802004dc:	00813023          	sd	s0,0(sp)
    802004e0:	01010413          	addi	s0,sp,16
    printk("2024");
    802004e4:	00002517          	auipc	a0,0x2
    802004e8:	b5c50513          	addi	a0,a0,-1188 # 80202040 <_srodata+0x40>
    802004ec:	721000ef          	jal	8020140c <printk>
    printk(" ZJU Operating System\n");
    802004f0:	00002517          	auipc	a0,0x2
    802004f4:	b5850513          	addi	a0,a0,-1192 # 80202048 <_srodata+0x48>
    802004f8:	715000ef          	jal	8020140c <printk>

    test();
    802004fc:	01c000ef          	jal	80200518 <test>
    return 0;
    80200500:	00000793          	li	a5,0
}
    80200504:	00078513          	mv	a0,a5
    80200508:	00813083          	ld	ra,8(sp)
    8020050c:	00013403          	ld	s0,0(sp)
    80200510:	01010113          	addi	sp,sp,16
    80200514:	00008067          	ret

0000000080200518 <test>:
#include "sbi.h"
#include "defs.h"

void test() {
    80200518:	fd010113          	addi	sp,sp,-48
    8020051c:	02113423          	sd	ra,40(sp)
    80200520:	02813023          	sd	s0,32(sp)
    80200524:	03010413          	addi	s0,sp,48

    // uint64_t read_val = csr_read(sstatus);
    // printk("sstatus: 0x%lx\n", read_val);

    // 向 sscratch 寄存器写入数据
    uint64_t write_val = 0x12345678;
    80200528:	123457b7          	lui	a5,0x12345
    8020052c:	67878793          	addi	a5,a5,1656 # 12345678 <_skernel-0x6deba988>
    80200530:	fef43423          	sd	a5,-24(s0)
    csr_write(sscratch, write_val);
    80200534:	fe843783          	ld	a5,-24(s0)
    80200538:	fef43023          	sd	a5,-32(s0)
    8020053c:	fe043783          	ld	a5,-32(s0)
    80200540:	14079073          	csrw	sscratch,a5

    // 读取 sscratch 寄存器的值
    uint64_t read_val = csr_read(sscratch);
    80200544:	140027f3          	csrr	a5,sscratch
    80200548:	fcf43c23          	sd	a5,-40(s0)
    8020054c:	fd843783          	ld	a5,-40(s0)
    80200550:	fcf43823          	sd	a5,-48(s0)
    printk("sscratch: 0x%lx\n", read_val);
    80200554:	fd043583          	ld	a1,-48(s0)
    80200558:	00002517          	auipc	a0,0x2
    8020055c:	b0850513          	addi	a0,a0,-1272 # 80202060 <_srodata+0x60>
    80200560:	6ad000ef          	jal	8020140c <printk>

    return 0;
    80200564:	00000013          	nop

}
    80200568:	02813083          	ld	ra,40(sp)
    8020056c:	02013403          	ld	s0,32(sp)
    80200570:	03010113          	addi	sp,sp,48
    80200574:	00008067          	ret

0000000080200578 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200578:	fe010113          	addi	sp,sp,-32
    8020057c:	00113c23          	sd	ra,24(sp)
    80200580:	00813823          	sd	s0,16(sp)
    80200584:	02010413          	addi	s0,sp,32
    80200588:	00050793          	mv	a5,a0
    8020058c:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200590:	fec42783          	lw	a5,-20(s0)
    80200594:	0ff7f793          	zext.b	a5,a5
    80200598:	00078513          	mv	a0,a5
    8020059c:	cf9ff0ef          	jal	80200294 <sbi_debug_console_write_byte>
    return (char)c;
    802005a0:	fec42783          	lw	a5,-20(s0)
    802005a4:	0ff7f793          	zext.b	a5,a5
    802005a8:	0007879b          	sext.w	a5,a5
}
    802005ac:	00078513          	mv	a0,a5
    802005b0:	01813083          	ld	ra,24(sp)
    802005b4:	01013403          	ld	s0,16(sp)
    802005b8:	02010113          	addi	sp,sp,32
    802005bc:	00008067          	ret

00000000802005c0 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    802005c0:	fe010113          	addi	sp,sp,-32
    802005c4:	00813c23          	sd	s0,24(sp)
    802005c8:	02010413          	addi	s0,sp,32
    802005cc:	00050793          	mv	a5,a0
    802005d0:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    802005d4:	fec42783          	lw	a5,-20(s0)
    802005d8:	0007871b          	sext.w	a4,a5
    802005dc:	02000793          	li	a5,32
    802005e0:	02f70263          	beq	a4,a5,80200604 <isspace+0x44>
    802005e4:	fec42783          	lw	a5,-20(s0)
    802005e8:	0007871b          	sext.w	a4,a5
    802005ec:	00800793          	li	a5,8
    802005f0:	00e7de63          	bge	a5,a4,8020060c <isspace+0x4c>
    802005f4:	fec42783          	lw	a5,-20(s0)
    802005f8:	0007871b          	sext.w	a4,a5
    802005fc:	00d00793          	li	a5,13
    80200600:	00e7c663          	blt	a5,a4,8020060c <isspace+0x4c>
    80200604:	00100793          	li	a5,1
    80200608:	0080006f          	j	80200610 <isspace+0x50>
    8020060c:	00000793          	li	a5,0
}
    80200610:	00078513          	mv	a0,a5
    80200614:	01813403          	ld	s0,24(sp)
    80200618:	02010113          	addi	sp,sp,32
    8020061c:	00008067          	ret

0000000080200620 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200620:	fb010113          	addi	sp,sp,-80
    80200624:	04113423          	sd	ra,72(sp)
    80200628:	04813023          	sd	s0,64(sp)
    8020062c:	05010413          	addi	s0,sp,80
    80200630:	fca43423          	sd	a0,-56(s0)
    80200634:	fcb43023          	sd	a1,-64(s0)
    80200638:	00060793          	mv	a5,a2
    8020063c:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200640:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200644:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200648:	fc843783          	ld	a5,-56(s0)
    8020064c:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80200650:	0100006f          	j	80200660 <strtol+0x40>
        p++;
    80200654:	fd843783          	ld	a5,-40(s0)
    80200658:	00178793          	addi	a5,a5,1
    8020065c:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80200660:	fd843783          	ld	a5,-40(s0)
    80200664:	0007c783          	lbu	a5,0(a5)
    80200668:	0007879b          	sext.w	a5,a5
    8020066c:	00078513          	mv	a0,a5
    80200670:	f51ff0ef          	jal	802005c0 <isspace>
    80200674:	00050793          	mv	a5,a0
    80200678:	fc079ee3          	bnez	a5,80200654 <strtol+0x34>
    }

    if (*p == '-') {
    8020067c:	fd843783          	ld	a5,-40(s0)
    80200680:	0007c783          	lbu	a5,0(a5)
    80200684:	00078713          	mv	a4,a5
    80200688:	02d00793          	li	a5,45
    8020068c:	00f71e63          	bne	a4,a5,802006a8 <strtol+0x88>
        neg = true;
    80200690:	00100793          	li	a5,1
    80200694:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200698:	fd843783          	ld	a5,-40(s0)
    8020069c:	00178793          	addi	a5,a5,1
    802006a0:	fcf43c23          	sd	a5,-40(s0)
    802006a4:	0240006f          	j	802006c8 <strtol+0xa8>
    } else if (*p == '+') {
    802006a8:	fd843783          	ld	a5,-40(s0)
    802006ac:	0007c783          	lbu	a5,0(a5)
    802006b0:	00078713          	mv	a4,a5
    802006b4:	02b00793          	li	a5,43
    802006b8:	00f71863          	bne	a4,a5,802006c8 <strtol+0xa8>
        p++;
    802006bc:	fd843783          	ld	a5,-40(s0)
    802006c0:	00178793          	addi	a5,a5,1
    802006c4:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    802006c8:	fbc42783          	lw	a5,-68(s0)
    802006cc:	0007879b          	sext.w	a5,a5
    802006d0:	06079c63          	bnez	a5,80200748 <strtol+0x128>
        if (*p == '0') {
    802006d4:	fd843783          	ld	a5,-40(s0)
    802006d8:	0007c783          	lbu	a5,0(a5)
    802006dc:	00078713          	mv	a4,a5
    802006e0:	03000793          	li	a5,48
    802006e4:	04f71e63          	bne	a4,a5,80200740 <strtol+0x120>
            p++;
    802006e8:	fd843783          	ld	a5,-40(s0)
    802006ec:	00178793          	addi	a5,a5,1
    802006f0:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    802006f4:	fd843783          	ld	a5,-40(s0)
    802006f8:	0007c783          	lbu	a5,0(a5)
    802006fc:	00078713          	mv	a4,a5
    80200700:	07800793          	li	a5,120
    80200704:	00f70c63          	beq	a4,a5,8020071c <strtol+0xfc>
    80200708:	fd843783          	ld	a5,-40(s0)
    8020070c:	0007c783          	lbu	a5,0(a5)
    80200710:	00078713          	mv	a4,a5
    80200714:	05800793          	li	a5,88
    80200718:	00f71e63          	bne	a4,a5,80200734 <strtol+0x114>
                base = 16;
    8020071c:	01000793          	li	a5,16
    80200720:	faf42e23          	sw	a5,-68(s0)
                p++;
    80200724:	fd843783          	ld	a5,-40(s0)
    80200728:	00178793          	addi	a5,a5,1
    8020072c:	fcf43c23          	sd	a5,-40(s0)
    80200730:	0180006f          	j	80200748 <strtol+0x128>
            } else {
                base = 8;
    80200734:	00800793          	li	a5,8
    80200738:	faf42e23          	sw	a5,-68(s0)
    8020073c:	00c0006f          	j	80200748 <strtol+0x128>
            }
        } else {
            base = 10;
    80200740:	00a00793          	li	a5,10
    80200744:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200748:	fd843783          	ld	a5,-40(s0)
    8020074c:	0007c783          	lbu	a5,0(a5)
    80200750:	00078713          	mv	a4,a5
    80200754:	02f00793          	li	a5,47
    80200758:	02e7f863          	bgeu	a5,a4,80200788 <strtol+0x168>
    8020075c:	fd843783          	ld	a5,-40(s0)
    80200760:	0007c783          	lbu	a5,0(a5)
    80200764:	00078713          	mv	a4,a5
    80200768:	03900793          	li	a5,57
    8020076c:	00e7ee63          	bltu	a5,a4,80200788 <strtol+0x168>
            digit = *p - '0';
    80200770:	fd843783          	ld	a5,-40(s0)
    80200774:	0007c783          	lbu	a5,0(a5)
    80200778:	0007879b          	sext.w	a5,a5
    8020077c:	fd07879b          	addiw	a5,a5,-48
    80200780:	fcf42a23          	sw	a5,-44(s0)
    80200784:	0800006f          	j	80200804 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200788:	fd843783          	ld	a5,-40(s0)
    8020078c:	0007c783          	lbu	a5,0(a5)
    80200790:	00078713          	mv	a4,a5
    80200794:	06000793          	li	a5,96
    80200798:	02e7f863          	bgeu	a5,a4,802007c8 <strtol+0x1a8>
    8020079c:	fd843783          	ld	a5,-40(s0)
    802007a0:	0007c783          	lbu	a5,0(a5)
    802007a4:	00078713          	mv	a4,a5
    802007a8:	07a00793          	li	a5,122
    802007ac:	00e7ee63          	bltu	a5,a4,802007c8 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    802007b0:	fd843783          	ld	a5,-40(s0)
    802007b4:	0007c783          	lbu	a5,0(a5)
    802007b8:	0007879b          	sext.w	a5,a5
    802007bc:	fa97879b          	addiw	a5,a5,-87
    802007c0:	fcf42a23          	sw	a5,-44(s0)
    802007c4:	0400006f          	j	80200804 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    802007c8:	fd843783          	ld	a5,-40(s0)
    802007cc:	0007c783          	lbu	a5,0(a5)
    802007d0:	00078713          	mv	a4,a5
    802007d4:	04000793          	li	a5,64
    802007d8:	06e7f863          	bgeu	a5,a4,80200848 <strtol+0x228>
    802007dc:	fd843783          	ld	a5,-40(s0)
    802007e0:	0007c783          	lbu	a5,0(a5)
    802007e4:	00078713          	mv	a4,a5
    802007e8:	05a00793          	li	a5,90
    802007ec:	04e7ee63          	bltu	a5,a4,80200848 <strtol+0x228>
            digit = *p - ('A' - 10);
    802007f0:	fd843783          	ld	a5,-40(s0)
    802007f4:	0007c783          	lbu	a5,0(a5)
    802007f8:	0007879b          	sext.w	a5,a5
    802007fc:	fc97879b          	addiw	a5,a5,-55
    80200800:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    80200804:	fd442783          	lw	a5,-44(s0)
    80200808:	00078713          	mv	a4,a5
    8020080c:	fbc42783          	lw	a5,-68(s0)
    80200810:	0007071b          	sext.w	a4,a4
    80200814:	0007879b          	sext.w	a5,a5
    80200818:	02f75663          	bge	a4,a5,80200844 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    8020081c:	fbc42703          	lw	a4,-68(s0)
    80200820:	fe843783          	ld	a5,-24(s0)
    80200824:	02f70733          	mul	a4,a4,a5
    80200828:	fd442783          	lw	a5,-44(s0)
    8020082c:	00f707b3          	add	a5,a4,a5
    80200830:	fef43423          	sd	a5,-24(s0)
        p++;
    80200834:	fd843783          	ld	a5,-40(s0)
    80200838:	00178793          	addi	a5,a5,1
    8020083c:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    80200840:	f09ff06f          	j	80200748 <strtol+0x128>
            break;
    80200844:	00000013          	nop
    }

    if (endptr) {
    80200848:	fc043783          	ld	a5,-64(s0)
    8020084c:	00078863          	beqz	a5,8020085c <strtol+0x23c>
        *endptr = (char *)p;
    80200850:	fc043783          	ld	a5,-64(s0)
    80200854:	fd843703          	ld	a4,-40(s0)
    80200858:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    8020085c:	fe744783          	lbu	a5,-25(s0)
    80200860:	0ff7f793          	zext.b	a5,a5
    80200864:	00078863          	beqz	a5,80200874 <strtol+0x254>
    80200868:	fe843783          	ld	a5,-24(s0)
    8020086c:	40f007b3          	neg	a5,a5
    80200870:	0080006f          	j	80200878 <strtol+0x258>
    80200874:	fe843783          	ld	a5,-24(s0)
}
    80200878:	00078513          	mv	a0,a5
    8020087c:	04813083          	ld	ra,72(sp)
    80200880:	04013403          	ld	s0,64(sp)
    80200884:	05010113          	addi	sp,sp,80
    80200888:	00008067          	ret

000000008020088c <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    8020088c:	fd010113          	addi	sp,sp,-48
    80200890:	02113423          	sd	ra,40(sp)
    80200894:	02813023          	sd	s0,32(sp)
    80200898:	03010413          	addi	s0,sp,48
    8020089c:	fca43c23          	sd	a0,-40(s0)
    802008a0:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    802008a4:	fd043783          	ld	a5,-48(s0)
    802008a8:	00079863          	bnez	a5,802008b8 <puts_wo_nl+0x2c>
        s = "(null)";
    802008ac:	00001797          	auipc	a5,0x1
    802008b0:	7cc78793          	addi	a5,a5,1996 # 80202078 <_srodata+0x78>
    802008b4:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    802008b8:	fd043783          	ld	a5,-48(s0)
    802008bc:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    802008c0:	0240006f          	j	802008e4 <puts_wo_nl+0x58>
        putch(*p++);
    802008c4:	fe843783          	ld	a5,-24(s0)
    802008c8:	00178713          	addi	a4,a5,1
    802008cc:	fee43423          	sd	a4,-24(s0)
    802008d0:	0007c783          	lbu	a5,0(a5)
    802008d4:	0007871b          	sext.w	a4,a5
    802008d8:	fd843783          	ld	a5,-40(s0)
    802008dc:	00070513          	mv	a0,a4
    802008e0:	000780e7          	jalr	a5
    while (*p) {
    802008e4:	fe843783          	ld	a5,-24(s0)
    802008e8:	0007c783          	lbu	a5,0(a5)
    802008ec:	fc079ce3          	bnez	a5,802008c4 <puts_wo_nl+0x38>
    }
    return p - s;
    802008f0:	fe843703          	ld	a4,-24(s0)
    802008f4:	fd043783          	ld	a5,-48(s0)
    802008f8:	40f707b3          	sub	a5,a4,a5
    802008fc:	0007879b          	sext.w	a5,a5
}
    80200900:	00078513          	mv	a0,a5
    80200904:	02813083          	ld	ra,40(sp)
    80200908:	02013403          	ld	s0,32(sp)
    8020090c:	03010113          	addi	sp,sp,48
    80200910:	00008067          	ret

0000000080200914 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    80200914:	f9010113          	addi	sp,sp,-112
    80200918:	06113423          	sd	ra,104(sp)
    8020091c:	06813023          	sd	s0,96(sp)
    80200920:	07010413          	addi	s0,sp,112
    80200924:	faa43423          	sd	a0,-88(s0)
    80200928:	fab43023          	sd	a1,-96(s0)
    8020092c:	00060793          	mv	a5,a2
    80200930:	f8d43823          	sd	a3,-112(s0)
    80200934:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200938:	f9f44783          	lbu	a5,-97(s0)
    8020093c:	0ff7f793          	zext.b	a5,a5
    80200940:	02078663          	beqz	a5,8020096c <print_dec_int+0x58>
    80200944:	fa043703          	ld	a4,-96(s0)
    80200948:	fff00793          	li	a5,-1
    8020094c:	03f79793          	slli	a5,a5,0x3f
    80200950:	00f71e63          	bne	a4,a5,8020096c <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80200954:	00001597          	auipc	a1,0x1
    80200958:	72c58593          	addi	a1,a1,1836 # 80202080 <_srodata+0x80>
    8020095c:	fa843503          	ld	a0,-88(s0)
    80200960:	f2dff0ef          	jal	8020088c <puts_wo_nl>
    80200964:	00050793          	mv	a5,a0
    80200968:	2a00006f          	j	80200c08 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    8020096c:	f9043783          	ld	a5,-112(s0)
    80200970:	00c7a783          	lw	a5,12(a5)
    80200974:	00079a63          	bnez	a5,80200988 <print_dec_int+0x74>
    80200978:	fa043783          	ld	a5,-96(s0)
    8020097c:	00079663          	bnez	a5,80200988 <print_dec_int+0x74>
        return 0;
    80200980:	00000793          	li	a5,0
    80200984:	2840006f          	j	80200c08 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200988:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    8020098c:	f9f44783          	lbu	a5,-97(s0)
    80200990:	0ff7f793          	zext.b	a5,a5
    80200994:	02078063          	beqz	a5,802009b4 <print_dec_int+0xa0>
    80200998:	fa043783          	ld	a5,-96(s0)
    8020099c:	0007dc63          	bgez	a5,802009b4 <print_dec_int+0xa0>
        neg = true;
    802009a0:	00100793          	li	a5,1
    802009a4:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    802009a8:	fa043783          	ld	a5,-96(s0)
    802009ac:	40f007b3          	neg	a5,a5
    802009b0:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    802009b4:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    802009b8:	f9f44783          	lbu	a5,-97(s0)
    802009bc:	0ff7f793          	zext.b	a5,a5
    802009c0:	02078863          	beqz	a5,802009f0 <print_dec_int+0xdc>
    802009c4:	fef44783          	lbu	a5,-17(s0)
    802009c8:	0ff7f793          	zext.b	a5,a5
    802009cc:	00079e63          	bnez	a5,802009e8 <print_dec_int+0xd4>
    802009d0:	f9043783          	ld	a5,-112(s0)
    802009d4:	0057c783          	lbu	a5,5(a5)
    802009d8:	00079863          	bnez	a5,802009e8 <print_dec_int+0xd4>
    802009dc:	f9043783          	ld	a5,-112(s0)
    802009e0:	0047c783          	lbu	a5,4(a5)
    802009e4:	00078663          	beqz	a5,802009f0 <print_dec_int+0xdc>
    802009e8:	00100793          	li	a5,1
    802009ec:	0080006f          	j	802009f4 <print_dec_int+0xe0>
    802009f0:	00000793          	li	a5,0
    802009f4:	fcf40ba3          	sb	a5,-41(s0)
    802009f8:	fd744783          	lbu	a5,-41(s0)
    802009fc:	0017f793          	andi	a5,a5,1
    80200a00:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200a04:	fa043703          	ld	a4,-96(s0)
    80200a08:	00a00793          	li	a5,10
    80200a0c:	02f777b3          	remu	a5,a4,a5
    80200a10:	0ff7f713          	zext.b	a4,a5
    80200a14:	fe842783          	lw	a5,-24(s0)
    80200a18:	0017869b          	addiw	a3,a5,1
    80200a1c:	fed42423          	sw	a3,-24(s0)
    80200a20:	0307071b          	addiw	a4,a4,48
    80200a24:	0ff77713          	zext.b	a4,a4
    80200a28:	ff078793          	addi	a5,a5,-16
    80200a2c:	008787b3          	add	a5,a5,s0
    80200a30:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200a34:	fa043703          	ld	a4,-96(s0)
    80200a38:	00a00793          	li	a5,10
    80200a3c:	02f757b3          	divu	a5,a4,a5
    80200a40:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200a44:	fa043783          	ld	a5,-96(s0)
    80200a48:	fa079ee3          	bnez	a5,80200a04 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200a4c:	f9043783          	ld	a5,-112(s0)
    80200a50:	00c7a783          	lw	a5,12(a5)
    80200a54:	00078713          	mv	a4,a5
    80200a58:	fff00793          	li	a5,-1
    80200a5c:	02f71063          	bne	a4,a5,80200a7c <print_dec_int+0x168>
    80200a60:	f9043783          	ld	a5,-112(s0)
    80200a64:	0037c783          	lbu	a5,3(a5)
    80200a68:	00078a63          	beqz	a5,80200a7c <print_dec_int+0x168>
        flags->prec = flags->width;
    80200a6c:	f9043783          	ld	a5,-112(s0)
    80200a70:	0087a703          	lw	a4,8(a5)
    80200a74:	f9043783          	ld	a5,-112(s0)
    80200a78:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200a7c:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200a80:	f9043783          	ld	a5,-112(s0)
    80200a84:	0087a703          	lw	a4,8(a5)
    80200a88:	fe842783          	lw	a5,-24(s0)
    80200a8c:	fcf42823          	sw	a5,-48(s0)
    80200a90:	f9043783          	ld	a5,-112(s0)
    80200a94:	00c7a783          	lw	a5,12(a5)
    80200a98:	fcf42623          	sw	a5,-52(s0)
    80200a9c:	fd042783          	lw	a5,-48(s0)
    80200aa0:	00078593          	mv	a1,a5
    80200aa4:	fcc42783          	lw	a5,-52(s0)
    80200aa8:	00078613          	mv	a2,a5
    80200aac:	0006069b          	sext.w	a3,a2
    80200ab0:	0005879b          	sext.w	a5,a1
    80200ab4:	00f6d463          	bge	a3,a5,80200abc <print_dec_int+0x1a8>
    80200ab8:	00058613          	mv	a2,a1
    80200abc:	0006079b          	sext.w	a5,a2
    80200ac0:	40f707bb          	subw	a5,a4,a5
    80200ac4:	0007871b          	sext.w	a4,a5
    80200ac8:	fd744783          	lbu	a5,-41(s0)
    80200acc:	0007879b          	sext.w	a5,a5
    80200ad0:	40f707bb          	subw	a5,a4,a5
    80200ad4:	fef42023          	sw	a5,-32(s0)
    80200ad8:	0280006f          	j	80200b00 <print_dec_int+0x1ec>
        putch(' ');
    80200adc:	fa843783          	ld	a5,-88(s0)
    80200ae0:	02000513          	li	a0,32
    80200ae4:	000780e7          	jalr	a5
        ++written;
    80200ae8:	fe442783          	lw	a5,-28(s0)
    80200aec:	0017879b          	addiw	a5,a5,1
    80200af0:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200af4:	fe042783          	lw	a5,-32(s0)
    80200af8:	fff7879b          	addiw	a5,a5,-1
    80200afc:	fef42023          	sw	a5,-32(s0)
    80200b00:	fe042783          	lw	a5,-32(s0)
    80200b04:	0007879b          	sext.w	a5,a5
    80200b08:	fcf04ae3          	bgtz	a5,80200adc <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200b0c:	fd744783          	lbu	a5,-41(s0)
    80200b10:	0ff7f793          	zext.b	a5,a5
    80200b14:	04078463          	beqz	a5,80200b5c <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200b18:	fef44783          	lbu	a5,-17(s0)
    80200b1c:	0ff7f793          	zext.b	a5,a5
    80200b20:	00078663          	beqz	a5,80200b2c <print_dec_int+0x218>
    80200b24:	02d00793          	li	a5,45
    80200b28:	01c0006f          	j	80200b44 <print_dec_int+0x230>
    80200b2c:	f9043783          	ld	a5,-112(s0)
    80200b30:	0057c783          	lbu	a5,5(a5)
    80200b34:	00078663          	beqz	a5,80200b40 <print_dec_int+0x22c>
    80200b38:	02b00793          	li	a5,43
    80200b3c:	0080006f          	j	80200b44 <print_dec_int+0x230>
    80200b40:	02000793          	li	a5,32
    80200b44:	fa843703          	ld	a4,-88(s0)
    80200b48:	00078513          	mv	a0,a5
    80200b4c:	000700e7          	jalr	a4
        ++written;
    80200b50:	fe442783          	lw	a5,-28(s0)
    80200b54:	0017879b          	addiw	a5,a5,1
    80200b58:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200b5c:	fe842783          	lw	a5,-24(s0)
    80200b60:	fcf42e23          	sw	a5,-36(s0)
    80200b64:	0280006f          	j	80200b8c <print_dec_int+0x278>
        putch('0');
    80200b68:	fa843783          	ld	a5,-88(s0)
    80200b6c:	03000513          	li	a0,48
    80200b70:	000780e7          	jalr	a5
        ++written;
    80200b74:	fe442783          	lw	a5,-28(s0)
    80200b78:	0017879b          	addiw	a5,a5,1
    80200b7c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200b80:	fdc42783          	lw	a5,-36(s0)
    80200b84:	0017879b          	addiw	a5,a5,1
    80200b88:	fcf42e23          	sw	a5,-36(s0)
    80200b8c:	f9043783          	ld	a5,-112(s0)
    80200b90:	00c7a703          	lw	a4,12(a5)
    80200b94:	fd744783          	lbu	a5,-41(s0)
    80200b98:	0007879b          	sext.w	a5,a5
    80200b9c:	40f707bb          	subw	a5,a4,a5
    80200ba0:	0007871b          	sext.w	a4,a5
    80200ba4:	fdc42783          	lw	a5,-36(s0)
    80200ba8:	0007879b          	sext.w	a5,a5
    80200bac:	fae7cee3          	blt	a5,a4,80200b68 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200bb0:	fe842783          	lw	a5,-24(s0)
    80200bb4:	fff7879b          	addiw	a5,a5,-1
    80200bb8:	fcf42c23          	sw	a5,-40(s0)
    80200bbc:	03c0006f          	j	80200bf8 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200bc0:	fd842783          	lw	a5,-40(s0)
    80200bc4:	ff078793          	addi	a5,a5,-16
    80200bc8:	008787b3          	add	a5,a5,s0
    80200bcc:	fc87c783          	lbu	a5,-56(a5)
    80200bd0:	0007871b          	sext.w	a4,a5
    80200bd4:	fa843783          	ld	a5,-88(s0)
    80200bd8:	00070513          	mv	a0,a4
    80200bdc:	000780e7          	jalr	a5
        ++written;
    80200be0:	fe442783          	lw	a5,-28(s0)
    80200be4:	0017879b          	addiw	a5,a5,1
    80200be8:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200bec:	fd842783          	lw	a5,-40(s0)
    80200bf0:	fff7879b          	addiw	a5,a5,-1
    80200bf4:	fcf42c23          	sw	a5,-40(s0)
    80200bf8:	fd842783          	lw	a5,-40(s0)
    80200bfc:	0007879b          	sext.w	a5,a5
    80200c00:	fc07d0e3          	bgez	a5,80200bc0 <print_dec_int+0x2ac>
    }

    return written;
    80200c04:	fe442783          	lw	a5,-28(s0)
}
    80200c08:	00078513          	mv	a0,a5
    80200c0c:	06813083          	ld	ra,104(sp)
    80200c10:	06013403          	ld	s0,96(sp)
    80200c14:	07010113          	addi	sp,sp,112
    80200c18:	00008067          	ret

0000000080200c1c <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200c1c:	f4010113          	addi	sp,sp,-192
    80200c20:	0a113c23          	sd	ra,184(sp)
    80200c24:	0a813823          	sd	s0,176(sp)
    80200c28:	0c010413          	addi	s0,sp,192
    80200c2c:	f4a43c23          	sd	a0,-168(s0)
    80200c30:	f4b43823          	sd	a1,-176(s0)
    80200c34:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200c38:	f8043023          	sd	zero,-128(s0)
    80200c3c:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200c40:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200c44:	7a40006f          	j	802013e8 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200c48:	f8044783          	lbu	a5,-128(s0)
    80200c4c:	72078e63          	beqz	a5,80201388 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200c50:	f5043783          	ld	a5,-176(s0)
    80200c54:	0007c783          	lbu	a5,0(a5)
    80200c58:	00078713          	mv	a4,a5
    80200c5c:	02300793          	li	a5,35
    80200c60:	00f71863          	bne	a4,a5,80200c70 <vprintfmt+0x54>
                flags.sharpflag = true;
    80200c64:	00100793          	li	a5,1
    80200c68:	f8f40123          	sb	a5,-126(s0)
    80200c6c:	7700006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200c70:	f5043783          	ld	a5,-176(s0)
    80200c74:	0007c783          	lbu	a5,0(a5)
    80200c78:	00078713          	mv	a4,a5
    80200c7c:	03000793          	li	a5,48
    80200c80:	00f71863          	bne	a4,a5,80200c90 <vprintfmt+0x74>
                flags.zeroflag = true;
    80200c84:	00100793          	li	a5,1
    80200c88:	f8f401a3          	sb	a5,-125(s0)
    80200c8c:	7500006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200c90:	f5043783          	ld	a5,-176(s0)
    80200c94:	0007c783          	lbu	a5,0(a5)
    80200c98:	00078713          	mv	a4,a5
    80200c9c:	06c00793          	li	a5,108
    80200ca0:	04f70063          	beq	a4,a5,80200ce0 <vprintfmt+0xc4>
    80200ca4:	f5043783          	ld	a5,-176(s0)
    80200ca8:	0007c783          	lbu	a5,0(a5)
    80200cac:	00078713          	mv	a4,a5
    80200cb0:	07a00793          	li	a5,122
    80200cb4:	02f70663          	beq	a4,a5,80200ce0 <vprintfmt+0xc4>
    80200cb8:	f5043783          	ld	a5,-176(s0)
    80200cbc:	0007c783          	lbu	a5,0(a5)
    80200cc0:	00078713          	mv	a4,a5
    80200cc4:	07400793          	li	a5,116
    80200cc8:	00f70c63          	beq	a4,a5,80200ce0 <vprintfmt+0xc4>
    80200ccc:	f5043783          	ld	a5,-176(s0)
    80200cd0:	0007c783          	lbu	a5,0(a5)
    80200cd4:	00078713          	mv	a4,a5
    80200cd8:	06a00793          	li	a5,106
    80200cdc:	00f71863          	bne	a4,a5,80200cec <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200ce0:	00100793          	li	a5,1
    80200ce4:	f8f400a3          	sb	a5,-127(s0)
    80200ce8:	6f40006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200cec:	f5043783          	ld	a5,-176(s0)
    80200cf0:	0007c783          	lbu	a5,0(a5)
    80200cf4:	00078713          	mv	a4,a5
    80200cf8:	02b00793          	li	a5,43
    80200cfc:	00f71863          	bne	a4,a5,80200d0c <vprintfmt+0xf0>
                flags.sign = true;
    80200d00:	00100793          	li	a5,1
    80200d04:	f8f402a3          	sb	a5,-123(s0)
    80200d08:	6d40006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200d0c:	f5043783          	ld	a5,-176(s0)
    80200d10:	0007c783          	lbu	a5,0(a5)
    80200d14:	00078713          	mv	a4,a5
    80200d18:	02000793          	li	a5,32
    80200d1c:	00f71863          	bne	a4,a5,80200d2c <vprintfmt+0x110>
                flags.spaceflag = true;
    80200d20:	00100793          	li	a5,1
    80200d24:	f8f40223          	sb	a5,-124(s0)
    80200d28:	6b40006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200d2c:	f5043783          	ld	a5,-176(s0)
    80200d30:	0007c783          	lbu	a5,0(a5)
    80200d34:	00078713          	mv	a4,a5
    80200d38:	02a00793          	li	a5,42
    80200d3c:	00f71e63          	bne	a4,a5,80200d58 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200d40:	f4843783          	ld	a5,-184(s0)
    80200d44:	00878713          	addi	a4,a5,8
    80200d48:	f4e43423          	sd	a4,-184(s0)
    80200d4c:	0007a783          	lw	a5,0(a5)
    80200d50:	f8f42423          	sw	a5,-120(s0)
    80200d54:	6880006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200d58:	f5043783          	ld	a5,-176(s0)
    80200d5c:	0007c783          	lbu	a5,0(a5)
    80200d60:	00078713          	mv	a4,a5
    80200d64:	03000793          	li	a5,48
    80200d68:	04e7f663          	bgeu	a5,a4,80200db4 <vprintfmt+0x198>
    80200d6c:	f5043783          	ld	a5,-176(s0)
    80200d70:	0007c783          	lbu	a5,0(a5)
    80200d74:	00078713          	mv	a4,a5
    80200d78:	03900793          	li	a5,57
    80200d7c:	02e7ec63          	bltu	a5,a4,80200db4 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200d80:	f5043783          	ld	a5,-176(s0)
    80200d84:	f5040713          	addi	a4,s0,-176
    80200d88:	00a00613          	li	a2,10
    80200d8c:	00070593          	mv	a1,a4
    80200d90:	00078513          	mv	a0,a5
    80200d94:	88dff0ef          	jal	80200620 <strtol>
    80200d98:	00050793          	mv	a5,a0
    80200d9c:	0007879b          	sext.w	a5,a5
    80200da0:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200da4:	f5043783          	ld	a5,-176(s0)
    80200da8:	fff78793          	addi	a5,a5,-1
    80200dac:	f4f43823          	sd	a5,-176(s0)
    80200db0:	62c0006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200db4:	f5043783          	ld	a5,-176(s0)
    80200db8:	0007c783          	lbu	a5,0(a5)
    80200dbc:	00078713          	mv	a4,a5
    80200dc0:	02e00793          	li	a5,46
    80200dc4:	06f71863          	bne	a4,a5,80200e34 <vprintfmt+0x218>
                fmt++;
    80200dc8:	f5043783          	ld	a5,-176(s0)
    80200dcc:	00178793          	addi	a5,a5,1
    80200dd0:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200dd4:	f5043783          	ld	a5,-176(s0)
    80200dd8:	0007c783          	lbu	a5,0(a5)
    80200ddc:	00078713          	mv	a4,a5
    80200de0:	02a00793          	li	a5,42
    80200de4:	00f71e63          	bne	a4,a5,80200e00 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200de8:	f4843783          	ld	a5,-184(s0)
    80200dec:	00878713          	addi	a4,a5,8
    80200df0:	f4e43423          	sd	a4,-184(s0)
    80200df4:	0007a783          	lw	a5,0(a5)
    80200df8:	f8f42623          	sw	a5,-116(s0)
    80200dfc:	5e00006f          	j	802013dc <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200e00:	f5043783          	ld	a5,-176(s0)
    80200e04:	f5040713          	addi	a4,s0,-176
    80200e08:	00a00613          	li	a2,10
    80200e0c:	00070593          	mv	a1,a4
    80200e10:	00078513          	mv	a0,a5
    80200e14:	80dff0ef          	jal	80200620 <strtol>
    80200e18:	00050793          	mv	a5,a0
    80200e1c:	0007879b          	sext.w	a5,a5
    80200e20:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200e24:	f5043783          	ld	a5,-176(s0)
    80200e28:	fff78793          	addi	a5,a5,-1
    80200e2c:	f4f43823          	sd	a5,-176(s0)
    80200e30:	5ac0006f          	j	802013dc <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200e34:	f5043783          	ld	a5,-176(s0)
    80200e38:	0007c783          	lbu	a5,0(a5)
    80200e3c:	00078713          	mv	a4,a5
    80200e40:	07800793          	li	a5,120
    80200e44:	02f70663          	beq	a4,a5,80200e70 <vprintfmt+0x254>
    80200e48:	f5043783          	ld	a5,-176(s0)
    80200e4c:	0007c783          	lbu	a5,0(a5)
    80200e50:	00078713          	mv	a4,a5
    80200e54:	05800793          	li	a5,88
    80200e58:	00f70c63          	beq	a4,a5,80200e70 <vprintfmt+0x254>
    80200e5c:	f5043783          	ld	a5,-176(s0)
    80200e60:	0007c783          	lbu	a5,0(a5)
    80200e64:	00078713          	mv	a4,a5
    80200e68:	07000793          	li	a5,112
    80200e6c:	30f71263          	bne	a4,a5,80201170 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200e70:	f5043783          	ld	a5,-176(s0)
    80200e74:	0007c783          	lbu	a5,0(a5)
    80200e78:	00078713          	mv	a4,a5
    80200e7c:	07000793          	li	a5,112
    80200e80:	00f70663          	beq	a4,a5,80200e8c <vprintfmt+0x270>
    80200e84:	f8144783          	lbu	a5,-127(s0)
    80200e88:	00078663          	beqz	a5,80200e94 <vprintfmt+0x278>
    80200e8c:	00100793          	li	a5,1
    80200e90:	0080006f          	j	80200e98 <vprintfmt+0x27c>
    80200e94:	00000793          	li	a5,0
    80200e98:	faf403a3          	sb	a5,-89(s0)
    80200e9c:	fa744783          	lbu	a5,-89(s0)
    80200ea0:	0017f793          	andi	a5,a5,1
    80200ea4:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200ea8:	fa744783          	lbu	a5,-89(s0)
    80200eac:	0ff7f793          	zext.b	a5,a5
    80200eb0:	00078c63          	beqz	a5,80200ec8 <vprintfmt+0x2ac>
    80200eb4:	f4843783          	ld	a5,-184(s0)
    80200eb8:	00878713          	addi	a4,a5,8
    80200ebc:	f4e43423          	sd	a4,-184(s0)
    80200ec0:	0007b783          	ld	a5,0(a5)
    80200ec4:	01c0006f          	j	80200ee0 <vprintfmt+0x2c4>
    80200ec8:	f4843783          	ld	a5,-184(s0)
    80200ecc:	00878713          	addi	a4,a5,8
    80200ed0:	f4e43423          	sd	a4,-184(s0)
    80200ed4:	0007a783          	lw	a5,0(a5)
    80200ed8:	02079793          	slli	a5,a5,0x20
    80200edc:	0207d793          	srli	a5,a5,0x20
    80200ee0:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200ee4:	f8c42783          	lw	a5,-116(s0)
    80200ee8:	02079463          	bnez	a5,80200f10 <vprintfmt+0x2f4>
    80200eec:	fe043783          	ld	a5,-32(s0)
    80200ef0:	02079063          	bnez	a5,80200f10 <vprintfmt+0x2f4>
    80200ef4:	f5043783          	ld	a5,-176(s0)
    80200ef8:	0007c783          	lbu	a5,0(a5)
    80200efc:	00078713          	mv	a4,a5
    80200f00:	07000793          	li	a5,112
    80200f04:	00f70663          	beq	a4,a5,80200f10 <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200f08:	f8040023          	sb	zero,-128(s0)
    80200f0c:	4d00006f          	j	802013dc <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200f10:	f5043783          	ld	a5,-176(s0)
    80200f14:	0007c783          	lbu	a5,0(a5)
    80200f18:	00078713          	mv	a4,a5
    80200f1c:	07000793          	li	a5,112
    80200f20:	00f70a63          	beq	a4,a5,80200f34 <vprintfmt+0x318>
    80200f24:	f8244783          	lbu	a5,-126(s0)
    80200f28:	00078a63          	beqz	a5,80200f3c <vprintfmt+0x320>
    80200f2c:	fe043783          	ld	a5,-32(s0)
    80200f30:	00078663          	beqz	a5,80200f3c <vprintfmt+0x320>
    80200f34:	00100793          	li	a5,1
    80200f38:	0080006f          	j	80200f40 <vprintfmt+0x324>
    80200f3c:	00000793          	li	a5,0
    80200f40:	faf40323          	sb	a5,-90(s0)
    80200f44:	fa644783          	lbu	a5,-90(s0)
    80200f48:	0017f793          	andi	a5,a5,1
    80200f4c:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80200f50:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80200f54:	f5043783          	ld	a5,-176(s0)
    80200f58:	0007c783          	lbu	a5,0(a5)
    80200f5c:	00078713          	mv	a4,a5
    80200f60:	05800793          	li	a5,88
    80200f64:	00f71863          	bne	a4,a5,80200f74 <vprintfmt+0x358>
    80200f68:	00001797          	auipc	a5,0x1
    80200f6c:	13078793          	addi	a5,a5,304 # 80202098 <upperxdigits.1>
    80200f70:	00c0006f          	j	80200f7c <vprintfmt+0x360>
    80200f74:	00001797          	auipc	a5,0x1
    80200f78:	13c78793          	addi	a5,a5,316 # 802020b0 <lowerxdigits.0>
    80200f7c:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80200f80:	fe043783          	ld	a5,-32(s0)
    80200f84:	00f7f793          	andi	a5,a5,15
    80200f88:	f9843703          	ld	a4,-104(s0)
    80200f8c:	00f70733          	add	a4,a4,a5
    80200f90:	fdc42783          	lw	a5,-36(s0)
    80200f94:	0017869b          	addiw	a3,a5,1
    80200f98:	fcd42e23          	sw	a3,-36(s0)
    80200f9c:	00074703          	lbu	a4,0(a4)
    80200fa0:	ff078793          	addi	a5,a5,-16
    80200fa4:	008787b3          	add	a5,a5,s0
    80200fa8:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80200fac:	fe043783          	ld	a5,-32(s0)
    80200fb0:	0047d793          	srli	a5,a5,0x4
    80200fb4:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80200fb8:	fe043783          	ld	a5,-32(s0)
    80200fbc:	fc0792e3          	bnez	a5,80200f80 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80200fc0:	f8c42783          	lw	a5,-116(s0)
    80200fc4:	00078713          	mv	a4,a5
    80200fc8:	fff00793          	li	a5,-1
    80200fcc:	02f71663          	bne	a4,a5,80200ff8 <vprintfmt+0x3dc>
    80200fd0:	f8344783          	lbu	a5,-125(s0)
    80200fd4:	02078263          	beqz	a5,80200ff8 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80200fd8:	f8842703          	lw	a4,-120(s0)
    80200fdc:	fa644783          	lbu	a5,-90(s0)
    80200fe0:	0007879b          	sext.w	a5,a5
    80200fe4:	0017979b          	slliw	a5,a5,0x1
    80200fe8:	0007879b          	sext.w	a5,a5
    80200fec:	40f707bb          	subw	a5,a4,a5
    80200ff0:	0007879b          	sext.w	a5,a5
    80200ff4:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80200ff8:	f8842703          	lw	a4,-120(s0)
    80200ffc:	fa644783          	lbu	a5,-90(s0)
    80201000:	0007879b          	sext.w	a5,a5
    80201004:	0017979b          	slliw	a5,a5,0x1
    80201008:	0007879b          	sext.w	a5,a5
    8020100c:	40f707bb          	subw	a5,a4,a5
    80201010:	0007871b          	sext.w	a4,a5
    80201014:	fdc42783          	lw	a5,-36(s0)
    80201018:	f8f42a23          	sw	a5,-108(s0)
    8020101c:	f8c42783          	lw	a5,-116(s0)
    80201020:	f8f42823          	sw	a5,-112(s0)
    80201024:	f9442783          	lw	a5,-108(s0)
    80201028:	00078593          	mv	a1,a5
    8020102c:	f9042783          	lw	a5,-112(s0)
    80201030:	00078613          	mv	a2,a5
    80201034:	0006069b          	sext.w	a3,a2
    80201038:	0005879b          	sext.w	a5,a1
    8020103c:	00f6d463          	bge	a3,a5,80201044 <vprintfmt+0x428>
    80201040:	00058613          	mv	a2,a1
    80201044:	0006079b          	sext.w	a5,a2
    80201048:	40f707bb          	subw	a5,a4,a5
    8020104c:	fcf42c23          	sw	a5,-40(s0)
    80201050:	0280006f          	j	80201078 <vprintfmt+0x45c>
                    putch(' ');
    80201054:	f5843783          	ld	a5,-168(s0)
    80201058:	02000513          	li	a0,32
    8020105c:	000780e7          	jalr	a5
                    ++written;
    80201060:	fec42783          	lw	a5,-20(s0)
    80201064:	0017879b          	addiw	a5,a5,1
    80201068:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    8020106c:	fd842783          	lw	a5,-40(s0)
    80201070:	fff7879b          	addiw	a5,a5,-1
    80201074:	fcf42c23          	sw	a5,-40(s0)
    80201078:	fd842783          	lw	a5,-40(s0)
    8020107c:	0007879b          	sext.w	a5,a5
    80201080:	fcf04ae3          	bgtz	a5,80201054 <vprintfmt+0x438>
                }

                if (prefix) {
    80201084:	fa644783          	lbu	a5,-90(s0)
    80201088:	0ff7f793          	zext.b	a5,a5
    8020108c:	04078463          	beqz	a5,802010d4 <vprintfmt+0x4b8>
                    putch('0');
    80201090:	f5843783          	ld	a5,-168(s0)
    80201094:	03000513          	li	a0,48
    80201098:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    8020109c:	f5043783          	ld	a5,-176(s0)
    802010a0:	0007c783          	lbu	a5,0(a5)
    802010a4:	00078713          	mv	a4,a5
    802010a8:	05800793          	li	a5,88
    802010ac:	00f71663          	bne	a4,a5,802010b8 <vprintfmt+0x49c>
    802010b0:	05800793          	li	a5,88
    802010b4:	0080006f          	j	802010bc <vprintfmt+0x4a0>
    802010b8:	07800793          	li	a5,120
    802010bc:	f5843703          	ld	a4,-168(s0)
    802010c0:	00078513          	mv	a0,a5
    802010c4:	000700e7          	jalr	a4
                    written += 2;
    802010c8:	fec42783          	lw	a5,-20(s0)
    802010cc:	0027879b          	addiw	a5,a5,2
    802010d0:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    802010d4:	fdc42783          	lw	a5,-36(s0)
    802010d8:	fcf42a23          	sw	a5,-44(s0)
    802010dc:	0280006f          	j	80201104 <vprintfmt+0x4e8>
                    putch('0');
    802010e0:	f5843783          	ld	a5,-168(s0)
    802010e4:	03000513          	li	a0,48
    802010e8:	000780e7          	jalr	a5
                    ++written;
    802010ec:	fec42783          	lw	a5,-20(s0)
    802010f0:	0017879b          	addiw	a5,a5,1
    802010f4:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    802010f8:	fd442783          	lw	a5,-44(s0)
    802010fc:	0017879b          	addiw	a5,a5,1
    80201100:	fcf42a23          	sw	a5,-44(s0)
    80201104:	f8c42703          	lw	a4,-116(s0)
    80201108:	fd442783          	lw	a5,-44(s0)
    8020110c:	0007879b          	sext.w	a5,a5
    80201110:	fce7c8e3          	blt	a5,a4,802010e0 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201114:	fdc42783          	lw	a5,-36(s0)
    80201118:	fff7879b          	addiw	a5,a5,-1
    8020111c:	fcf42823          	sw	a5,-48(s0)
    80201120:	03c0006f          	j	8020115c <vprintfmt+0x540>
                    putch(buf[i]);
    80201124:	fd042783          	lw	a5,-48(s0)
    80201128:	ff078793          	addi	a5,a5,-16
    8020112c:	008787b3          	add	a5,a5,s0
    80201130:	f807c783          	lbu	a5,-128(a5)
    80201134:	0007871b          	sext.w	a4,a5
    80201138:	f5843783          	ld	a5,-168(s0)
    8020113c:	00070513          	mv	a0,a4
    80201140:	000780e7          	jalr	a5
                    ++written;
    80201144:	fec42783          	lw	a5,-20(s0)
    80201148:	0017879b          	addiw	a5,a5,1
    8020114c:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201150:	fd042783          	lw	a5,-48(s0)
    80201154:	fff7879b          	addiw	a5,a5,-1
    80201158:	fcf42823          	sw	a5,-48(s0)
    8020115c:	fd042783          	lw	a5,-48(s0)
    80201160:	0007879b          	sext.w	a5,a5
    80201164:	fc07d0e3          	bgez	a5,80201124 <vprintfmt+0x508>
                }

                flags.in_format = false;
    80201168:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    8020116c:	2700006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201170:	f5043783          	ld	a5,-176(s0)
    80201174:	0007c783          	lbu	a5,0(a5)
    80201178:	00078713          	mv	a4,a5
    8020117c:	06400793          	li	a5,100
    80201180:	02f70663          	beq	a4,a5,802011ac <vprintfmt+0x590>
    80201184:	f5043783          	ld	a5,-176(s0)
    80201188:	0007c783          	lbu	a5,0(a5)
    8020118c:	00078713          	mv	a4,a5
    80201190:	06900793          	li	a5,105
    80201194:	00f70c63          	beq	a4,a5,802011ac <vprintfmt+0x590>
    80201198:	f5043783          	ld	a5,-176(s0)
    8020119c:	0007c783          	lbu	a5,0(a5)
    802011a0:	00078713          	mv	a4,a5
    802011a4:	07500793          	li	a5,117
    802011a8:	08f71063          	bne	a4,a5,80201228 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    802011ac:	f8144783          	lbu	a5,-127(s0)
    802011b0:	00078c63          	beqz	a5,802011c8 <vprintfmt+0x5ac>
    802011b4:	f4843783          	ld	a5,-184(s0)
    802011b8:	00878713          	addi	a4,a5,8
    802011bc:	f4e43423          	sd	a4,-184(s0)
    802011c0:	0007b783          	ld	a5,0(a5)
    802011c4:	0140006f          	j	802011d8 <vprintfmt+0x5bc>
    802011c8:	f4843783          	ld	a5,-184(s0)
    802011cc:	00878713          	addi	a4,a5,8
    802011d0:	f4e43423          	sd	a4,-184(s0)
    802011d4:	0007a783          	lw	a5,0(a5)
    802011d8:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    802011dc:	fa843583          	ld	a1,-88(s0)
    802011e0:	f5043783          	ld	a5,-176(s0)
    802011e4:	0007c783          	lbu	a5,0(a5)
    802011e8:	0007871b          	sext.w	a4,a5
    802011ec:	07500793          	li	a5,117
    802011f0:	40f707b3          	sub	a5,a4,a5
    802011f4:	00f037b3          	snez	a5,a5
    802011f8:	0ff7f793          	zext.b	a5,a5
    802011fc:	f8040713          	addi	a4,s0,-128
    80201200:	00070693          	mv	a3,a4
    80201204:	00078613          	mv	a2,a5
    80201208:	f5843503          	ld	a0,-168(s0)
    8020120c:	f08ff0ef          	jal	80200914 <print_dec_int>
    80201210:	00050793          	mv	a5,a0
    80201214:	fec42703          	lw	a4,-20(s0)
    80201218:	00f707bb          	addw	a5,a4,a5
    8020121c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201220:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201224:	1b80006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201228:	f5043783          	ld	a5,-176(s0)
    8020122c:	0007c783          	lbu	a5,0(a5)
    80201230:	00078713          	mv	a4,a5
    80201234:	06e00793          	li	a5,110
    80201238:	04f71c63          	bne	a4,a5,80201290 <vprintfmt+0x674>
                if (flags.longflag) {
    8020123c:	f8144783          	lbu	a5,-127(s0)
    80201240:	02078463          	beqz	a5,80201268 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201244:	f4843783          	ld	a5,-184(s0)
    80201248:	00878713          	addi	a4,a5,8
    8020124c:	f4e43423          	sd	a4,-184(s0)
    80201250:	0007b783          	ld	a5,0(a5)
    80201254:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201258:	fec42703          	lw	a4,-20(s0)
    8020125c:	fb043783          	ld	a5,-80(s0)
    80201260:	00e7b023          	sd	a4,0(a5)
    80201264:	0240006f          	j	80201288 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    80201268:	f4843783          	ld	a5,-184(s0)
    8020126c:	00878713          	addi	a4,a5,8
    80201270:	f4e43423          	sd	a4,-184(s0)
    80201274:	0007b783          	ld	a5,0(a5)
    80201278:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    8020127c:	fb843783          	ld	a5,-72(s0)
    80201280:	fec42703          	lw	a4,-20(s0)
    80201284:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201288:	f8040023          	sb	zero,-128(s0)
    8020128c:	1500006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201290:	f5043783          	ld	a5,-176(s0)
    80201294:	0007c783          	lbu	a5,0(a5)
    80201298:	00078713          	mv	a4,a5
    8020129c:	07300793          	li	a5,115
    802012a0:	02f71e63          	bne	a4,a5,802012dc <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    802012a4:	f4843783          	ld	a5,-184(s0)
    802012a8:	00878713          	addi	a4,a5,8
    802012ac:	f4e43423          	sd	a4,-184(s0)
    802012b0:	0007b783          	ld	a5,0(a5)
    802012b4:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    802012b8:	fc043583          	ld	a1,-64(s0)
    802012bc:	f5843503          	ld	a0,-168(s0)
    802012c0:	dccff0ef          	jal	8020088c <puts_wo_nl>
    802012c4:	00050793          	mv	a5,a0
    802012c8:	fec42703          	lw	a4,-20(s0)
    802012cc:	00f707bb          	addw	a5,a4,a5
    802012d0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802012d4:	f8040023          	sb	zero,-128(s0)
    802012d8:	1040006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    802012dc:	f5043783          	ld	a5,-176(s0)
    802012e0:	0007c783          	lbu	a5,0(a5)
    802012e4:	00078713          	mv	a4,a5
    802012e8:	06300793          	li	a5,99
    802012ec:	02f71e63          	bne	a4,a5,80201328 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    802012f0:	f4843783          	ld	a5,-184(s0)
    802012f4:	00878713          	addi	a4,a5,8
    802012f8:	f4e43423          	sd	a4,-184(s0)
    802012fc:	0007a783          	lw	a5,0(a5)
    80201300:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201304:	fcc42703          	lw	a4,-52(s0)
    80201308:	f5843783          	ld	a5,-168(s0)
    8020130c:	00070513          	mv	a0,a4
    80201310:	000780e7          	jalr	a5
                ++written;
    80201314:	fec42783          	lw	a5,-20(s0)
    80201318:	0017879b          	addiw	a5,a5,1
    8020131c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201320:	f8040023          	sb	zero,-128(s0)
    80201324:	0b80006f          	j	802013dc <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201328:	f5043783          	ld	a5,-176(s0)
    8020132c:	0007c783          	lbu	a5,0(a5)
    80201330:	00078713          	mv	a4,a5
    80201334:	02500793          	li	a5,37
    80201338:	02f71263          	bne	a4,a5,8020135c <vprintfmt+0x740>
                putch('%');
    8020133c:	f5843783          	ld	a5,-168(s0)
    80201340:	02500513          	li	a0,37
    80201344:	000780e7          	jalr	a5
                ++written;
    80201348:	fec42783          	lw	a5,-20(s0)
    8020134c:	0017879b          	addiw	a5,a5,1
    80201350:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201354:	f8040023          	sb	zero,-128(s0)
    80201358:	0840006f          	j	802013dc <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    8020135c:	f5043783          	ld	a5,-176(s0)
    80201360:	0007c783          	lbu	a5,0(a5)
    80201364:	0007871b          	sext.w	a4,a5
    80201368:	f5843783          	ld	a5,-168(s0)
    8020136c:	00070513          	mv	a0,a4
    80201370:	000780e7          	jalr	a5
                ++written;
    80201374:	fec42783          	lw	a5,-20(s0)
    80201378:	0017879b          	addiw	a5,a5,1
    8020137c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201380:	f8040023          	sb	zero,-128(s0)
    80201384:	0580006f          	j	802013dc <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201388:	f5043783          	ld	a5,-176(s0)
    8020138c:	0007c783          	lbu	a5,0(a5)
    80201390:	00078713          	mv	a4,a5
    80201394:	02500793          	li	a5,37
    80201398:	02f71063          	bne	a4,a5,802013b8 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    8020139c:	f8043023          	sd	zero,-128(s0)
    802013a0:	f8043423          	sd	zero,-120(s0)
    802013a4:	00100793          	li	a5,1
    802013a8:	f8f40023          	sb	a5,-128(s0)
    802013ac:	fff00793          	li	a5,-1
    802013b0:	f8f42623          	sw	a5,-116(s0)
    802013b4:	0280006f          	j	802013dc <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    802013b8:	f5043783          	ld	a5,-176(s0)
    802013bc:	0007c783          	lbu	a5,0(a5)
    802013c0:	0007871b          	sext.w	a4,a5
    802013c4:	f5843783          	ld	a5,-168(s0)
    802013c8:	00070513          	mv	a0,a4
    802013cc:	000780e7          	jalr	a5
            ++written;
    802013d0:	fec42783          	lw	a5,-20(s0)
    802013d4:	0017879b          	addiw	a5,a5,1
    802013d8:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    802013dc:	f5043783          	ld	a5,-176(s0)
    802013e0:	00178793          	addi	a5,a5,1
    802013e4:	f4f43823          	sd	a5,-176(s0)
    802013e8:	f5043783          	ld	a5,-176(s0)
    802013ec:	0007c783          	lbu	a5,0(a5)
    802013f0:	84079ce3          	bnez	a5,80200c48 <vprintfmt+0x2c>
        }
    }

    return written;
    802013f4:	fec42783          	lw	a5,-20(s0)
}
    802013f8:	00078513          	mv	a0,a5
    802013fc:	0b813083          	ld	ra,184(sp)
    80201400:	0b013403          	ld	s0,176(sp)
    80201404:	0c010113          	addi	sp,sp,192
    80201408:	00008067          	ret

000000008020140c <printk>:

int printk(const char* s, ...) {
    8020140c:	f9010113          	addi	sp,sp,-112
    80201410:	02113423          	sd	ra,40(sp)
    80201414:	02813023          	sd	s0,32(sp)
    80201418:	03010413          	addi	s0,sp,48
    8020141c:	fca43c23          	sd	a0,-40(s0)
    80201420:	00b43423          	sd	a1,8(s0)
    80201424:	00c43823          	sd	a2,16(s0)
    80201428:	00d43c23          	sd	a3,24(s0)
    8020142c:	02e43023          	sd	a4,32(s0)
    80201430:	02f43423          	sd	a5,40(s0)
    80201434:	03043823          	sd	a6,48(s0)
    80201438:	03143c23          	sd	a7,56(s0)
    int res = 0;
    8020143c:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201440:	04040793          	addi	a5,s0,64
    80201444:	fcf43823          	sd	a5,-48(s0)
    80201448:	fd043783          	ld	a5,-48(s0)
    8020144c:	fc878793          	addi	a5,a5,-56
    80201450:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201454:	fe043783          	ld	a5,-32(s0)
    80201458:	00078613          	mv	a2,a5
    8020145c:	fd843583          	ld	a1,-40(s0)
    80201460:	fffff517          	auipc	a0,0xfffff
    80201464:	11850513          	addi	a0,a0,280 # 80200578 <putc>
    80201468:	fb4ff0ef          	jal	80200c1c <vprintfmt>
    8020146c:	00050793          	mv	a5,a0
    80201470:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201474:	fec42783          	lw	a5,-20(s0)
}
    80201478:	00078513          	mv	a0,a5
    8020147c:	02813083          	ld	ra,40(sp)
    80201480:	02013403          	ld	s0,32(sp)
    80201484:	07010113          	addi	sp,sp,112
    80201488:	00008067          	ret
