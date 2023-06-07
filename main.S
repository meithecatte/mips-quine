.global __start
.set noreorder

__start:
    la $s0, __start

    lw $s1, ($s0)
    jal printinstr
    addiu $s0, $s0, 4

    lw $s1, ($s0)
    jal printinstr
    addiu $s0, $s0, 4

    li $v0, 4001
    li $a0, 0
    syscall

# preserves $s0
# $s1 = instr
printinstr:
    addiu $sp, $sp, -8
    sw $ra, ($sp)

    li $a0, 1
    la $a1, indent
    li $a2, 4
    li $v0, 4004
    syscall

    srl $t0, $s1, 24
    andi $t0, $t0, 252

    la $t1, instrs
check:
    lb $t2, ($t1)
    andi $t3, $t2, 252
    beq $t0, $t3, found
    addiu $t1, $t1, 1

skip:
    lb $t2, ($t1)
    bnez $t2, skip
    addiu $t1, $t1, 1
    j check
    nop

found:
    li $a0, 1
    move $a1, $t1
    li $a2, -1
measure:
    lb $t3, ($t1)
    addiu $a2, $a2, 1
    bnez $t3, measure
    addiu $t1, $t1, 1

    li $v0, 4004
    syscall

    la $a1, indent
    li $a2, 1
    li $v0, 4004
    syscall

    andi $t0, $t2, 2
    bnez $t0, nors
    nop

    jal printreg
    srl $a0, $s1, 21
    jal sep
    nop

nors:
    jal printreg
    srl $a0, $s1, 16
    jal sep
    nop

    li $a0, 1
    la $a1, newline
    li $a2, 1
    li $v0, 4004
    syscall

    lw $ra, ($sp)
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

.data

dollar: .ascii "$"
indent: .ascii "    "
regs: .ascii "r0atv0v1a0a1a2a3t0t1t2t3t4t5t6t7s0s1s2s3s4s5s6s7t8t9k0k1gpspfpra"
comma: .ascii ", "
newline: .ascii "\n"

# oooooosj
# j = is jump
# s = skip rs
instrs:
    .byte 0x24
    .asciz "addiu"
    .byte 0x3e
    .asciz "lui"
