.global __start
.set noreorder

__start:
    la $a1, initstr
    jal zstr
    addu $0, $0, $0

    la $t0, __executable_start
    lw $t1, 32($t0)
    addu $t1, $t0, $t1
    addu $s0, $t1, $0
    li $t3, 2
findsymtab:
    lw $t4, 4($t1)
    lw $t5, 16($t1)
    lw $t6, 20($t1)
    lw $t7, 24($t1)
    bne $t3, $t4, findsymtab
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
    la $s2, endtext
    li $s4, 0
textloop:
    jal checksym
    addu $a0, $s0, $0

    beq $v0, $0, notlabel
    addu $a1, $v0, $0

    jal zstr
    addu $0, $0, $0

    la $a1, labend
    jal zstr
    addu $0, $0, $0

notlabel:
    lw $s1, 0($s0)
    jal printinstr
    addiu $s0, $s0, 4

    addiu $t0, $s4, -1
    bne $t0, $0, noextranl
    movn $s4, $t0, $s4

    la $a1, newline
    jal zstr
    addu $0, $0, $0

noextranl:
    bne $s0, $s2, textloop
    addu $0, $0, $0

    la $a1, midstr
    jal zstr
    addu $0, $0, $0

    li $a0, 0
    li $v0, 4001
    syscall

printinstr:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    la $a1, indent
    jal zstr
    li $t7, 288

    srl $t0, $s1, 21
    bne $t0, $t7, not_li
    addu $0, $0, $0

    la $a1, instr_li
    jal zstr
    addu $0, $0, $0

    j found
    li $s3, 2

not_li:
    srl $t0, $s1, 26
    beq $t0, $0, reginstr
    li $t7, 15

    bne $t0, $t7, not_la
    addu $0, $0, $0

    la $a1, instr_la
    jal zstr
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 16

    jal sep
    addu $0, $0, $0

    sll $t0, $s1, 16
    lh $a0, 2($s0)
    addiu $s0, $s0, 4
    j printtarget
    addu $a0, $a0, $t0

not_la:
    srl $a0, $s1, 24
    la $a1, instrs
    jal gettable
    andi $a0, $a0, 252

    beq $v0, $0, endinstr
    addu $0, $0, $0

found:
    andi $t0, $s3, 3
    addiu $t0, $t0, -1
    beq $t0, $0, branch
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 16

    jal sep
    addu $0, $0, $0

    andi $t0, $s3, 2
    bne $t0, $0, nors
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 21

    jal sep
    addu $0, $0, $0

nors:
    sll $t0, $s1, 16
    jal printnum
    sra $t0, $t0, 16

    andi $t0, $s3, 1
    beq $t0, $0, endinstr
    addu $0, $0, $0

    la $a1, lparen
    jal zstr
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 21

    la $a1, rparen
    jal zstr
    addu $0, $0, $0

endinstr:
    la $a1, newline
    jal zstr
    addu $0, $0, $0

    lw $ra, 0($sp)
    jr $ra
    addiu $sp, $sp, 8

branch:
    li $s4, 2
    andi $t1, $s3, 16
    sll $t0, $s1, 6
    beq $t1, $0, printtarget
    sra $a0, $t0, 4

    jal printreg
    srl $a0, $s1, 21

    jal sep
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 16

    jal sep
    addu $0, $0, $0

    sll $t0, $s1, 16
    sra $t0, $t0, 14
    addu $a0, $s0, $t0
printtarget:
    jal checksym
    addu $0, $0, $0

    jal zstr
    addu $a1, $v0, $0

    j endinstr
    addu $0, $0, $0

reginstr:
    andi $a0, $s1, 63
    la $a1, reginstrs
    jal gettable
    sll $a0, $a0, 2

    andi $t0, $s3, 3
    beq $t0, $0, simple
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 11

    andi $t0, $s3, 2
    beq $t0, $0, endinstr
    addu $0, $0, $0

    jal sep
    addu $0, $0, $0

    andi $t0, $s3, 1
    bne $t0, $0, reg_dst
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 16

    jal sep
    addu $0, $0, $0

    srl $t0, $s1, 6
    jal printnum
    andi $t0, $t0, 31

    j endinstr
    addu $0, $0, $0

reg_dst:
    jal printreg
    srl $a0, $s1, 21

    jal sep
    addu $0, $0, $0

    jal printreg
    srl $a0, $s1, 16

    j endinstr
    addu $0, $0, $0

