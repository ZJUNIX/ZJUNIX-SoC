.globl	readSector
.globl	loadKernel
.globl	puts
.globl	putHex
.globl	sleep

#Variable map:
#$s0=fatLocation
#$s1=firstCluster
#$s2=fileSize
#$s3=clusterId
#$s4=i
loadKernel:
	addu	$sp, $sp, -28
	sw	$s0, 0x0($sp)
	sw	$s1, 0x4($sp)
	sw	$s2, 0x8($sp)
	sw	$s3, 0xc($sp)
	sw	$s4, 0x10($sp)
	sw	$gp, 0x14($sp)
	sw	$ra, 0x18($sp)
	
	la	$gp, sectorBuf
#readSector(sectorBuf, 0);
	move	$a0, $gp
	jal	readSector
	move	$a1, $zero
#if(sectorBuf[0x1c2] != 0x0b || sectorBuf[0x1c2] != 0x0c) return fileSystemTypeErrMsg;
	lbu	$t0, 0x1c2($gp)
	li	$t1, 0x0b
	la	$v0, fileSystemTypeErrMsg
	beq	$t0, $t1, fsTypePassed
	li	$t1, 0x0c
	bne $t0, $t1, loadKernel_exit
	nop
fsTypePassed:
#fatLocation = *(unsigned int *)(sectorBuf + (0x1c6));
	lwr	$s0, 0x1c6($gp)
	lwl	$s0, 0x1c9($gp)
#readSector(sectorBuf, fatLocation);
	move	$a0, $gp
	jal	readSector
	move	$a1, $s0
#if(*(unsigned short *)(sectorBuf + (0xb)) != 512 || sectorBuf[0xd] != 8) return -1;
	lwr	$t0, 0xb($gp)
	lwl	$t0, 0xe($gp)
	and	$t0, $t0, 0xffff
	li	$t1, 512
	la	$v0, sectorSizeErrMsg
	bne	$t0, $t1, loadKernel_exit
	nop

	lbu	$t0, 0xd($gp)
	li	$t1, 0x8
	la	$v0, clusterSizeErrMsg
	bne	$t0, $t1, loadKernel_exit
	nop
#fatLocation += *(unsigned short *)(sectorBuf + (0xe));
	lhu	$t0, 0xe($gp)
	addu	$s0, $s0, $t0
#firstCluster = fatLocation + *(unsigned int *)(sectorBuf + (0x24)) * sectorBuf[0x10] - (8 << 1);
	lw	$t0, 0x24($gp)
	lbu	$t1, 0x10($gp)
	mult	$t0, $t1
	mflo	$t2
	addu	$s1, $s0, -16
	addu	$s1, $s1, $t2
#readCluster(clusterBuf, *(unsigned int *)(sectorBuf + (0x2c)));
	lw	$a1, 0x2c($gp)
	jal	readCluster
	addu	$a0, $gp, 512
#for(int i = 0; i < 512 * 8; i += 32) -> for(char *p = clusterBuf; p < (clusterBuf + 4096); p += 32)
	addu	$t0, $gp, 512
	addu	$t1, $t0, 4096
loadKernel_loop0_start:
	lw	$t2, -0xc($gp)
	lw	$t3, 0x0($t0)
	bne	$t2, $t3, loadKernel_loop0_end
	nop
	lw	$t2, -0x8($gp)
	lw	$t3, 0x4($t0)
	bne	$t2, $t3, loadKernel_loop0_end
	nop
	lw	$t2, -0x4($gp)
	lw	$t3, 0x8($t0)
	li	$t4, 0xffffff
	and	$t3, $t3, $t4
	bne	$t2, $t3, loadKernel_loop0_end
	nop
	b	loadKernel_loop0_out
	nop
loadKernel_loop0_end:
	addu	$t0, $t0, 32
	bne	$t0, $t1, loadKernel_loop0_start
	nop
	#Not found:
	la	$v0, kernelNotFoundErrMsg
	b	loadKernel_exit
	nop
loadKernel_loop0_out:#Found
#fileSize = *(unsigned int *)(clusterBuf + (i + 0x1C));
	lw	$s2, 0x1c($t0)
