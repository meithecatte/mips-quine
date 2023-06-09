.global __start
.set noreorder

__start:
    la $a1, s0
    jal zstr
    addu $0, $0, $0

    la $t0, __executable_start
    lw $t1, 32($t0)
    addu $t1, $t0, $t1
    addu $s0, $t1, $0
    li $t3, 2
stab:
    lw $t4, 4($t1)
    lw $t5, 16($t1)
    lw $t6, 20($t1)
    lw $t7, 24($t1)
    bne $t3, $t4, stab
    addiu $t1, $t1, 40

    addu $s6, $t0, $t5
    addu $s7, $s6, $t6
    sll $t1, $t7, 5
    sll $t2, $t7, 3
    addu $t2, $t1, $t2
    addu $t2, $s0, $t2
    lw $t3, 16($t2)
    addu $s5, $t0, $t3
    la $s0, __start
    la $s2, z
    li $s4, 0
p1:
    jal psym
    lw $s1, 0($s0)

    addiu $s0, $s0, 4
    la $a1, sp
    jal zstr
    li $t7, 288

    srl $t0, $s1, 21
    bne $t0, $t7, nli
    addu $0, $0, $0

    la $a1, sli
    jal zstr
    addu $0, $0, $0

    j found
    li $s3, 2

nli:
    srl $t0, $s1, 26
    beq $t0, $0, renc
    li $t7, 15

    bne $t0, $t7, nla
    addu $0, $0, $0

    la $a1, sla
    jal zstr
    addu $0, $0, $0

    jal preg
    srl $a0, $s1, 16

    jal sep
    sll $t7, $s1, 16

    lh $a0, 2($s0)
    addiu $s0, $s0, 4
    j ptgt
    addu $a0, $a0, $t7

nla:
    srl $a0, $s1, 24
    la $a1, t1
    jal gtab
    andi $a0, $a0, 252

    beq $v0, $0, p1nl
    addu $0, $0, $0

found:
    andi $t0, $s3, 3
    addiu $t0, $t0, -1
    beq $t0, $0, bx
    addu $0, $0, $0

    jal preg
    srl $a0, $s1, 16

    jal sep
    andi $t7, $s3, 2

    bne $t7, $0, nors
    addu $0, $0, $0

    jal preg
    srl $a0, $s1, 21

    jal sep
    addu $0, $0, $0

nors:
    sll $t0, $s1, 16
    jal pnum
    sra $t0, $t0, 16

    andi $t0, $s3, 1
    beq $t0, $0, p1nl
    addu $0, $0, $0

    la $a1, lp
    jal zstr
    addu $0, $0, $0

    jal preg
    srl $a0, $s1, 21

    la $a1, rp
    jal zstr
    addu $0, $0, $0

p1nl:
    la $a1, nl
    jal zstr
    addiu $t7, $s4, -1

    bne $t7, $0, ngap
    movn $s4, $t7, $s4

    la $a1, nl
    jal zstr
    addu $0, $0, $0

ngap:
    bne $s0, $s2, p1
    addu $0, $0, $0

    la $a1, s1
    jal zstr
    addu $0, $0, $0

    la $s0, s0
    la $s2, y
p2:
    jal psym
    addu $0, $0, $0

    beq $s0, $s2, exit
    li $a0, 0

    la $a1, sa
    jal zstr
    addu $0, $0, $0

slit:
    lbu $t0, 0($s0)
    beq $t0, $0, p2nl
    li $a0, 1

    li $a2, 1
    addu $a1, $s0, $0
    sltiu $t1, $t0, 32
    bne $t1, $0, esc
    addiu $t1, $t0, -34

    beq $t1, $0, esc
    addiu $t1, $t0, -92

    beq $t1, $0, esc
    sltiu $t1, $t0, 127

    bne $t1, $0, pch
    addu $0, $0, $0

esc:
    la $a1, buf
    li $t1, 92
    sb $t1, 0($a1)
    srl $t1, $t0, 6
    addiu $t1, $t1, 48
    sb $t1, 1($a1)
    srl $t1, $t0, 3
    andi $t1, $t1, 7
    addiu $t1, $t1, 48
    sb $t1, 2($a1)
    andi $t1, $t0, 7
    addiu $t1, $t1, 48
    sb $t1, 3($a1)
    li $a2, 4
pch:
    li $v0, 4004
    syscall

    j slit
    addiu $s0, $s0, 1

p2nl:
    la $a1, se
    jal zstr
    addiu $s0, $s0, 1

    j p2
    addu $0, $0, $0

exit:
    li $v0, 4001
    syscall

bx:
    li $s4, 2
    andi $t1, $s3, 16
    sll $t0, $s1, 6
    beq $t1, $0, ptgt
    sra $a0, $t0, 4

    jal preg
    srl $a0, $s1, 21

    jal sep
    sll $t7, $s1, 16

    jal preg
    srl $a0, $s1, 16

    jal sep
    sra $t7, $t7, 14

    addu $a0, $s0, $t7
ptgt:
    jal sym
    addu $0, $0, $0

    jal zstr
    addu $a1, $v0, $0

    j p1nl
    addu $0, $0, $0

