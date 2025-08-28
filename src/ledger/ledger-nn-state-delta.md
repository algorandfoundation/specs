$$
\newcommand \TxTail {\mathrm{TxTail}}
$$

# State Delta

A _State Delta_ represents the changes made to the Ledger's state from one round
to the next.

It is a compact data structure designed to efficiently update all state _Trackers_
after a block is committed. By recording only the parts of the state that were modified,
it also simplifies block assembly and validation.

> For a formal definition of this structure, refer to the Algorand Ledger [normative specification](ledger.md#state-deltas).

{{#include ../_include/styles.md:impl}}
> State Delta [reference implementation](https://github.com/algorand/go-algorand/blob/a81d54fb36c16c2f2f44cc5d153f358105a63317/ledger/ledgercore/statedelta.go#L92).

In the `go-algorand` reference implementation, a _State Delta_ includes the following
fields:

- `AccountStateDeltas`:\
A set of [`Account State Deltas`](ledger.md#account-state), collecting changes to
accounts affected by the block, detailing how their states were modified.

- `KVMods`:\
A key-value map of modified entries in the [Key Value Store](ledger.md#keyvalue-stores),
represented as `(string → KvValueDelta)`.

- `TxIDs`:\
A mapping of new transaction IDs to their `LastValid` round: `(txid → uint)`. This
is used to update the \\( \TxTail \\) and manage the transaction counter.

- `Txleases`:\
A mapping `(TxLease → uint64)` of new transaction leases to their expiration rounds,
also relevant to the \\( \TxTail \\) mechanism.

- `Creatables`:\
A mapping of data about newly created or deleted _“creatable entities”_ such as
Applications and Assets.

- `*Hdr`:\
A read-only reference to the header of the new block.

- `StateProofNext`:\
Reflects any update to the `StateProofNextRound` in the block header. If the block
includes a valid _State Proof_ transaction, this is set to the next round for a proof;
otherwise, it’s set to \\( 0 \\).

- `PrevTimestamp`:\
Stores the timestamp of the previous block as an integer.

- `AccountTotals`:\
A snapshot of the updated account totals resulting from the changes in this _State
Delta_.