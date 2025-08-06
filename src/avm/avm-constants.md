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
reproduced [in the `varuint` section](#varuint).

The `intcblock` opcode is followed by a `varuint` specifying the number of integer
constants, and then that number of `varuint`.

The `bytecblock` opcode is followed by a `varuint` specifying the number of byte
constants, and then that number of pairs of `(varuint, bytes)` length prefixed byte
strings.

## Assembly

The [Assembler]() will hide most of this, for example, allowing simple use of `int 1234`
and `byte 0xcafed00d`. Constants introduced via `int` and `byte` will be assembled
into appropriate uses of `pushint|pushbytes` and `{int|byte}c, {int|byte}c_[0123]`
to minimize program bytecode size.

## Named Integer Constants

### On Complete Action Enum Constants

An _application call_ transaction **MUST** indicate the action to be taken following
the execution of its Approval Program or Clear State Program.

The constants below describe the available actions.

|        ACTION         | VALUE | DESCRIPTION                                                                                                                                                                                                                                         |
|:---------------------:|:-----:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|       `NoOpOC`        |  `0`  | _Only_ execute the Approval Program associated with the _application ID_, with no additional effects.                                                                                                                                               |
|       `OptInOC`       |  `1`  | _Before_ executing the Approval Program, allocate _local state_ for the _application ID_ into the _sender_’s account data.                                                                                                                          |
|     `CloseOutOC`      |  `2`  | _After_ executing the Approval Program, clear any _local state_ for the _application ID_ out of the _sender_’s account data.                                                                                                                        |
|    `ClearStateOC`     |  `3`  | _Do not_ execute the Approval Program, and instead execute the Clear State Program (which may not reject this transaction). Additionally, clear any _local state_ for the _application ID_ out of the _sender_’s account data (as in `CloseOutOC`). |
| `UpdateApplicationOC` |  `4`  | _After_ executing the Approval Program, _replace_ the Approval Program and Clear State Program associated with the _application ID_ with the programs specified in this transaction.                                                                |
| `DeleteApplicationOC` |  `5`  | _After_ executing the Approval Program, _delete_ the parameters of with the _application ID_ from the account data of the application’s creator.                                                                                                    |

### Transaction Type Enum Constants

|   TYPE    | VALUE | DESCRIPTION                       |
|:---------:|:-----:|:----------------------------------|
| `unknown` |  `0`  | Unknown type, invalid transaction |
|   `pay`   |  `1`  | ALGO transfers (payment)          |
| `keyreg`  |  `2`  | Consensus keys registration       |
|  `acfg`   |  `3`  | Asset creation and configuration  |
|  `axfer`  |  `4`  | Asset transfer                    |
|  `afrz`   |  `5`  | Asset freeze and unfreeze         |
|  `appl`   |  `6`  | Application calls                 |
|  `stpf`   |  `7`  | State Proof                       |
|   `hb`    |  `8`  | Consensus heartbeat               |