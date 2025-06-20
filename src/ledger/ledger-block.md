$$
\newcommand \BonusDecayInterval {B_{b,\mathrm{decay}}}
\newcommand \MaxProposedExpiredOnlineAccounts {B_{N_\mathrm{e},\max}}
\newcommand \MinBalance {b_\min}
\newcommand \PayoutsMaxBalance {A_{r,\max}}
\newcommand \PayoutsMinBalance {A_{r,\min}}
\newcommand \PayoutsChallengeBits {\Heartbeat_\mathrm{bits}}
\newcommand \PayoutsChallengeGracePeriod {\Heartbeat_\mathrm{grace}}
\newcommand \PayoutsChallengeInterval {\Heartbeat_r}
\newcommand \PayoutMaxMarkAbsent {B_{N_\mathrm{a},\max}}
$$

# Blocks

A _block_ is a data structure that specifies the transition between states.

The data in a block is divided between the _block header_ and its _block body_.

The block header contains the following components:

- The block’s _round_, which matches the round of the state it is transitioning 
into. (The block with round \\( 0 \\) is special in that this block specifies not
a transition but rather the entire initial state, which is called the _genesis state_.
This block is correspondingly called the [_genesis block_](#genesis)). The round
is stored under msgpack key `rnd`.

- The block’s _genesis identifier_ and _genesis hash_, which match the genesis identifier
and hash of the states it transitions between (i.e., they stay constant since the
initial state forwards). The genesis identifier is stored under msgpack key `gen`,
and the genesis hash is stored under msgpack key `gh`.

- The block’s _upgrade vote_, which results in the new upgrade state. The block also
duplicates the upgrade state of the state it transitions into. The msgpack representations
of the upgrade vote components are described in detail below.

- The block's _timestamp_, which matches the timestamp of the state it transitions
into. The timestamp is stored under msgpack key `ts`.

- The block's [_seed_](abft.md#seed), which matches the seed of the state it transitions
into. The seed is stored under msgpack key `seed`.

- The block's _reward updates_, which results in the new reward state. The block
also duplicates the reward state of the state it transitions into. The msgpack representations
of the reward updates components are described in detail below.

- A cryptographic commitment to the block’s _transaction sequence_ (referred also
as _payset_), described below, stored under msgpack key `txn`.

- A cryptographic commitment, using the [SHA-256 hash function](crypto.md#sha256),
to the block’s _transaction sequence_ (referred also as _payset_), described below,
stored under msgpack key `txn256`.

- The block’s _previous hash_, which is the cryptographic hash of the previous block
in the sequence. (The previous hash of the [genesis block](#genesis) is \\( 0 \\)).
The previous hash is stored under msgpack key `prev`.

- The block’s _transaction counter_, which is the total number of transactions issued
prior to this block. This count starts from the first block with a protocol version
that supports the transaction counter. The counter is stored in msgpack field `tc`.

- The block’s _proposer_, which is the address of the account that proposed the
block. The proposer is stored in msgpack field `prp`.

- The block’s _fees collected_ is the sum of all fees paid by transactions in the
block and is stored in msgpack field `fc`.

- The potential _bonus incentive_ is the amount, in μALGO, that may be paid to the
proposer of this block beyond the amount available from fees. It is stored in msgpack
field `bi`. It may be set during a consensus upgrade, or else it must be equal to
the value from the previous block in most rounds, or be \\( 99 \\% \\) of the previous
value (rounded down) if the round of this block is \\( 0 \mod \BonusDecayInterval \\).

- The _proposer payout_ is the actual amount that is moved from the \\( I_f \\) to
the proposer, and is stored in msgpack field `pp`. If the proposer is not eligible,
as described below, the _proposer payout_ **MUST** be \\( 0 \\). The proposer payout
**MUST NOT** exceed

  - The sum of the _bonus incentive_ and half of the _fees collected_.
  - The fee sink balance minus \\( \MinBalance \\).

- The block’s _expired participation accounts_, which contains an _optional_ list of
account addresses. These accounts’ [participation key](../crypto/paricipation.md)
expire by the end of the _current_ round, with exact rules below. The list is stored
in msgpack key `partupdrmv`.

- The block’s _suspended participation accounts_, which contains an _optional_ list
of account addresses. These accounts have not recently demonstrated that they are
available and participating, with exact rules below. The list is stored in msgpack
key `partupdabs`.

A proposer is _eligible_ for bonus payouts if the account’s `IncentiveEligible`
flag is true _and_ its online balance is between \\( \PayoutsMinBalance \\) and
\\( \PayoutsMaxBalance \\).

The _expired participation accounts_ list is valid as long as:

- The participation keys of all the accounts in the slice are expired by the end
of the round;
- The accounts themselves would have been online at the end of the round if they
were not included in the list;
- The number of elements in the list is less than or equal to \\( \MaxProposedExpiredOnlineAccounts \\).
A block proposer may not include all such accounts in the list and may even omit
the list completely.

The _suspended participation accounts_ list is valid if, for each included address,
the account is:

- _Online_;
- Incentive _eligible_;
- Either _absent_ or _failing a challenge_ as of the current round.

An account is _absent_ if its `LastHeartbeat` and `LastProposed` rounds are both
more than \\( 20n \\) rounds before `current`, where \\( n \\) is the reciprocal
of the account’s fraction of online stake.

An account is _failing a challenge_ if:

- The first \\( \PayoutsChallengeBits \\) bits of the account’s address matches the
first \\( \PayoutsChallengeBits \\) bits of an active challenge round’s block seed;
- The active challenge round is between \\( \PayoutsChallengeGracePeriod \\) and
\\( 2\PayoutsChallengeGracePeriod \\) rounds before the current round.

An active challenge round is a round that is \\( 0 \mod \PayoutsChallengeInterval \\).

The length of the list **MUST** not exceed \\( \PayoutMaxMarkAbsent \\).

A block proposer **MAY NOT** include all such accounts in the list and **MAY** even
omit the list completely.

The block body is the block’s transaction sequence (also known as _payset_), which
describes the sequence of updates (transactions) to the account state and box state.

A block is _valid_ if each component is also _valid_. (The genesis block is always
valid).

_Applying_ a _valid_ block to a state produces a new state by updating each of its
components.

The rest of this document defines block validity and state transitions by describing
them for each component.