renc:
    andi $a0, $s1, 63
    la $a1, t0
    jal gtab
    sll $a0, $a0, 2

    andi $t0, $s3, 3
    beq $t0, $0, simp
    addiu $t0, $s3, -32

    jal preg
    srl $a0, $s1, 11

    andi $t0, $s3, 2
    beq $t0, $0, p1nl
    addu $0, $0, $0

    jal sep
    andi $t7, $s3, 1

    bne $t7, $0, dst
    addu $0, $0, $0

    jal preg
    srl $a0, $s1, 16

    jal sep
    srl $t7, $s1, 6

    jal pnum
    andi $t0, $t7, 31

    j p1nl
    addu $0, $0, $0

dst:
    jal preg
    srl $a0, $s1, 21

    jal sep
    addu $0, $0, $0

    jal preg
    srl $a0, $s1, 16

    j p1nl
    addu $0, $0, $0

simp:
    li $t1, 2
    li $s4, 1
    j p1nl
    movz $s4, $t1, $t0

sep:
    la $a1, comma
zstr:
    li $a0, 1
    addu $t0, $a1, $0
    li $a2, -1
len:
    lb $t1, 0($t0)
    addiu $a2, $a2, 1
    bne $t1, $0, len
    addiu $t0, $t0, 1

    li $v0, 4004
    syscall

    jr $ra
    addu $0, $0, $0

preg:
    andi $a0, $a0, 31
    addu $t0, $a0, $a0
    li $a0, 1
    la $a1, usd
    li $a2, 1
    li $v0, 4004
    syscall

    la $a1, r_
    addu $a1, $a1, $t0
    li $a2, 2
    movz $a2, $a0, $t0
    li $v0, 4004
    syscall

    jr $ra
    addu $0, $0, $0

pnum:
    srl $t1, $t0, 31
    beq $t1, $0, pos
    li $t7, 10

    li $a0, 1
    la $a1, ng
    li $a2, 1
    li $v0, 4004
    syscall

    subu $t0, $0, $t0
pos:
    la $a1, buf
    addiu $a1, $a1, 16
    li $a2, 0
digits:
    divu $0, $t0, $t7
    mflo $t0
    mfhi $t1
    addiu $t1, $t1, 48
    addiu $a1, $a1, -1
    sb $t1, 0($a1)
    bne $t0, $0, digits
    addiu $a2, $a2, 1

    li $v0, 4004
    syscall

    jr $ra
    addu $0, $0, $0

psym:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    jal sym
    addu $a0, $s0, $0

    beq $v0, $0, nlab
    addu $a1, $v0, $0

    jal zstr
    addu $0, $0, $0

    la $a1, lz
    jal zstr
    addu $0, $0, $0

nlab:
    lw $ra, 0($sp)
    jr $ra
    addiu $sp, $sp, 8

sym:
    addu $t0, $s6, $0
nextsym:
    lw $t1, 4($t0)
    lw $t2, 0($t0)
    beq $t2, $0, emp
    addiu $t0, $t0, 16

    beq $a0, $t1, symok
    addu $0, $0, $0

emp:
    bne $t0, $s7, nextsym
    addu $0, $0, $0

    jr $ra
    li $v0, 0

symok:
    jr $ra
    addu $v0, $t2, $s5

gtab:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
next:
    lb $s3, 0($a1)
    beq $s3, $0, nope
    andi $t3, $s3, 252

    beq $a0, $t3, ok
    addiu $a1, $a1, 1

skip:
    lb $t2, 0($a1)
    bne $t2, $0, skip
    addiu $a1, $a1, 1

    j next
    addu $0, $0, $0

nope:
    li $v0, 0
    jr $ra
    addiu $sp, $sp, 8

ok:
    jal zstr
    addu $0, $0, $0

    li $v0, 1
    lw $ra, 0($sp)
    jr $ra
    addiu $sp, $sp, 8

z:
.data

buf: .space 16
s0:
.asciz ".global __start\012.set noreorder\012\012"
s1:
.asciz "z:\012.data\012\012buf: .space 16\012"
usd:
.asciz "$"
sp:
.asciz "    "
r_:
.asciz "0 atv0v1a0a1a2a3t0t1t2t3t4t5t6t7s0s1s2s3s4s5s6s7t8t9k0k1gpspfpra"
comma:
.asciz ", "
nl:
.asciz "\012"
ng:
.asciz "-"
lp:
.asciz "("
rp:
.asciz ")"
sli:
.asciz "li "
sla:
.asciz "la "
lz:
.asciz ":\012"
sa:
.asciz ".asciz \042"
se:
.asciz "\042\012"
t1:
.asciz "\011j "
.asciz "\015jal "
.asciz "\021beq "
.asciz "\025bne "
.asciz "$addiu "
.asciz ",sltiu "
.asciz "0andi "
.asciz "\203lb "
.asciz "\207lh "
.asciz "\217lw "
.asciz "\223lbu "
.asciz "\243sb "
.asciz "\257sw "
.asciz ""
t0:
.asciz "\002sll "
.asciz "\012srl "
.asciz "\016sra "
.asciz " jr $ra"
.asciz "+movz "
.asciz "/movn "
.asciz "0syscall"
.asciz "Amfhi "
.asciz "Imflo "
.asciz "odivu "
.asciz "\207addu "
.asciz "\217subu "
.asciz ""
y:
