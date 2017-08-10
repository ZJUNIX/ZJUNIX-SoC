#Cache test data
.init	0xbfc00000
	li	$s0, 0xbfc09000
	lui	$s1, 0x8000
	
	la	$s2, testProg
	addu	$s3, $s2,128
loadTestProg:
	lw	$t0, 0($s2)
	addu	$s2, $s2, 4
	sw	$t0, 0($s1)
	bne	$s2, $s3, loadTestProg
	addu	$s1, $s1, 4
	
	lui	$s1, 0x8000
	cache	0, 0x0($s1)
	nop
	cache	1, 0x0($s1)
	nop
	cache	0, 0x40($s1)
	nop
	cache	1, 0x40($s1)
	
	lui	$s1, 0x8000
	lw	$t0, 0($s1)
	sw	$t0, 0x8($s0)

	
	li	$a0, 0xdeadbeef
	li	$a1, 0xbfc09000

	lui	$t0, 0x8000
	jal	$t0
#	jal	testProg
	nop
	
infLoop:
	nop
	nop
	b	infLoop
	nop

	
testProg:
	sw	$a0, 0x8($a1)
	addu	$a0, $a0, 1
	sw	$ra, 0x8($a1)
#	srl	$t0, $ra, 24
#	sw	$t0, 0x18($a1)
#	srl	$t0, $ra, 16
#	sw	$t0, 0x18($a1)
#	srl	$t0, $ra, 8
#	sw	$t0, 0x18($a1)
#	sw	$ra, 0x18($a1)
#	nop
	j	$ra
.space	16
