$$
\newcommand \ApplyData {\mathrm{ApplyData}}
\newcommand \ClosingAmount {\mathrm{ClosingAmount}}
\newcommand \AssetClosingAmount {\mathrm{AssetClosingAmount}}
$$

# ApplyData

Each transaction is associated with some information about how it is applied to the
[Account State](./ledger-account-state.md). This information is called \\( \ApplyData \\),
and contains the fields based on the _transaction type_ (`type`).

## Payment Transaction

- The _closing amount_, \\( \ClosingAmount \\), encoded as msgpack field `ca`, specifies
how many μALGO were transferred to the _close-to_ address (`close`).

## Asset Transfer Transaction

- The _asset closing amount_ \\( \AssetClosingAmount \\), encoded as msgpack field
`aca`, specifies how many of the asset units were transferred to the _asset close-to_
address (`aclose`).

## Application Call Transaction

- The _eval delta_, encoded as msgpack field `dt`, is associated with the successful
execution of the corresponding application's Approval Program or Clear State Program.
It contains the following fields:

  - A _global delta_, encoded as msgpack field `gd`, encoding the changes to the
  _global state_ of the called application. This field is a [State Delta](#state-deltas);

  - Zero or more _local deltas_, encoded as msgpack field `ld`, encoding changes
  to some _local states_ associated with the called application. The local delta
  `ld` maps an "account offset" to a [State Delta](#state-deltas). Account offset
  \\( 0 \\) is the transaction's _sender_. Account offsets \\( 1 \\) and greater
  refer to the account specified at that offset _minus one_ in the transaction's
  _foreign accounts_ (`apat`). An account would have a `ld` entry as long as there
  is at least a single change in that set.

  - Zero or more _logs_, encoded as msgpack array `lg`, recording the arguments to
  each call of the `log` opcode in the called application. The order of the entries
  follows the execution order of the `log` opcode invocations. The total number of
  `log` calls **MUST NOT** exceed \\( 32 \\), and the total size of all logged bytes
  is **MUST NOT** exceed \\( 1024 \\). No _logs_ are included if a Clear State Program
  fails.

  - Zero or more _inner transactions_, encoded as msgpack array `itx`. Each element
  of `itx` records a successful inner transaction. Each element will contain the
  transaction fields, encoded under the msgpack field `txn`, in the same way that
  the regular (top-level) transaction is encoded, recursively, including \\( ApplyData \\)
  that applies to the inner transaction.

    - The recursive depth of inner transactions is **MUST NOT** exceed \\( 8 \\);
    - In Version 5, the _inner transactions_ **MUST NOT** exceed \\( 16 \\). From
    Version 6, the count of all _inner transactions_ across the transaction group
    **MUST NOT** exceed \\( 256 \\).
    - The _inner transaction_ types (`type`) are limited to `pay`, `axfer`, `acfg`,
    and `afrz` in programs _before_ Version 6. From Version, `keyreg` and `appl`
    are allowed.
    - A Clear State Program execution **MUST NOT** have any _inner transaction_.

## Distribution Rewards

> The following \\( ApplyData \\) item refers to the legacy Distribution Reward
> system.

- The amount of rewards distributed to each of the accounts touched by this transaction,
encoded as three msgpack fields `rs`, `rr`, and `rc`, representing amount of reward distributed
respectively to:

  - The _sender_ address,
  - The _receiver_ address,
  - The _cose-to_ addresses.

The fields have integer values representing μALGO. 

If any of the addresses are the same (e.g., the _sender_ and _receiver_ are the same), 
then that account received the sum of the respective reward distributions (i.e.,
`rs` plus `rr`).

{{#include ../_include/styles.md:impl}}
> In the reference implementation, one of these two fields will be zero in that case.

# Inner Transactions

TODO (Similarities and differences with respect to regular transactions)

# State Deltas

A _state delta_ represents an update to a [Key/Value Store (KV)](./ledger-applications.md#keyvalue-stores).
It is constructed as an associative array mapping a byte-array key to a single value
delta. It represents a series of actions that, when applied to the previous state
of the Key/Value store, will yield the new state. These _state deltas_ are included
in the Application Call \\( ApplyData \\) structure under the field _eval delta_
(`dt`).

A _value delta_is composed of three fields:

- An _action_, encoded as msgpack field `at`, which specifies how the value for
this key has changed. It has three possible values:

  - `SetUintAction` (value = `1`), indicating that the value for this key should
  be set to the value delta's `Uint` field.
  - `SetBytesAction` (value = `2`), indicating that the value for this key should
  be set to the value delta's `Bytes` field.
  - `DeleteAction` (value = `3`), indicating that the value for this key should
  be deleted.

- `Bytes`, encoded as msgpack field `bs`, which specifies a byte slice value to
set.

- `Uint`, encoded as msgpack field `ui`, which specifies a 64-bit unsigned integer
value to set.