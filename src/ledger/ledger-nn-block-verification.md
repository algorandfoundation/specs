# Block Verification

After the block is assembled or a block is received from the network, a series of
checks are performed to verify the integrity of the block.

- Validate that all transactions are [`Alive`](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/transactions/transaction.go#L292)
(can be applied to the Ledger) for the round,

- Validate that the `payset` has valid signatures and the underlying transactions
are properly constructed.
