# Versioning and Encoding

## Versioning

To preserve existing semantics for previously written programs, AVM code is versioned.

When new opcodes are added or existing behavior is changed, a new _Version_ is introduced. 
Programs carrying old versions are executed with their original semantics.

In the AVM bytecode, the Version is an incrementing integer, denoted in the program
as `vX` (where `X` is the version number, see [Pragma directive section](./avm-assembler.md#pragma)).

The AVM current Version is: \\( 11 \\).

> For further details about the available opcodes per version, refer to the [AVM Opcodes
> Specification]().

A compiled program starts with a [varuint](#encoding) declaring the Version of the
compiled code.

Any addition, removal, or change of opcode behavior increments the Version.

> Existing opcode behavior **SHOULD NOT** change. Opcode additions will be infrequent,
> and opcode removals **SHOULD** be very rare.

For Version \\( 1 \\), subsequent bytes after the [varuint](#encoding) are program
opcode bytes.

Future versions **MAY** put other metadata following the version identifier.

Newly introduced transaction types and fields **MUST NOT** break assumptions made
by programs written before they existed.

If one of the transactions in a group executes a program whose Version predates a
transaction type or field that can violate expectations, that transaction type or
field **MUST NOT** be used anywhere in the transaction group.

{{#include ./.include/styles.md:example}}
> A Version \\( 1 \\) program included in a transaction group that includes an [application
> call transaction]() or a non-zero [rekey-to field]() will fail regardless of the
> program itself.

This requirement is enforced as follows:

1. For every transaction in the group, compute the earliest Version that supports
_all_ the fields and values in this transaction.
  
2. Compute `maxVerNo`, the largest Version number across all the transactions in
a group (of size 1 or more).

3. If any transaction in this group has a program with a version smaller than `maxVerNo`,
then that program will fail.

In addition, Applications **MUST** be Version 4 or greater to be called in an inner
transaction.

## Encoding

Trailing versioning information on each program, as well as `intcblock` and `bytecblock`
instructions, are handled using [proto-buf style variable length unsigned ints](https://developers.google.com/protocol-buffers/docs/encoding#varint).

These are encoded with packets of \\( 7 \\) data bits per byte. For every packet,
the high data bit is a \\( 1 \\) if there is a byte after the current one, and \\( 0 \\)
for the last byte of the sequence. The lowest order \\( 7 \\) bits are in the first
byte, followed by successively higher groups of 7 bits.