#Bootstrap main code
.extern	sdInit
.extern	loadKernel
.extern	readSector

.globl	sleep
.globl	puts
.globl	putHex
.globl	putchar
.globl	infLoop
.globl	hexCharMap

.set noreorder
.set noat
.text
.align 3
main:
#Copy data section to RAM
	la	$s0, _rom_data_begin
	la	$s1, _ram_data_begin
	la	$s2, _data_size
	addiu	$s2, $s2, -1
	sra	$s2, $s2, 2
	j	copySection_cond
	addiu	$s2, $s2, 1
	
copySection_loop:
	lw	$t0, 0($s0)
	addiu $s0, $s0, 4
	addiu $s1, $s1, 4
	addiu $s2, $s2, -1
	sw	$t0, 4($s1)
copySection_cond:
	bne	$s2, $zero, copySection_loop
	nop
	
	la	$sp, _ram_data_begin
	jal	sleep
	or	$a0, $zero, 4096
	la	$t0, textOffset
	sw	$zero, 0($t0)
	li	$t1, 0x000fff00
	sw	$t1, 4($t0)
	
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
	
#	li	$a0, 10000000
#	jal	sleep
#	nop
	
	li	$t0, 0x80001000
	j	$t0

infLoop:
	nop
	nop
	j	infLoop
	nop
	
main_sdErr:
	la	$a0, prompt_sdErr
	jal	puts
	nop

	j	infLoop
	nop

main_loadErr:
	move	$s0, $v0
	la	$a0, prompt_loadErr
	jal	puts
	nop

	jal	puts
	move	$a0, $s0
	
	j	infLoop
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

#k0 = target address
saveContext:
	la	$k1, contextBuffer
	sw	$1, 0x0($k1)
	sw	$v0, 0x4($k1)
	sw	$v1, 0x8($k1)
	sw	$a0, 0xc($k1)
	sw	$a1, 0x10($k1)
	sw	$a2, 0x14($k1)
	sw	$a3, 0x18($k1)
	sw	$t0, 0x1c($k1)
	sw	$t1, 0x20($k1)
	sw	$t2, 0x24($k1)
	sw	$t3, 0x28($k1)
	sw	$t4, 0x2c($k1)
	sw	$t5, 0x30($k1)
	sw	$t6, 0x34($k1)
	sw	$t7, 0x38($k1)
	sw	$s0, 0x3c($k1)
	sw	$s1, 0x40($k1)
	sw	$s2, 0x44($k1)
	sw	$s3, 0x48($k1)
	sw	$s4, 0x4c($k1)
	sw	$s5, 0x50($k1)
	sw	$s6, 0x54($k1)
	sw	$s7, 0x58($k1)
	sw	$t8, 0x5c($k1)
	sw	$t9, 0x60($k1)
	sw	$gp, 0x64($k1)
	sw	$sp, 0x68($k1)
	sw	$fp, 0x6c($k1)
	sw	$ra, 0x70($k1)
	
	la	$sp, _ram_data_begin

	#Initialize global variables and clear screen
	la	$t0, textOffset
	sw	$zero, 0($t0)
	li	$t1, 0xf00fff00
	sw	$t1, 4($t0)
	jal	fillScreen
	move	$a0, $t1
	
	jal	$k0
	nop
	j	infLoop
	nop

.org 0x200 # TLB refill
	lui	$k0, %hi(exceptionHandler)
	j	saveContext
	addiu	$k0, $k0, %lo(exceptionHandler)
	
.org 0x380 # Exception
	lui	$k0, %hi(exceptionHandler)
	j	saveContext
	addiu	$k0, $k0, %lo(exceptionHandler)

.org 0x400 # Interrupt
	lui	$k0, %hi(exceptionHandler)
	j	saveContext
	addiu	$k0, $k0, %lo(exceptionHandler)

