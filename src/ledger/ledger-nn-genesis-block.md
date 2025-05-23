# Genesis Block

> This section is directly derived from the `go-algorand` reference implementation.

The _genesis block_ defines the Algorand “universe”, which is initialized with:

- The initial account states (`GenesisAllocation)`, which includes the ALGO balance
and the initial consensus participation state (and keys),

- The initial consensus protocol version (`GenesisProto`),

- The special addresses (`FeeSink` and `RewardsPool`),

- The schema of the Ledger.

{{#include ../.include/styles.md:impl}}
> `Genesis` type definition in the [reference implementation](https://github.com/algorand/go-algorand/blame/18990e06116efa0ad29008d5879c8e4dcfa51653/data/bookkeeping/genesis.go#L45).

{{#include ../.include/styles.md:impl}}
> `GenesisBalances` type definition in the [reference implementation](https://github.com/algorand/go-algorand/blame/18990e06116efa0ad29008d5879c8e4dcfa51653/data/bookkeeping/genesis.go#L155).
> It contains the information needed to generate a new Ledger:
>
> - `Balances`: a map with the account data for each address,
> - `FeeSink`: address where fees are collected,
> - `RewardsPool`: address holding distribution rewards (legacy),
> - `Timestamp`: time when the object is created.

## Genesis Block Example

The following is the Algorand MainNet _genesis block_:

```json
{{#include ../.include/genesis-block.json}}
```
