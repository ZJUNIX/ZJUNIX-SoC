.init	0xbfc00000

	li	$gp, 0xbfc09000
	move	$s0, $zero
	li	$s1, 0x10000

loop:
	sw	$s0, 0x8($gp)
	lw	$t0, 0x14($gp)
	lw	$t1, 0x1c($gp)
	andi	$t0, $t0, 0x1f
	andi	$t1, $t1, 0xff
	beq	$t0, $zero, ps2_nodata
	nop
	lb	$t2, 0x10($gp)
	addiu	$s0, $s0, 1
	sb	$t2, 0x18($gp)
ps2_nodata:
	beq	$t1, $zero, loop
	nop
	lb	$t2, 0x18($gp)
	addu	$s0, $s0, $s1
	sb	$t2, 0x10($gp)
	b	loop
	nop
