# Operations

Most AVM operations work with only one type of argument, `uint64` or `bytes`, and
fail if the wrong type value is on the Stack.

Many instructions accept values to designate Accounts, Assets, or Applications.

Beginning with Version 4, these values may be given as an _offset_ in the corresponding
transaction fields ([foreign accounts](../ledger/ledger-txn-application-call.md#foreign-accounts),
[foreign assets](../ledger/ledger-txn-application-call.md#foreign-assets), [foreign
applications](../ledger/ledger-txn-application-call.md#foreign-applications)) _or_
as the value itself (`bytes` address for foreign accounts, or a `uint64` ID for
foreign assets and applications). The values, however, **MUST** still be present
in the transaction fields.

Before Version 4, most opcodes required using an _offset_, except for reading account
local values of assets or applications, which accepted the IDs directly and did not
require the ID to be present in the corresponding _foreign_ array.

> Beginning with Version 4, those IDs _are_ required to be present in their corresponding
> _foreign_ array. See individual opcodes for details.

In the case of account offsets or application offsets, \\( 0 \\) is specially defined
to the [transaction sender](../ledger/ledger-transactions.md#sender) or the ID of
the _current_ application, respectively.

This section provides a summary of the AVM opcodes, divided by categories. A short
description and a link to the reference implementation are provided for each opcode.
This summary is supplemented by more detail in the [opcodes specification](./avm-appendix-a.md).

Some operations immediately fail the program. A transaction checked by a program
that fails is not valid.

In the documentation for each opcode, the popped Stack arguments are referred to
_alphabetically_, beginning with the deepest argument as `A`. These arguments are
shown in the opcode description, and if the opcode must be of a specific type, it
is noted there.

All opcodes fail if a specified type is incorrect.

If an opcode pushes multiple results, the values are named for ease of exposition
and clarity concerning their Stack positions.

When an opcode manipulates the Stack in such a way that a value changes position
but is otherwise unchanged, the name of the output on the return Stack matches the
name of the input value.