#clusterId = *(unsigned short *)(clusterBuf + (i + 0x14)) << 16;
#clusterId |= *(unsigned short *)(clusterBuf + (i + 0x1A));
	lhu	$s3, 0x14($t0)
	lhu	$t1, 0x1a($t0)
	sll	$s3, $s3, 16
	or	$s3, $s3, $t1
	
	la	$a0, fileFoundMsg
	jal	puts
	nop

	#Test code
#	jal	putHex
#	move	$a0, $s2
#	jal	putHex
#	move	$a0, $s3
#	b	loadKernel_exit
#	nop
	
#for(int i = 0; i < fileSize; i += 512 * 8)
	move	$s4, $zero
loadKernel_loop1_start:
#readSector(sectorBuf, fatLocation + (clusterId >> 7));
	srl	$a1, $s3, 7
	addu	$a1, $a1, $s0
	jal	readSector
	move	$a0, $gp
#readCluster(kernelLocation + i, clusterId);
	lui	$a0, 0x8000
	addu	$a0, $a0, $s4
	jal	readCluster
	move	$a1, $s3
	jal	writebackCluster
	move	$a0, $s4
#clusterId = ((unsigned int *)sectorBuf)[clusterId & 63];
	and	$t0, $s3, 63
	sll	$t0, $t0, 2
	addu	$t0, $t0, $gp
	lw	$s3, 0($t0)
#for(int i = 0; i < fileSize; i += 512 * 8)
	addu	$s4, $s4, 4096
	sltu	$t0, $s4, $s2
	bne	$t0, $zero, loadKernel_loop1_start
	nop
	
	move	$v0, $zero
loadKernel_exit:
	lw	$s0, 0x0($sp)
	lw	$s1, 0x4($sp)
	lw	$s2, 0x8($sp)
	lw	$s3, 0xc($sp)
	lw	$s4, 0x10($sp)
	lw	$gp, 0x14($sp)
	lw	$ra, 0x18($sp)
	addu	$sp, $sp, 28
	j	$ra
	nop
	
readCluster:
#id=firstCluster+(id<<3)
	sll	$a1, $a1, 3
	addu	$a1, $a1, $s1
	
	addu	$sp, $sp, -12
	sw	$s0, 0x0($sp)
	sw	$s1, 0x4($sp)
	sw	$ra, 0x8($sp)

	move	$s0, $a0
	jal	readSector
	move	$s1, $a1
	addu	$a0, $s0, 0x200
	jal	readSector
	addu	$a1, $s1, 1
	addu	$a0, $s0, 0x400
	jal	readSector
	addu	$a1, $s1, 2
	addu	$a0, $s0, 0x600
	jal	readSector
	addu	$a1, $s1, 3
	addu	$a0, $s0, 0x800
	jal	readSector
	addu	$a1, $s1, 4
	addu	$a0, $s0, 0xa00
	jal	readSector
	addu	$a1, $s1, 5
	addu	$a0, $s0, 0xc00
	jal	readSector
	addu	$a1, $s1, 6
	addu	$a0, $s0, 0xe00
	jal	readSector
	addu	$a1, $s1, 7
	
	lw	$s0, 0x0($sp)
	lw	$s1, 0x4($sp)
	lw	$ra, 0x8($sp)
	addu	$sp, $sp, 12
	j	$ra
	nop

writebackCluster:#a0=starting address of cluster
	move	$t0, $a0
	addu	$t1, $t0, 0x1000#4096bytes
writebackCluster_loop:
	cache	0, 0x0($t0)
	nop
	cache	1, 0x0($t0)
#	xor	$t0, $t0, 0x8000
#	cache	0, 0x0($t0)
#	nop
#	cache	1, 0x0($t0)
#	xor	$t0, $t0, 0x8000
	addu	$t0, $t0, 0x40
	bne	$t0, $t1, writebackCluster_loop
	nop
	
	j	$ra
	nop
	
fileFoundMsg:	
	.asciiz	"Kernel binary found. Loading kernel...\n"
fileSystemTypeErrMsg:
	.asciiz "File system of first partition is not FAT32.\n"
sectorSizeErrMsg:
	.asciiz "Sector size is incorrect; 512 bytes required.\n"
clusterSizeErrMsg:
	.asciiz "Cluster size is incorrect; 4096 bytes required.\n"
kernelNotFoundErrMsg:
	.asciiz "Kernel binary not found.\n"
fileName:#-0xc($gp)
	.asciiz	"KERNEL  BIN"
sectorBuf:
#	.space	128
#clusterBuf:
#	.space	1024
