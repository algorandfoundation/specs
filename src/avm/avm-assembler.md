# Assembler

The Assembler parses TEAL programs line by line:

- Opcodes that only take Stack arguments appear on a line by themselves.

- Opcodes that take immediate arguments are followed by their arguments on the same
line, separated by whitespace.

## Directives

The `#` character at the beginning of a line identifies _preprocessor directives_.

### Pragma

The first line of a TEAL program may contain a special version directive `#pragma
version X` (where `X` is an unsigned integer), which directs the Assembler to generate
bytecode targeting a certain AVM Version.

{{#include ../_include/styles.md:example}}
> For instance, `#pragma version 2` produces bytecode targeting Version 2. By default,
> the Assembler targets Version 1.

> It is syntactically _invalid_ to have a `#pragma` definition after the first program
> opcode.

Subsequent lines may contain other pragma declarations (i.e., `#pragma <some-specification>`),
pertaining to checks the Assembler should perform before agreeing to emit the program
bytecode, specific optimizations, etc. Those declarations are **OPTIONAL** and cannot
alter the semantics as described in this document.

{{#include ../_include/styles.md:impl}}
> Pragma directive [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/data/transactions/logic/assembler.go#L2277).

### Macro

A `#define M M_def` directive (where `M` is an identifier and `M_def` is a valid
TEAL expression) is used to define a _macro_. This is syntactically equivalent to
replacing each occurence of the `M` identifier for the corresponding definition `M_def`.

{{#include ../_include/styles.md:impl}}
> Macro directive [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/data/transactions/logic/assembler.go#L2252C2-L2252C35).

## Comments

`//` prefixes a line comment.

## Separators

Both `;` and `/n` may be used interchangeably to separate statements.

## Constants and Pseudo-Ops

A few _pseudo-opcodes_ simplify writing code. The following pseudo-opcodes:

- `addr`
- `method`
- `int`
- `byte`

Followed by a constant record the constant to a `intcblock` or `bytecblock` at the
beginning of code and insert an `intc` or `bytec` reference where the instruction
appears to load that value.

### `addr`

`addr` parses an Algorand account address `base32` and converts it to a regular bytes
constant.

### `method`

`method` is passed a method signature and takes the first four bytes of the hash
to convert it to the standard method selector defined in [ARC4](https://arc.algorand.foundation/ARCs/arc-0004).

### `byte`

`byte` constants are:

```text
byte base64 AAAA...
byte b64 AAAA...
byte base64(AAAA...)
byte b64(AAAA...)
byte base32 AAAA...
byte b32 AAAA...
byte base32(AAAA...)
byte b32(AAAA...)
byte 0x0123456789abcdef...
byte "\x01\x02"
byte "string literal"
```

### `int`

`int` constants may be:

- `0x` prefixed for hex,
- `0o` or `0` prefixed for octal,
- `0b` prefixed for binary,
- Or decimal numbers.

### `intcblock` and `bytecblock`

`intcblock` may be explicitly assembled. It will conflict with the assembler gathering
`int` pseudo-ops into a `intcblock` program prefix, but may be used if code only
has explicit `intc` references. `intcblock` should be followed by space separated
`int` constants all on one line.

`bytecblock` may be explicitly assembled. It will conflict with the assembler if
there are any `byte` pseudo-ops but may be used if only explicit `bytec` references
are used. `bytecblock` should be followed with `byte` constants all on one line,
either "encoding value" pairs (`b64 AAA...`) or `0x` prefix or function-style values
(`base64(...)`) or string literal values.

## Labels and Branches

A _label_ is defined by any string (that:

- Is a valid identifier string,

- Is not some other opcode or keyword,

- Ends with in `:`.

A label without the trailing `:` can be an argument to a branching instruction.

{{#include ../_include/styles.md:example}}
> Here is an example of TEAL program that uses a `bnz` opcode with the `safe` _label_
> as an _argument_. Since a `1` is pushed into the Stack, the execution jumps to
> the `pop` instruction after the `safe:` label:
>
> ```text
> int 1
> bnz safe
> err
> safe:
> pop
> ```
