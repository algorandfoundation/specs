---
numbersections: true
title: "Algorand Transaction Execution Approval Language"
date: \today
abstract: >
  Algorand allows transactions to be effectively signed by a small program. If the program evaluates to true then the transaction is allowed. This document defines the language and bytecode format.
---

# The Algorand Virtual Machine (AVM) and TEAL.

The AVM is a bytecode based stack interpreter that executes programs
associated with Algorand transactions. TEAL is an assembly language
syntax for specifying a program that is ultimately converted to AVM
bytecode. These programs can be used to check the parameters of the
transaction and approve the transaction as if by a signature. This use
is called a _Smart Signature_. Starting with v2, these programs may
also execute as _Smart Contracts_, which are often called
_Applications_. Contract executions are invoked with explicit
application call transactions.

Programs have read-only access to the transaction they are attached
to, the other transactions in their atomic transaction group, and a
few global values. In addition, _Smart Contracts_ have access to
limited state that is global to the application, per-account local
state for each account that has opted-in to the application, and
additional per-application arbitrary state in named _boxes_. For both types of
program, approval is signaled by finishing with the stack containing a
single non-zero uint64 value, though `return` can be used to signal an
early approval which approves based only upon the top stack value
being a non-zero uint64 value.

### Inner Transactions

The following opcodes allow for "inner transactions". Inner
transactions allow stateful applications to have many of the effects
of a true top-level transaction, programmatically.  However, they are
different in significant ways.  The most important differences are
that they are not signed, duplicates are not rejected, and they do not
appear in the block in the usual away. Instead, their effects are
noted in metadata associated with their top-level application
call transaction.  An inner transaction's `Sender` must be the
SHA512_256 hash of the application ID (prefixed by "appID"), or an
account that has been rekeyed to that hash.

In v5, inner transactions may perform `pay`, `axfer`, `acfg`, and
`afrz` effects.  After executing an inner transaction with
`itxn_submit`, the effects of the transaction are visible beginning
with the next instruction with, for example, `balance` and
`min_balance` checks. In v6, inner transactions may also perform
`keyreg` and `appl` effects. Inner `appl` calls fail if they attempt
to invoke a program with version less than v4, or if they attempt to
opt-in to an app with a ClearState Program less than v4.

In v5, only a subset of the transaction's header fields may be set: `Type`/`TypeEnum`,
`Sender`, and `Fee`. In v6, header fields `Note` and `RekeyTo` may
also be set.  For the specific (non-header) fields of each transaction
type, any field may be set.  This allows, for example, clawback
transactions, asset opt-ins, and asset creates in addition to the more
common uses of `axfer` and `acfg`.  All fields default to the zero
value, except those described under `itxn_begin`.

Fields may be set multiple times, but may not be read. The most recent
setting is used when `itxn_submit` executes. For this purpose `Type`
and `TypeEnum` are considered to be the same field. When using
`itxn_field` to set an array field (`ApplicationArgs` `Accounts`,
`Assets`, or `Applications`) each use adds an element to the end of
the array, rather than setting the entire array at once.

`itxn_field` fails immediately for unsupported fields, unsupported
transaction types, or improperly typed values for a particular
field. `itxn_field` makes acceptance decisions entirely from the field
and value provided, never considering previously set fields. Illegal
interactions between fields, such as setting fields that belong to two
different transaction types, are rejected by `itxn_submit`.

| Opcode | Description |
| - | -- |
| `itxn_begin` | begin preparation of a new inner transaction in a new transaction group |
| `itxn_next` | begin preparation of a new inner transaction in the same transaction group |
| `itxn_field f` | set field F of the current inner transaction to A |
| `itxn_submit` | execute the current inner transaction group. Fail if executing this group would exceed the inner transaction limit, or if any transaction in the group fails. |
| `itxn f` | field F of the last inner transaction |
| `itxna f i` | Ith value of the array field F of the last inner transaction |
| `itxnas f` | Ath value of the array field F of the last inner transaction |
| `gitxn t f` | field F of the Tth transaction in the last inner group submitted |
| `gitxna t f i` | Ith value of the array field F from the Tth transaction in the last inner group submitted |
| `gitxnas t f` | Ath value of the array field F from the Tth transaction in the last inner group submitted |
