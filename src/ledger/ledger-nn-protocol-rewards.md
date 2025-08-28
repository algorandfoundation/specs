# Protocol Rewards

The Algorand protocol has two reward systems:

1. Distribution Rewards (Legacy)

1. Staking Rewards

Rewards are distributed during the final stage of block assembly (in both systems).

> The rewards systems are not mutually exclusive.

## Distribution Rewards (Legacy)

The first reward system grants ALGO rewards to all the accounts, unless opted out
of rewards, through a passive distribution of ALGO from the Rewards Pool, regardless
of their participation in the consensus. The reward amount is proportional to the
accounts’ ALGO balance.
 
Rewards distributed through this system are claimed and added to the account’s balance
on each account state change (e.g., sending or receiving a transaction).

> This system is disabled on MainNet and is kept for legacy and retro-compatibility
> reasons.

{{#include ../_include/styles.md:impl}}
> Distribution rewards [reference implementation](https://github.com/algorand/go-algorand/blob/a81d54fb36c16c2f2f44cc5d153f358105a63317/data/bookkeeping/block.go#L337).

## Staking Rewards

The second reward system grants ALGO rewards to accounts actively participating in
the consensus protocol, if they meet eligibility criteria when selected as block
proposers (see the following section for further details). The reward amount per
block depends on the fee collected from the transactions included in the block,
and an exponentially decaying bonus.

Rewards distributed through this system are instantly added to the block proposer
balance, in the proposed block.

> Staking rewards [reference implementation](https://github.com/algorand/go-algorand/blame/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/ledger/eval/eval.go#L1511-L1612).