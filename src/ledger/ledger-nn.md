# Algorand Ledger Overview

The following is a _non-normative_ specification of the _Algorand Ledger_.

The Algorand Ledger consists of

- The _Account Table_, which records the current state of the Ledger as an aggregation
of individual accounts' states,

- The _Blockchain_, which records the history of the accounts’ states updates since
the _genesis block_ up to the current state.

This chapter aids implementors and readers in understanding the Ledger component,
as well as bridging the gap between the [normative specification](ledger.md)
and the `go-algorand` [reference implementation](https://github.com/algorand/go-algorand).

Whenever possible, we illustrate how specific subcomponents may be implemented,
providing design patterns from the reference implementation.

Besides the actual [Ledger](ledger.md) as an ordered sequence of [blocks](ledger.md#blocks),
several subcomponents are defined to look up, commit, validate, and assemble said
blocks and their corresponding certificates.

Some constructs are built to optimize specific fields look up in these blocks for
a given [round](ledger.md#round), or to get the state implicitly defined by an
aggregate of their history up to a certain round. These constructs are called _Trackers_,
and their usage and implementation details are addressed in the [corresponding section](#./ledger-nn-trackers,md).

This chapter also includes the [_Transaction Pool_](#./ledger-nn-transaction-pool.md),
a queue of transactions that plays a key role in the assembly of a new block, the
[_Transaction Tail_](ledger-nn-transaction-tail.md) used for efficient deduplication,
and a dive into the protocol [_Rewards_](./ledger-nn-rewards.md) system.
