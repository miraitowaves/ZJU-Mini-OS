
example:     file format elf64-littleriscv


Disassembly of section .plt:

0000000000000570 <.plt>:
 570:	00002397          	auipc	t2,0x2
 574:	41c30333          	sub	t1,t1,t3
 578:	a983be03          	ld	t3,-1384(t2) # 2008 <__TMC_END__>
 57c:	fd430313          	addi	t1,t1,-44
 580:	a9838293          	addi	t0,t2,-1384
 584:	00135313          	srli	t1,t1,0x1
 588:	0082b283          	ld	t0,8(t0)
 58c:	000e0067          	jr	t3

0000000000000590 <__libc_start_main@plt>:
 590:	00002e17          	auipc	t3,0x2
 594:	a88e3e03          	ld	t3,-1400(t3) # 2018 <__libc_start_main@GLIBC_2.34>
 598:	000e0367          	jalr	t1,t3
 59c:	00000013          	nop

00000000000005a0 <puts@plt>:
 5a0:	00002e17          	auipc	t3,0x2
 5a4:	a80e3e03          	ld	t3,-1408(t3) # 2020 <puts@GLIBC_2.27>
 5a8:	000e0367          	jalr	t1,t3
 5ac:	00000013          	nop

Disassembly of section .text:

00000000000005b0 <_start>:
 5b0:	022000ef          	jal	ra,5d2 <load_gp>
 5b4:	87aa                	mv	a5,a0
 5b6:	00002517          	auipc	a0,0x2
 5ba:	a8253503          	ld	a0,-1406(a0) # 2038 <_GLOBAL_OFFSET_TABLE_+0x10>
 5be:	6582                	ld	a1,0(sp)
 5c0:	0030                	addi	a2,sp,8
 5c2:	ff017113          	andi	sp,sp,-16
 5c6:	4681                	li	a3,0
 5c8:	4701                	li	a4,0
 5ca:	880a                	mv	a6,sp
 5cc:	fc5ff0ef          	jal	ra,590 <__libc_start_main@plt>
 5d0:	9002                	ebreak

00000000000005d2 <load_gp>:
 5d2:	00002197          	auipc	gp,0x2
 5d6:	22e18193          	addi	gp,gp,558 # 2800 <__global_pointer$>
 5da:	8082                	ret
	...

00000000000005de <deregister_tm_clones>:
 5de:	00002517          	auipc	a0,0x2
 5e2:	a2a50513          	addi	a0,a0,-1494 # 2008 <__TMC_END__>
 5e6:	00002797          	auipc	a5,0x2
 5ea:	a2278793          	addi	a5,a5,-1502 # 2008 <__TMC_END__>
 5ee:	00a78863          	beq	a5,a0,5fe <deregister_tm_clones+0x20>
 5f2:	00002797          	auipc	a5,0x2
 5f6:	a3e7b783          	ld	a5,-1474(a5) # 2030 <_ITM_deregisterTMCloneTable@Base>
 5fa:	c391                	beqz	a5,5fe <deregister_tm_clones+0x20>
 5fc:	8782                	jr	a5
 5fe:	8082                	ret

0000000000000600 <register_tm_clones>:
 600:	00002517          	auipc	a0,0x2
 604:	a0850513          	addi	a0,a0,-1528 # 2008 <__TMC_END__>
 608:	00002597          	auipc	a1,0x2
 60c:	a0058593          	addi	a1,a1,-1536 # 2008 <__TMC_END__>
 610:	8d89                	sub	a1,a1,a0
 612:	4035d793          	srai	a5,a1,0x3
 616:	91fd                	srli	a1,a1,0x3f
 618:	95be                	add	a1,a1,a5
 61a:	8585                	srai	a1,a1,0x1
 61c:	c599                	beqz	a1,62a <register_tm_clones+0x2a>
 61e:	00002797          	auipc	a5,0x2
 622:	a2a7b783          	ld	a5,-1494(a5) # 2048 <_ITM_registerTMCloneTable@Base>
 626:	c391                	beqz	a5,62a <register_tm_clones+0x2a>
 628:	8782                	jr	a5
 62a:	8082                	ret

000000000000062c <__do_global_dtors_aux>:
 62c:	1141                	addi	sp,sp,-16
 62e:	e022                	sd	s0,0(sp)
 630:	00002417          	auipc	s0,0x2
 634:	a2040413          	addi	s0,s0,-1504 # 2050 <completed.0>
 638:	00044783          	lbu	a5,0(s0)
 63c:	e406                	sd	ra,8(sp)
 63e:	e385                	bnez	a5,65e <__do_global_dtors_aux+0x32>
 640:	00002797          	auipc	a5,0x2
 644:	a007b783          	ld	a5,-1536(a5) # 2040 <__cxa_finalize@GLIBC_2.27>
 648:	c791                	beqz	a5,654 <__do_global_dtors_aux+0x28>
 64a:	00002517          	auipc	a0,0x2
 64e:	9b653503          	ld	a0,-1610(a0) # 2000 <__dso_handle>
 652:	9782                	jalr	a5
 654:	f8bff0ef          	jal	ra,5de <deregister_tm_clones>
 658:	4785                	li	a5,1
 65a:	00f40023          	sb	a5,0(s0)
 65e:	60a2                	ld	ra,8(sp)
 660:	6402                	ld	s0,0(sp)
 662:	0141                	addi	sp,sp,16
 664:	8082                	ret

0000000000000666 <frame_dummy>:
 666:	bf69                	j	600 <register_tm_clones>

0000000000000668 <main>:
 668:	1141                	addi	sp,sp,-16
 66a:	e406                	sd	ra,8(sp)
 66c:	e022                	sd	s0,0(sp)
 66e:	0800                	addi	s0,sp,16
 670:	00000517          	auipc	a0,0x0
 674:	02050513          	addi	a0,a0,32 # 690 <_IO_stdin_used+0x8>
 678:	f29ff0ef          	jal	ra,5a0 <puts@plt>
 67c:	4781                	li	a5,0
 67e:	853e                	mv	a0,a5
 680:	60a2                	ld	ra,8(sp)
 682:	6402                	ld	s0,0(sp)
 684:	0141                	addi	sp,sp,16
 686:	8082                	ret
