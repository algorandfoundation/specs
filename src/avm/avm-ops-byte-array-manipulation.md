# Byte Array Manipulation

## Byte Manipulation

{{#include ../_include/auto/avm-ops-byte-array-manipulation.md}}

## Byte Arithmetic

The following opcodes take byte-array values that are interpreted as
big-endian unsigned integers.  For mathematical operators, the
returned values are the shortest byte-array that can represent the
returned value.  For example, the zero value is the empty
byte-array. For comparison operators, the returned value is a uint64.

Input lengths are limited to a maximum length of 64 bytes,
representing a 512 bit unsigned integer. Output lengths are not
explicitly restricted, though only `b*` and `b+` can produce a larger
output than their inputs, so there is an implicit length limit of 128
bytes on outputs.

{{#include ../_include/auto/avm-ops-byte-arithmetic.md}}

## Bitwise Operations

These opcodes operate on the bits of byte-array values.  The shorter
input array is interpreted as though left padded with zeros until it is the
same length as the other input.  The returned values are the same
length as the longer input.  Therefore, unlike array arithmetic,
these results may contain leading zero bytes.

{{#include ../_include/auto/avm-ops-bitwise.md}}
