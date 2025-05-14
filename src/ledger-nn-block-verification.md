# Block Verification

After the block is assembled or a block is received from the network, a series of
checks are performed to verify the integrity of the block.

- Validate that all transactions are `Alive` (can be applied to the Ledger) for
the round,

- Validate that the `payset` has valid signatures and the underlying transactions
are properly constructed.