# Trackers

The Ledger [module](https://github.com/algorand/go-algorand/tree/18990e06116efa0ad29008d5879c8e4dcfa51653/ledger)
includes a collection of auxiliary components known as _Trackers_.

Trackers are state machines that evolve by consuming blocks from the blockchain. 

Although logically stateless, meaning Trackers can rebuild their state from scratch
by replaying all blocks since the _genesis block_ every time, the reference implementation
designs them to persist their state to speed up Ledger reconstruction.

Trackers are widely used in `go-algorand` to maintain efficient, read-optimized
views over different aspects of Ledger state.

Below is an overview of the main Trackers and their responsibilities:

- **Account Tracker**\
Maintains account states up to a given round. Key methods include:

  - `Lookup(round, address)`: Retrieves the state of the account (`address`) at the
  specified `round`.

  - `AllBalances(round)`: Returns all account states at the specified `round`.

  - `Totals(round)`: Returns aggregate account totals for a given `round`, which
  is useful when querying for total account balance in the [cryptographic sortition](../crypto.md#cryptographic-sortition).

- **Recent Transactions Tracker**\
Uses the [Transaction Tail](ledger-nn-transaction-tail.md) to efficiently check
whether a given transaction ID (`txid`) was included in a recent block.

- **State Proof Verification Tracker**\
Maintains the necessary context to verify State Proofs (see State Proof [normative specification](../crypto.md#state-proof-validity).

- **Voters Tracker**\
Tracks the [vector commitment](../crypto.md#vector-commitment) representing the most
recent set of online accounts participating in the [State Proofs](../crypto.md#state-proofs).

- **Catchpoint Tracker**\
Monitors the Catch-Up process used during node synchronization (see the [non-normative specification](infrastructure-overview.md#node-catchup)).