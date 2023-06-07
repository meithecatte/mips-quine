.global __start
.set noreorder

__start:
    la $t0, __executable_start
    lw $t1, 32($t0)
    addu $t1, $t0, $t1
    li $t3, 2
findsymtab:
    lw $t4, 4($t1)
    lw $t5, 16($t1)
    lw $t2, 20($t1)
    beq $t3, $t4, foundsymtab
    addiu $t1, $t1, 40

foundsymtab:
    addu $s6, $t0, $t5
    addu $s7, $t1, $t2

    la $s0, __start
    la $s2, endtext

textloop:
    jal checksym
    move $a0, $s0
    beqz $v0, notlabel
    li $a0, 1

    la $a1, labend
    li $a2, 2
    li $v0, 4004
    syscall

notlabel:
    lw $s1, 0($s0)
    jal printinstr
    addiu $s0, $s0, 4
    bne $s0, $s2, textloop
    nop

    li $a0, 0
    li $v0, 4001
    syscall

# preserves $s0
# $s1 = instr
printinstr:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)

    li $a0, 1
    la $a1, indent
    li $a2, 4
    li $v0, 4004
    syscall

    srl $t0, $s1, 21
    li $t7, 288
    bne $t0, $t7, not_li
    nop
    la $t1, instr_li
    j found
    li $t2, 2

not_li:
    srl $t0, $s1, 24
    andi $t0, $t0, 252

    la $t1, instrs
check:
    lb $t2, 0($t1)
    beqz $t2, endinstr
    andi $t3, $t2, 252
    beq $t0, $t3, found
    addiu $t1, $t1, 1

skip:
    lb $t2, 0($t1)
    bnez $t2, skip
    addiu $t1, $t1, 1
    j check
    nop

found:
    li $a0, 1
    move $a1, $t1
    li $a2, -1
measure:
    lb $t3, 0($t1)
    addiu $a2, $a2, 1
    bnez $t3, measure
    addiu $t1, $t1, 1

    li $v0, 4004
    syscall

    la $a1, indent
    li $a2, 1
    li $v0, 4004
    syscall

    jal printreg
    srl $a0, $s1, 16
    jal sep
    nop

    andi $t0, $t2, 2
    bnez $t0, nors
    nop

    jal printreg
    srl $a0, $s1, 21
    jal sep
    nop

nors:
    sll $t0, $s1, 16
    jal printnum
    sra $t0, $t0, 16

    andi $t0, $t2, 1
    beqz $t0, endinstr
    nop

    li $a0, 1
    la $a1, lparen
    li $a2, 1
    li $v0, 4004
    syscall

    jal printreg
    srl $a0, $s1, 21

    li $a0, 1
    la $a1, rparen
    li $a2, 1
    li $v0, 4004
    syscall

endinstr:
    li $a0, 1
    la $a1, newline
    li $a2, 1
    li $v0, 4004
    syscall

    lw $ra, 0($sp)
    jr $ra
    addiu $sp, $sp, 8

sep:
    li $a0, 1
    la $a1, comma
    li $a2, 2
    li $v0, 4004
    syscall
    jr $ra
    nop

# $a0 & 31 = reg
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
    li $v0, 4004
    syscall
    jr $ra
    nop

# $t0
printnum:
    bgez $t0, pos
    li $t7, 10

    li $a0, 1
    la $a1, minus
    li $a2, 1
    li $v0, 4004
    syscall
    negu $t0, $t0

pos:
    li $a0, 1
    la $a1, buf+15
    li $a2, 0

digits:
    divu $0 , $t0, $t7
    mflo $t0
    mfhi $t1
    addiu $t1, $t1, 48
    addiu $a1, $a1, -1
    sb $t1, 0($a1)
    bnez $t0, digits
    addiu $a2, $a2, 1

    li $v0, 4004
    syscall
    jr $ra
    nop

# $a0
checksym:
    move $t0, $s6
checksymloop:
    lw $t1, 4($t0)
    lw $t2, 0($t0)
    beq $a0, $t1, foundsym
    addiu $t0, $t0, 16

    bne $t0, $s7, checksymloop
    nop

    jr $ra
    li $v0, 0

foundsym:
    jr $ra
    li $v0, 1

endtext:
.data

buf: .space 16
dollar: .ascii "$"
indent: .ascii "    "
regs: .ascii "0 atv0v1a0a1a2a3t0t1t2t3t4t5t6t7s0s1s2s3s4s5s6s7t8t9k0k1gpspfpra"
comma: .ascii ", "
newline: .ascii "\n"
minus: .ascii "-"
lparen: .ascii "("
rparen: .ascii ")"
instr_li: .asciz "li"
labend: .ascii ":\n"

# oooooott
#       00 simple immediate instruction
#       01 jump
#       10 ignore rs
#       11 rs and offset form address
instrs:
    .byte 0x24
    .asciz "addiu"
    .byte 0x30
    .asciz "andi"
    .byte 0x3e
    .asciz "lui"
    .byte 0x83
    .asciz "lb"
    .byte 0x87
    .asciz "lh"
    .byte 0x8f
    .asciz "lw"
    .byte 0xaf
    .asciz "sw"
    .byte 0x00
