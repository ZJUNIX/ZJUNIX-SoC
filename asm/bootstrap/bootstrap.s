.globl	sleep
.globl	sdInit
.globl	loadKernel
.globl	readSector

.globl	puts
.globl	putHex
.globl	putchar
.globl	infLoop

.globl	hexCharMap

.init	0xbfc00000

#Bootstrap main code
main:
#Clear all registers
	move	$1, $zero
	move	$2, $zero
	move	$3, $zero
	move	$4, $zero
	move	$5, $zero
	move	$6, $zero
	move	$7, $zero
	move	$8, $zero
	move	$9, $zero
	move	$10, $zero
	move	$11, $zero
	move	$12, $zero
	move	$13, $zero
	move	$14, $zero
	move	$15, $zero
	move	$16, $zero
	move	$17, $zero
	move	$18, $zero
	move	$19, $zero
	move	$20, $zero
	move	$21, $zero
	move	$22, $zero
	move	$23, $zero
	move	$24, $zero
	move	$25, $zero
	move	$26, $zero
	move	$27, $zero
	move	$28, $zero
	move	$29, $zero
	move	$30, $zero
	move	$31, $zero

	li	$sp, 0xbfc04000
	jal	sleep
	or	$a0, $zero, 4096
	la	$t0, textOffset
	sw	$zero, 0($t0)
	
	jal	fillScreen
	move	$a0, $zero

	la	$a0, prompt0
	jal	puts
	nop

	jal	sdInit
	nop
	bne	$v0, $zero, main_sdErr
	nop
	
	la	$a0, prompt_sdComp
	jal	puts
	nop
	
	jal	loadKernel
	nop
	bne	$v0, $zero, main_loadErr
	nop
	
	la	$a0, prompt_loadComp
	jal	puts
	nop
	
	li	$a0, 10000000
	jal	sleep
	nop
	
	li	$t0, 0x80001000
	j	$t0
	nop
	
#	la	$a0, sectorBuf
#	jal	readSector
#	move	$a1, $zero
	
#	la	$t0, sectorBuf
#	addu	$t1, $t0, 512
#	li	$gp, 0xbfc09000
#main_loop:
#	lbu	$t2, 0($t0)
#	addu	$t0, $t0, 1
#	sw	$t2, 0x18($gp)
#	jal	sleep
#	li	$a0, 4096
#	bne	$t0, $t1, main_loop
#	nop
	
	b	infLoop
	nop
	
main_sdErr:
	
	la	$a0, prompt_sdErr
	jal	puts
	nop

	b	infLoop
	nop

main_loadErr:
	move	$s0, $v0
	la	$a0, prompt_loadErr
	jal	puts
	nop

	jal	puts
	move	$a0, $s0
	
	b	infLoop
	nop
	
infLoop:
	nop
	nop
	b	infLoop
	nop
	
sleep:
	nop
	nop
	nop
	nop
	nop
	nop
	bne	$a0, $zero, sleep
	addu	$a0, $a0, -1
	j	$ra
	nop

prompt0:
	.asciiz "ZJUNIX bootloader v1.0\nInitializing SD card...\n"
prompt_sdErr:
	.asciiz "Error initializing SD card."
prompt_sdComp:
	.asciiz "Successfully initialized SD card.\nSearching for kernel binary...\n"
prompt_loadErr:
	.asciiz	"Error loading Kernel binary:\n  "
prompt_loadComp:
	.asciiz	"Finished loading Kernel binary. Ready to enter kernel...\n"
hexCharMap:
	.asciiz	"0123456789abcdef"
textOffset:
	.word 0x0
putchar:
	addu	$sp, $sp, -12
	sw	$s0, 0x0($sp)
	sw	$s1, 0x4($sp)
	sw	$s2, 0x8($sp)
	la	$s0, textOffset
	li	$s1, 0xbfc04000
	lw	$s2, 0($s0)
	
	#test if \n
	xor	$t0, $a0, 0x0a
	and	$t0, $t0, 0xff
	beq	$t0, $zero, putchar_newline
	nop

	and	$a0, $a0, 0xff
	addu	$t0, $s1, $s2
	li	$t1, 0x000fff00
	or	$t1, $t1, $a0
	sw	$t1, 0($t0)

	addu	$s2, $s2, 4
	and	$t0, $s2, 0x1ff
	slt	$t1, $t0, 320
	bne	$t1, $zero, putchar_noscroll
	nop
	
putchar_newline:
	addu	$t0, $zero, 0xfe00
	and	$s2, $s2, $t0
	addu	$s2, $s2, 0x200
	slt	$t0, $s2, 0x3c00
	bne	$t0, $zero, putchar_noscroll
	nop
	
#Scroll the screen up for 1 line:for(i=0;i<3968;i++)c[i]=c[i+128];
	move	$t0, $s1
	addu	$t1, $s1, 14848
scrollScreen_loop1:
	lw	$t2, 0x200($t0)
	sw	$t2, 0x0($t0)
	addu	$t0, $t0, 4
	bne	$t0, $t1, scrollScreen_loop1
	nop
	addu	$t1, $t1, 0x200
scrollScreen_loop2:
	sw	$zero, 0x0($t0)
	addu	$t0, $t0, 4
	bne	$t0, $t1, scrollScreen_loop2
	nop
	
	addu	$s2, $s2, -0x200

putchar_noscroll:
	sw	$s2, 0($s0)
	
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	addu	$sp, $sp, 12
	j	$ra
	nop

puts:
	addu	$sp, $sp, -8
	sw	$s0, 0($sp)
	sw	$ra, 4($sp)
	move	$s0, $a0
puts_loop:
	lbu	$t0, 0($s0)
	addu	$s0, $s0, 1
	beq	$t0, $zero, puts_ret
	nop
	move	$a0, $t0
	jal	putchar
	nop
	j	puts_loop
	nop
	
puts_ret:
	lw	$s0, 0($sp)
	lw	$ra, 4($sp)
	addu	$sp, $sp, 8
	j	$ra
	nop

putHex:
	addu	$sp, $sp, -16
	sw	$s0, 0x0($sp)
	sw	$s1, 0x4($sp)
	sw	$s2, 0x8($sp)
	sw	$ra, 0xc($sp)
	move	$s0, $a0
	li	$s1, 8
	la	$s2, hexCharMap
putHex_loop:
	srl	$t0, $s0, 28
	addu	$t0, $t0, $s2
	lbu	$a0, 0($t0)
	jal	putchar
	sll	$s0, $s0, 4
	addu	$s1, $s1, -1
	bne	$s1, $zero, putHex_loop
	nop
	
	lw	$s0, 0x0($sp)
	lw	$s1, 0x4($sp)
	lw	$s2, 0x8($sp)
	lw	$ra, 0xc($sp)
	addu	$sp, $sp, 16
	j	$ra
	nop
	
fillScreen:
	li	$t0, 0xbfc04000
	addu	$t1, $t0, 0x3ffc
fillScreen_loop:
	sw	$a0, 0($t0)
	bne	$t0, $t1, fillScreen_loop
	addu	$t0, $t0, 4
	
	j	$ra
	nop

