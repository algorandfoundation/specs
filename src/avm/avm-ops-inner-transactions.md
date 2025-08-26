# Inner Transactions

The following opcodes allow for _inner transactions_.

Inner transactions allow Applications to have many of the effects of a true top-level
transaction, programmatically. However, they are different in significant ways.
The most important differences are that:

- They are not signed;

- Duplicates are not rejected;

- They do not appear in the block in the usual way.

Instead, their effects are noted in metadata associated with their top-level application
call transaction.

An inner transaction's _sender_ **MUST** be the [SHA512/256 hash](../crypto/crypto-sha512.md)
of the Application ID (prefixed by `appID`), or an account that has been rekeyed
to that hash.

In Version 5, inner transactions may perform `pay`, `axfer`, `acfg`, and `afrz` effects. 

After executing an inner transaction with `itxn_submit`, the effects of the transaction
are visible beginning with the next instruction with, for example, `balance` and
`min_balance` checks.

In Version 6, inner transactions may also perform `keyreg` and `appl` effects. Inner
`appl` calls fail if they attempt to invoke a program with a Version less than Version
4, or if they attempt to opt-in to an app with a Clear State Program less than Version 4.

In Version 5, only a subset of the transaction's header fields may be set: `Type` / 
`TypeEnum`, `Sender`, and `Fee`.

In Version 6, header fields `Note` and `RekeyTo` may also be set.

For the specific (non-header) fields of each transaction type, any field may be set.
This allows, for example, clawback transactions, asset opt-ins, and asset creates
in addition to the more common uses of `axfer` and `acfg`.

All fields default to the zero value, except those described under `itxn_begin`.

Fields may be set multiple times, but may not be read. The most recent setting is
used when `itxn_submit` executes. For this purpose `Type` and `TypeEnum` are considered
to be the same field. When using `itxn_field` to set an array field (`ApplicationArgs`,
`Accounts`, `Assets`, or `Applications`) each use adds an element to the end of
the array, rather than setting the entire array at once.

`itxn_field` fails immediately for unsupported fields, unsupported transaction types,
or improperly typed values for a particular field. `itxn_field` makes acceptance
decisions entirely from the field and value provided, never considering previously
set fields.

Illegal interactions between fields, such as setting fields that belong to two different
transaction types, are rejected by `itxn_submit`.

{{#include ../.include/auto/avm-ops-inner-transactions.md}}