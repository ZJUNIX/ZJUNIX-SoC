#SD initialize code and read sector function
.globl	sdInit
.globl	readSector
.globl	sleep

.globl	puts
.globl	putchar
.globl	putHex
.globl	infLoop

.globl	hexCharMap

sdInit:
	addu	$sp, $sp, -12
	sw	$s0, 0x0($sp)
	sw	$gp, 0x4($sp)
	sw	$ra, 0x8($sp)
	
	li	$gp, 0xbfc09000
	
	li	$t0, 125
	sw	$t0, 0x124($gp)#Set SD clock rate to 400kHz
	li	$t0, 511
	sw	$t0, 0x144($gp)
	sw	$zero, 0x148($gp)#Block size:512, block count:1
	li	$t0, 25000
	sw	$t0, 0x120($gp)#Command timeout:1ms under 25MHz clock
	li	$t0, 2500000
	sw	$t0, 0x118($gp)#Data timeout:100ms under 25MHz clock
	
	#Send CMD0
	li	$a0, 0x4
	la	$a2, sdInit_err
	move	$v0, $zero #v0 carries the current command index(BCD encoded) for error signaling
	jal	sd_sendCmd
	move	$a1, $zero
	
	jal	sleep
	or	$a0, $zero, 4095

	#Send CMD8, check response=0x1aa
	or	$a0, $zero, 0x81d
	li	$v0, 0x8
	jal	sd_sendCmd
	or	$a1, $zero, 0x1aa
	
	lw	$t0, 0x108($gp)
	li	$t1, 0x1aa
	bne	$t0, $t1, sdInit_err1
	nop

	jal	sleep
	or	$a0, $zero, 4095

	#Send ACMD41 for the first time, voltage window set to empty
	#Note: CMD41 in ACMD41 should not check command index and CRC
	or	$a0, $zero, 0x371d
	li	$v0, 0x55
	jal	sd_sendCmd
	move	$a1, $zero
	or	$a0, $zero, 0x2905
	li	$v0, 0x41
	jal	sd_sendCmd
	lui	$a1, 0x4000

	li	$s0, 200#Try 200 times at most
sd_ACMD41:
	or	$a0, $zero, 0x371d
	li	$v0, 0x55
	jal	sd_sendCmd
	move	$a1, $zero
	or	$a0, $zero, 0x2905
	li	$v0, 0x41
	jal	sd_sendCmd
	lui	$a1, 0x4010
	
	lw	$t0, 0x108($gp)
	lui	$t1, 0x8000
	and	$t0, $t0, $t1
	bne	$t0, $zero, sd_ACMD41_finish
	addu	$s0, $s0, -1
	beq	$s0, $zero, sdInit_err2
	nop
	jal	sleep
	or	$a0, $zero, 4095

	b	sd_ACMD41
	nop
sd_ACMD41_finish:
	
	#CMD2 followed by CMD3
	or	$a0, $zero, 0x0207
	li	$v0, 0x2
	jal	sd_sendCmd
	move	$a1, $zero
	or	$a0, $zero, 0x031d
	li	$v0, 0x3
	jal	sd_sendCmd
	move	$a1, $zero
	
	#Set SD clock rate to 25MHz
	or	$t0, $zero, 1
	sw	$t0, 0x124($gp)
	
	jal	sleep
	or	$a0, $zero, 4095
	
	#CMD7, select card
	#Store RCA in s0
	lw	$a1, 0x108($gp)
	li	$a0, 0x071d
	lui	$t0, 0xffff
	and	$a1, $a1, $t0
	li	$v0, 0x7
	jal	sd_sendCmd
	move	$s0, $a1
	
	#CMD13 to get card status
#	or	$a0, $zero, 0x0d1d
#	jal	sd_sendCmd
#	move	$a1, $s0
	
	#ACMD42, disconnect pullup resistor on DAT3
	li	$v1, 9
	or	$a0, $zero, 0x371d
	li	$v0, 0x55
	jal	sd_sendCmd
	move	$a1, $s0
	
	li	$v1, 10
	li	$v0, 0x42
	or	$a0, $zero, 0x2a1d
	jal	sd_sendCmd
	move	$a1, $zero
	
	#ACMD6, set bus width to 4-bit
	li	$v1, 11
	or	$a0, $zero, 0x371d
	li	$v0, 0x55
	jal	sd_sendCmd
	move	$a1, $s0
	
	li	$v1, 12
	or	$a0, $zero, 0x061d
	li	$v0, 0x6
	jal	sd_sendCmd
	or	$a1, $zero, 2
	
	#Set SD controller's bus width to 4
	li	$t0, 1
	sw	$t0, 0x11c($gp)
	
	#Initialization done
	move	$v0, $zero
	b	sdInit_ret
	nop
	
sdInit_err:
	lw	$s0, 0x134($gp)
	la	$a0, sdInitCmdErrMsg
	la	$t0, hexCharMap
	srl	$t1, $v0, 4
	and	$t2, $v0, 0xf
	and	$t1, $t1, 0xf
	addu	$t1, $t1, $t0
	addu	$t2, $t2, $t0
	lb	$t1, 0($t1)
	lb	$t2, 0($t2)
	sb	$t1, 24($a0)
	sb	$t2, 25($a0)
	jal	puts
	nop
	
	la	$a0, sdInitCmdErrMsg
	la	$t0, sdInitCmdErrMsgIndex
	srl	$t1, $s0, 2
	and	$t1, $t1, 7
	addu	$t0, $t0, $t1
	lbu	$t0, 0($t0)
	jal	puts
	addu	$a0, $a0, $t0
	
	b	sdInit_ret
	li	$v0, 1
	
