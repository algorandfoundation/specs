# Trackers

The Ledger [module](https://github.com/algorand/go-algorand/tree/18990e06116efa0ad29008d5879c8e4dcfa51653/ledger) comes
with a set of auxiliary constructs called _Trackers_.

Trackers are state machines that consume the blockchain as an input and evolve accordingly.

Trackers are logically stateless: that is, they can reconstruct their state by consuming
all blocks from the beginning of the blockchain.

As an optimization, the reference implementation allows Trackers to persist state,
to speed up Ledger state reconstruction, without having to browse through every
block from _genesis_.

Trackers are used extensively in `go-algorand` to maintain a read-efficient view of
several Ledger dimensions.

The following is a list of the main Trackers and their specific attributions:

- **Account tracker**\
Tracks accounts state up to a specific round. It provides the following methods:

  - `Lookup(round, address)` looks up the state of the account `address` as of `round`.

  - `AllBalances(round)` returns the set of all account states as of `round`.

  - `Totals(round)` returns the totals of accounts for a specific `round`. Useful
  when querying for total account balance in the [sortition](./crypto.md#cryptographic-sortition).

- **Recent Transactions Tracker**\
It uses the [Transaction Tail](./ledger-nn-transaction-tail.md) to quickly verify
whether a specific transaction, identified by its `txid`, was included in a recent
block.

- **State Proof Verification Tracker**\
Tracks the context required to verify State Proofs (see State Proof [normative specification](crypto.md#state-proof-validity).

- **Voters Tracker**\
Maintains the [vector commitment](./crypto.md#vector-commitment) for the most recent
commitments to online accounts for [State Proofs](crypto.md#state-proofs).

- **catchpointTracker**\
Keeps track of the Catch-Up process (see the node synchronization [non-normative specification](infrastructure-overview.md#node-catchup)).