printRegs:
	addu	$sp, $sp, -8
	sw	$s0, 0x0($sp)
	sw	$ra, 0x4($sp)
	la	$s0, contextBuffer
	
	lui	$a0, %hi(prompt_reg0)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_reg0)
	jal	putReg
	move	$a0, $zero
	jal	putReg
	lw	$a0, 0x0($s0)
	jal	putReg
	lw	$a0, 0x4($s0)
	jal	putReg
	lw	$a0, 0x8($s0)
	jal	putReg
	lw	$a0, 0xc($s0)
	jal	putReg
	lw	$a0, 0x10($s0)
	jal	putReg
	lw	$a0, 0x14($s0)
	jal	putReg
	lw	$a0, 0x18($s0)
	
	lui	$a0, %hi(prompt_reg1)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_reg1)
	jal	putReg
	lw	$a0, 0x1c($s0)
	jal	putReg
	lw	$a0, 0x20($s0)
	jal	putReg
	lw	$a0, 0x24($s0)
	jal	putReg
	lw	$a0, 0x28($s0)
	jal	putReg
	lw	$a0, 0x2c($s0)
	jal	putReg
	lw	$a0, 0x30($s0)
	jal	putReg
	lw	$a0, 0x34($s0)
	jal	putReg
	lw	$a0, 0x38($s0)
	
	lui	$a0, %hi(prompt_reg2)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_reg2)
	jal	putReg
	lw	$a0, 0x3c($s0)
	jal	putReg
	lw	$a0, 0x40($s0)
	jal	putReg
	lw	$a0, 0x44($s0)
	jal	putReg
	lw	$a0, 0x48($s0)
	jal	putReg
	lw	$a0, 0x4c($s0)
	jal	putReg
	lw	$a0, 0x50($s0)
	jal	putReg
	lw	$a0, 0x54($s0)
	jal	putReg
	lw	$a0, 0x58($s0)
	
	lui	$a0, %hi(prompt_reg3)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_reg3)
	jal putReg
	lw	$a0, 0x5c($s0)
	jal	putReg
	lw	$a0, 0x60($s0)
	jal	putReg
	move	$a0, $k0
	jal	putReg
	move	$a0, $k1
	jal putReg
	lw	$a0, 0x64($s0)
	jal putReg
	lw	$a0, 0x68($s0)
	jal putReg
	lw	$a0, 0x6c($s0)
	jal putReg
	lw	$a0, 0x70($s0)
	
	lui	$a0, %hi(prompt_reg4)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_reg4)
	jal	putReg
	mfc0	$a0, $8#BadVAddr
	jal	putReg
	mfc0	$a0, $12#Status
	jal	putReg
	mfc0	$a0, $13#Cause
	jal	putReg
	mfc0	$a0, $14#EPC
	
	lw	$s0, 0x0($sp)
	lw	$ra, 0x4($sp)
	j	$ra
	addu	$sp, $sp, 8

exceptionHandler:
	addu	$sp, $sp, -4
	sw	$ra, 0x0($sp)
	la	$s0, contextBuffer
	
	lui	$a0, %hi(prompt_exception1)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_exception1)
	
	jal	printRegs
	nop
	
	lui	$a0, %hi(prompt_exception2)
	jal	puts
	addiu	$a0, $a0, %lo(prompt_exception2)
	
	lw	$ra, 0x0($sp)
	j	$ra
	addu	$sp, $sp, 4
	
putReg:
	addu	$sp, $sp, -8
	sw	$a0, 0x0($sp)
	sw	$ra, 0x4($sp)
	jal	putchar
	or	$a0, $zero, 0x20
	lw	$a0, 0x0($sp)
	jal	putHex
	ori	$a1, $zero, 8
	jal	putchar
	or	$a0, $zero, 0x20
	lw	$ra, 0x4($sp)
	j	$ra
	addu	$sp, $sp, 8
	
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
	la	$t1, textColor
	lw	$t1, 0($t1)
	or	$t1, $t1, $a0
	sw	$t1, 0($t0)

	addu	$s2, $s2, 4
	and	$t0, $s2, 0x1ff
	slt	$t1, $t0, 320
	bne	$t1, $zero, putchar_noscroll
	nop
	
putchar_newline:
	li	$t0, 0xfe00
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
	beq	$t0, $zero, puts_ret
	addu	$s0, $s0, 1
	jal	putchar
	move	$a0, $t0
	j	puts_loop
	nop
	
puts_ret:
	lw	$ra, 4($sp)
	lw	$s0, 0($sp)
	j	$ra
	addu	$sp, $sp, 8

putHex:
	addu	$sp, $sp, -16
	sw	$s0, 0x0($sp)
	sw	$s1, 0x4($sp)
	sw	$s2, 0x8($sp)
	sw	$ra, 0xc($sp)
	move	$s0, $a0
	move	$s1, $a1
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
	
	lw	$ra, 0xc($sp)
	lw	$s0, 0x0($sp)
	lw	$s1, 0x4($sp)
	lw	$s2, 0x8($sp)
	j	$ra
	addu	$sp, $sp, 16
	
fillScreen:
	li	$t0, 0xbfc04000
	addu	$t1, $t0, 0x3ffc
fillScreen_loop:
	sw	$a0, 0($t0)
	bne	$t0, $t1, fillScreen_loop
	addu	$t0, $t0, 4
	
	j	$ra
	nop

.section .rodata
.align 0
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
prompt_exception1:
	.asciiz "An unhandled exception occured in the operating system.\nControl has been passed to the bootloader.\n\nProcessor registers:\n"
prompt_exception2:
	.asciiz "\n\nPress the reset button to reboot the system.\n"
prompt_reg0:
	.asciiz "  $zero      $at       $v0       $v1       $a0       $a1       $a2       $a3\n"
prompt_reg1:
	.asciiz "   $t0       $t1       $t2       $t3       $t4       $t5       $t6       $t7\n"
prompt_reg2:
	.asciiz "   $s0       $s1       $s2       $s3       $s4       $s5       $s6       $s7\n"
prompt_reg3:
	.asciiz "   $t8       $t9       $k0       $k1       $gp       $sp       $fp       $ra\n"
prompt_reg4:
	.asciiz	"$BadVAddr  $Status    $Cause     $EPC\n"
hexCharMap:
	.asciiz	"0123456789abcdef"

.section .rdata
.align 2
textOffset:
	.word	0x0
textColor:
	.word	0x0	
contextBuffer:
	.space	116
