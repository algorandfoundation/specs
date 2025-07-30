# The Scratch Space (Heap)

In addition to the stack, the AVM has a _scratch space_ (or _heap_) of 256 positions.

Like stack values, scratch locations may be hold `stackValues` (of either `uint64`
or `bytes` types) and are initialized as zeroed-out `uint64` values.

> The _scratch space_ is an additional area of volatile memory used at runtime. It’s
> useful for storing values that are needed multiple times during program execution
> or that stay the same for long periods. It provides a convenient place to keep
> such persistent or reusable data during the program execution.

{{#include ../.include/styles.md:impl}}
> Scratch Space [reference implementation.](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/data/transactions/logic/eval.go#L650)

## Indexing

Scratch space locations are mapped to \\( 0 \\)-based integer index.

## Access

The scratch space is accessed by the `load(s)` and `store(s)` opcodes which move
data respectively:

- From the scratch space to the stack;

- From the stack to the scratch space.

## Persistency

Application calls **MAY** inspect the _final_ scratch space of earlier application
call transactions in the _same group_ using `gload(s')(s)`, where:

- `s` is the integer index of a scratch space location,

- `s'` is the integer index of an earlier application call transaction in the group.