sdInit_err1:
	la	$a0, sdInitCMD8ErrMsg
	jal	puts
	nop
	lw	$a0, 0x108($gp)
	jal	putHex
	nop
	li	$a0, 10
	jal	putchar
	nop
	
	b	sdInit_ret
	li	$v0, 1
sdInit_err2:
	la	$a0, sdInitACMD41ErrMsg
	jal	puts
	nop
	b	sdInit_ret
	li	$v0, 1
	
sdInit_ret:
	lw	$s0, 0x0($sp)
	lw	$gp, 0x4($sp)
	lw	$ra, 0x8($sp)
	addu	$sp, $sp, 12
	j	$ra
	nop
	
sd_sendCmd:#a0=cmd, a1=arg, a2=err return addr
	sw	$zero, 0x134($gp)#Clear flags
	sw	$a0, 0x104($gp)
	sw	$a1, 0x100($gp)
	li	$t0, 4095
sd_sendCmd_wait0:
	nop
	nop
	bne	$t0, $zero, sd_sendCmd_wait0
	addu	$t0, $t0, -1
sd_sendCmd_wait1:
	lw	$t0, 0x134($gp)
	beq	$t0, $zero, sd_sendCmd_wait1
	nop
	and	$t1, $t0, 0x1
	bne	$t1, $zero, sd_sendCmd_ret
	nop
	j	$a2
	nop
sd_sendCmd_ret:
	j	$ra
	nop
	
readSector:#$a0=buffer, $a1=id
	addu	$sp, $sp, -16
	sw	$s0, 0x0($sp)
	sw	$s1, 0x4($sp)
	sw	$gp, 0x8($sp)
	sw	$ra, 0xc($sp)
	
	li	$gp, 0xbfc09000
	move	$s0, $a0
	move	$s1, $a1

	sw	$zero, 0x160($gp)#DMA address
	sw	$zero, 0x13c($gp)#Data transfer events
	li	$a0, 0x1139
	move	$a1, $s1
	la	$a2, sd_readSector_err
	jal	sd_sendCmd
	nop
	
sd_readSector_wait:
	lw	$t0, 0x13c($gp)
	beq	$t0, $zero, sd_readSector_wait
	nop
	
	xor	$t1, $t0, 0x1
	bne	$t1, $zero, sd_readSector_err1
	lw	$v0, 0x13c($gp)

#Copy data into buffer
	li	$t0, 0xbfc08000
	addu	$t1, $t0, 512
sd_readSector_copy:
	lw	$t2, 0($t0)
	addu	$t0, $t0, 4
	sw	$t2, 0($s0)
	bne	$t0, $t1, sd_readSector_copy
	addu	$s0, $s0, 4
	
	b	sd_readSector_ret
	move	$v0, $zero
sd_readSector_err:
	lw	$v0, 0x134($gp)
sd_readSector_err1:
	la	$a0, sd_readSector_errMsg
	jal	puts
	nop
	jal	putHex
	move	$a0, $s1
	la	$a0, sd_readSector_errMsg1
	jal	puts
	nop
	jal	putHex
	move	$a0, $v0
	jal	putchar
	li	$a0, 10
	j	infLoop
	nop
	
sd_readSector_ret:
	lw	$s0, 0x0($sp)
	lw	$s1, 0x4($sp)
	lw	$gp, 0x8($sp)
	lw	$ra, 0xc($sp)
	addu	$sp, $sp, 16
	j	$ra
	nop

#sd_readSector_debug:
#	.asciiz	"Read sector "
sd_readSector_errMsg:
	.asciiz	"Error reading sector 0x"
sd_readSector_errMsg1:
	.asciiz	",code="
sdInitCmdErrMsg:
	.asciiz "  Error when issuing CMD   to SD card: \0Timeout error.\n\0CRC error.\n\0Timeout and CRC error.\n\0Index error.\n\0Timeout and index error.\n\0CRC and index error.\n\0Timeout, CRC, and index error.\n"
sdInitCmdErrMsgIndex:
	.byte	0, 40, 56, 68, 92, 106, 132, 154
sdInitCMD8ErrMsg:
	.asciiz	"Expected response 0x1aa after CMD8 but received 0x"
sdInitACMD41ErrMsg:
	.asciiz	"Card did not respond properly after 200 tries of ACMD41."
#reportLongResponse:
#	lw	$t0, 0x114($gp)
#	srl	$t1, $t0, 24
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 16
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 8
#	sw	$t1, 0x18($gp)
#	sw	$t0, 0x18($gp)
#	lw	$t0, 0x110($gp)
#	srl	$t1, $t0, 24
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 16
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 8
#	sw	$t1, 0x18($gp)
#	sw	$t0, 0x18($gp)
#	lw	$t0, 0x10c($gp)
#	srl	$t1, $t0, 24
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 16
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 8
#	sw	$t1, 0x18($gp)
#	sw	$t0, 0x18($gp)
#reportResponse:
#	lw	$t0, 0x108($gp)
#	srl	$t1, $t0, 24
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 16
#	sw	$t1, 0x18($gp)
#	srl	$t1, $t0, 8
#	sw	$t1, 0x18($gp)
#	sw	$t0, 0x18($gp)
#	j	$ra
#	nop
