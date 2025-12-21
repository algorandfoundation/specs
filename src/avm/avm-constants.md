# Constants

Constants can be pushed onto the Stack in two different ways:

1. Constants can be pushed directly with `pushint` or `pushbytes` opcodes. This
method is more efficient for constants that are only used once.

1. Constants can be loaded into storage separate from the Stack and Scratch Space,
with `intcblock` or `bytecblock` opcodes. Then, constants from this storage can be
pushed onto the Stack by referring to the type and index using `intc`, `intc_[0123]`,
`bytec`, and `bytec_[0123]`. This method is more efficient for constants that are
used multiple times.

The opcodes `intcblock` and `bytecblock` use [proto-buf style variable length unsigned int](https://developers.google.com/protocol-buffers/docs/encoding#varint),
reproduced [in the `varuint` section](./avm-versioning.md#encoding).

The `intcblock` opcode is followed by a `varuint` specifying the number of integer
constants, and then that number of `varuint`.

The `bytecblock` opcode is followed by a `varuint` specifying the number of byte
constants, and then that number of pairs of `(varuint, bytes)` length prefixed byte
strings.

## Assembly

The [Assembler](./avm-assembler.md) will hide most of this, for example, allowing
simple use of `int 1234` and `byte 0xcafed00d`. Constants introduced via `int` and
`byte` will be assembled into appropriate uses of `pushint|pushbytes` and `{int|byte}c,
{int|byte}c_[0123]` to minimize program bytecode size.

## Named Integer Constants

### On Complete Action Enum Constants

An _application call_ transaction **MUST** indicate the action to be taken following
the execution of its Approval Program or Clear State Program.

The constants below describe the available actions.

{{#include ../_include/auto/constants-on-completion.md}}

### Transaction Type Enum Constants

{{#include ../_include/auto/constants-type-enums.md}}
