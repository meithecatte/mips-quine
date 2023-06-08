# MIPS quine

A quine is a program that prints its own source code. This one accomplishes this
by disassembling itself.

```
$ mips-linux-gnu-gcc -static -fno-pic -mno-abicalls -nostdlib quine.S -o quine
$ qemu-mips ./quine | head
.global __start
.set noreorder

__start:
    la $a1, s0
    jal zstr
    addu $0, $0, $0

    la $t0, __executable_start
    lw $t1, 32($t0)
$ diff <(qemu-mips ./quine) quine.S
$
```

## why?

It [seemed more enticing than going to sleep][nerdsnipe].

## how do you handle labels?

It parses its own ELF headers and walks its own symbol table.

## what's with the cryptic label names?

If the binary goes over 4 KiB, the symbol table lands in a part of the file that
doesn't get mapped. The easiest way to work around this was to golf it down.
It even was a fun challenge to make it fit. I could probably open the executable
and map it into memory, but that seems really finicky.

## Trivia

- The code assumes that a `lui` instruction is always part of the assembler's
  expansion of `la` and blindly reads out the literal field of the following
  `addiu` without checking whether it's actually an `addiu`. This is fine,
  as we only need to handle the situations that occur in our code.
- The disassembler is table driven, with each entry in the table consisting
  of a single byte, followed by the opcode name as a null-terminated string.
  The single byte holds 6 bits to identify the opcode, and 2 bits to describe
  how the operands should get decoded.

  This became a problem when the `jr` instruction called for a 5th operand mode
  in the R-encoding table. Instead of handling this properly, I just made
  the instruction always decode as `jr $ra`, by having `"jr $ra"` be the name
  of the opcode. It's not like anything else occurs in the quine's code.
- To avoid writing a separate routine for printing out the tables that drive
  the disassembler, I encode the opcode bytes using octal escapes. It's hideous,
  but it gets the job done.
- MIPS register names are mere suggestions. "Caller-saved registers"? That sounds
  like a global variable to me. "Function arguments are passed through `$a0-$a3`"?
  Sometimes you just don't feel like it and use `$t0`. Sometimes the only argument
  goes through `$a1`, skipping `$a0` entirely. I plead code golf.

## Closing remarks

meow!! ^_^ :3

[nerdsnipe]: https://xkcd.com/356/