simple:
    addiu $t0, $s3, -32
    li $t1, 2
    li $s4, 1
    j endinstr
    movz $s4, $t1, $t0

sep:
    la $a1, comma
zstr:
    li $a0, 1
    addu $t0, $a1, $0
    li $a2, -1
measure:
    lb $t1, 0($t0)
    addiu $a2, $a2, 1
    bne $t1, $0, measure
    addiu $t0, $t0, 1

    li $v0, 4004
    syscall

    jr $ra
    addu $0, $0, $0

printreg:
    andi $a0, $a0, 31
    addu $t0, $a0, $a0
    li $a0, 1
    la $a1, dollar
    li $a2, 1
    li $v0, 4004
    syscall

    la $a1, regs
    addu $a1, $a1, $t0
    li $a2, 2
    movz $a2, $a0, $t0
    li $v0, 4004
    syscall

    jr $ra
    addu $0, $0, $0

printnum:
    srl $t1, $t0, 31
    beq $t1, $0, pos
    li $t7, 10

    li $a0, 1
    la $a1, minus
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

checksym:
    addu $t0, $s6, $0
checksymloop:
    lw $t1, 4($t0)
    lw $t2, 0($t0)
    beq $t2, $0, emptyname
    addiu $t0, $t0, 16

    beq $a0, $t1, foundsym
    addu $0, $0, $0

emptyname:
    bne $t0, $s7, checksymloop
    addu $0, $0, $0

    jr $ra
    li $v0, 0

foundsym:
    jr $ra
    addu $v0, $t2, $s5

gettable:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
tableloop:
    lb $s3, 0($a1)
    beq $s3, $0, nomatch
    andi $t3, $s3, 252

    beq $a0, $t3, gotmatch
    addiu $a1, $a1, 1

skip:
    lb $t2, 0($a1)
    bne $t2, $0, skip
    addiu $a1, $a1, 1

    j tableloop
    addu $0, $0, $0

nomatch:
    li $v0, 0
    jr $ra
    addiu $sp, $sp, 8

gotmatch:
    jal zstr
    addu $0, $0, $0

    li $v0, 1
    lw $ra, 0($sp)
    jr $ra
    addiu $sp, $sp, 8

endtext:
.data

buf: .space 16
initstr: .asciz ".global __start\n.set noreorder\n\n"
midstr: .asciz "endtext:\n.data\n\nbuf: .space 16\n"
dollar: .asciz "$"
indent: .asciz "    "
regs: .asciz "0 atv0v1a0a1a2a3t0t1t2t3t4t5t6t7s0s1s2s3s4s5s6s7t8t9k0k1gpspfpra"
comma: .asciz ", "
newline: .asciz "\n"
minus: .asciz "-"
lparen: .asciz "("
rparen: .asciz ")"
instr_li: .asciz "li "
instr_la: .asciz "la "
labend: .asciz ":\n"
strbegin: .asciz ": .asciz \""
strend: .asciz "\"\n"
escquote: .asciz "\\\""
escnl: .asciz "\\n"

instrs:
    .byte 0x09
    .asciz "j "
    .byte 0x0d
    .asciz "jal "
    .byte 0x11
    .asciz "beq "
    .byte 0x15
    .asciz "bne "
    .byte 0x24
    .asciz "addiu "
    .byte 0x30
    .asciz "andi "
    .byte 0x3e
    .asciz "lui "
    .byte 0x83
    .asciz "lb "
    .byte 0x87
    .asciz "lh "
    .byte 0x8f
    .asciz "lw "
    .byte 0xa3
    .asciz "sb "
    .byte 0xaf
    .asciz "sw "
    .byte 0x00

reginstrs:
    .byte 0x02
    .asciz "sll "
    .byte 0x0a
    .asciz "srl "
    .byte 0x0e
    .asciz "sra "
    .byte 0x20
    .asciz "jr $ra"
    .byte 0x2b
    .asciz "movz "
    .byte 0x2f
    .asciz "movn "
    .byte 0x30
    .asciz "syscall"
    .byte 0x41
    .asciz "mfhi "
    .byte 0x49
    .asciz "mflo "
    .byte 0x6f
    .asciz "divu "
    .byte 0x87
    .asciz "addu "
    .byte 0x8f
    .asciz "subu "
    .byte 0x00
