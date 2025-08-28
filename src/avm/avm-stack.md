# The Stack

The AVM _Stack_ is the core structure for the interpreter’s execution. It is constructed
and used as a regular stack data structure.

{{#include ../_include/styles.md:impl}}
> Stack [reference implementation](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/data/transactions/logic/eval.go#L675).

On a new AVM program execution, the Stack starts empty. After opcode execution the
Stack can contain arbitrary values of either:

- 64-bit unsigned integer type (referred to as `uint64`), or

- Byte-array type (referred to as `bytes` or `[]byte`).

Byte-arrays length **MUST NOT** exceed \\( 4096 \\) bytes.

A value that may be of either one of these types (not simultaneously) is generically
referred to as a `StackValue`.

Most operations act on the stack, popping arguments from it and pushing results
to it. Some operations have _immediate_ arguments encoded directly into the instruction,
rather than coming from the Stack.

The maximum Stack depth is \\( 1000 \\). If the Stack depth is exceeded or if a
byte-array element exceeds \\( 4096 \\) bytes, the program fails.

If an opcode is documented to access a position in the Stack that does not exist,
the operation fails.

{{#include ../_include/styles.md:example}}
> This is often an attempt to access an element below the Stack. A simple example
> is an operation like `concat` that expects two arguments on the Stack: if the
> Stack has fewer than two elements, the operation fails.

Some operations (like `frame_dig` and `proto`) could fail because of an attempt to
access above the current Stack.

## Stack Types

While every element of the Stack is restricted to the types `uint64` and `bytes`, 
the values of these types may be known to be bounded.

The most common bounded types are named to provide more semantic information in the
documentation and as type checking during assembly time to provide more informative
error messages.

### Definitions

| Name       | Bound                               | AVM Type |
|:-----------|:------------------------------------|:--------:|
| `[]byte`   | \\( len(x) \leq 4096 \\)            | `[]byte` |
| `[32]byte` | \\( len(x) = 32 \\)                 | `[]byte` |
| `[64]byte` | \\( len(x) = 64 \\)                 | `[]byte` |
| `[80]byte` | \\( len(x) = 80 \\)                 | `[]byte` |
| `address`  | \\( len(x) = 32 \\)                 | `[]byte` |
| `bigint`   | \\( len(x) \leq 64 \\)              | `[]byte` |
| `boxName`  | \\( 1 \leq len(x) \leq 64 \\)       | `[]byte` |
| `method`   | \\( len(x) = 4 \\)                  | `[]byte` |
| `stateKey` | \\( len(x) \leq 64 \\)              | `[]byte` |
| `bool`     | \\( x \leq 1 \\)                    | `uint64` |
| `uint64`   | \\( x \leq 18446744073709551615 \\) | `uint64` |
| `any`      |                                     |  `any`   |
| `none`     |                                     |  `none`  |
