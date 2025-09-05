$$
\newcommand \Proven {\mathrm{Proven}}
\newcommand \W {\mathrm{Weight}}
\newcommand \StateProof {\mathrm{SP}}
\newcommand \StateProofInterval {\delta_\StateProof}
\newcommand \StateProofVotersLookback {\delta_{\StateProof,b}}
\newcommand \StateProofTopVoters {N_\StateProof}
\newcommand \StateProofStrengthTarget {KQ_\StateProof}
\newcommand \StateProofWeightThreshold {f_\StateProof}
\newcommand \RewardUnit {U_r}
$$

# State Proofs

## Message

A State Proof _message_ for rounds
\\( (X \cdot \StateProofInterval, \ldots, (X+1) \cdot \StateProofInterval] \\)
for some number \\( X \\), contains the following components:

- Light block headers commitment for rounds
\\( (X \cdot \StateProofInterval, \ldots, (X+1) \cdot \StateProofInterval] \\),
under msgpack key `b`.

- First attested round which would be equal to \\( X \cdot \StateProofInterval + 1 \\),
under msgpack key `f`.

- Last attested round which would be equal to \\( (X+1) \cdot \StateProofInterval \\),
under msgpack key `l`.

- Participant commitment used to verify state proof for rounds
\\( ((X+1) \cdot \StateProofInterval, \ldots, (X+2) \cdot \StateProofInterval] \\),
under msgpack key `v`.

- The value \\( \ln(Proven\W) \\) with \\( 16 \\) bits of precision that would be
used to verify State Proof for rounds
\\( ((X+1) \cdot \StateProofInterval, \ldots, (X+2) \cdot \StateProofInterval] \\),
under msgpack key `P`. This field is calculated based on the total weight of the
participants [see state-proof-transaction](./ledger-txn-state-proof.md)

## Tracking

Each block header keeps track of the state needed to construct, validate, and record
State Proofs.

This tracking data is stored in a map under the msgpack key `spt` in the block header.
The type of the State Proof indexes the map; at the moment, only type \\( 0 \\)
is supported. In the future, other types of state proofs might be added.

For type \\( 0 \\):

- \\( \StateProofStrengthTarget = 256 \\),
- \\( \StateProofWeightThreshold = 2^{32} \times \frac{30}{100} \\) (as the fraction numerator out of \\( 2^{32} \\)),
- \\( \StateProofTopVoters = 1024 \\),
- \\( \StateProofInterval = 256 \\),
- \\( \StateProofVotersLookback = 16 \\).

The value of the tracking data is a msgpack map with three elements:

- Under key `n`, the next expected round of a State Proof should be formed. When
upgrading from an earlier consensus protocol to a protocol that supports State Proofs,
the `n` field is set to the lowest value such that `n` is a multiple of \\( \StateProofInterval \\)
and so that the `n` is at least the first round of the new protocol (supporting State Proofs)
plus \\( \StateProofVotersLookback + \StateProofInterval \\). This field is set in
every block.

- Under key `v`, the root of the _vector commitment_ to an array of participants
that are eligible to vote in the State Proof at round \\( \StateProofInterval \\)
from the current block. Only blocks whose round number is a multiple of \\( \StateProofInterval \\)
have a non-zero `v` field.

- Under key `t`, the total online stake at round \\( \StateProofInterval \\) (with
pending rewards).

The participants committed to by the _vector commitment_ are chosen in a specific
fashion:

- First off, because it takes some time to collect all of the online participants
(more than the target assembly time for a block), the set of participants and total
online non-expired stake appearing in a commitment in block at round \\( r \\) are
actually based on the account state from round \\( r-\StateProofVotersLookback \\).

- The participants are sorted by the number of μALGO they currently hold (including
any pending rewards). This enables more compact proofs of pseudorandomly chosen participants
weighted by their μALGO holdings. Only accounts in the online state are included
in this list of participants.

- To limit the worst-case size of this _vector commitment_, the array of participants
contains just the top \\( \StateProofTopVoters \\) participants. Efficiently computing
the top \\( \StateProofTopVoters \\) accounts by their μALGO balance is difficult
in the presence of pending rewards. Thus, to make this top-\\( \StateProofTopVoters \\)
calculation more efficient, we choose the top accounts based on a normalized balance,
denoted below by \\( n_I \\).

The normalized balance is a _hypothetical balance_: consider an account \\( I \\)
with current balance \\( a_I \\). If an account had a balance \\( n_I \\) in the
genesis block, and did not perform any transactions since then, then its balance
by the current round (when rewards are included) will be \\( a_I \\), except perhaps
due to rounding effects.

In more detail, let \\( r^\ast_I \\) be the last round in which a transaction touched
account \\( I \\) (and therefore all pending rewards were added to it). Consider
the following quantities, as defined in the [Account State](./ledger-account-state.md):

- The raw balance \\( a_I \\) of the account \\( I \\) at round \\( r^\ast_I \\)
is its total balance on that round.

- The rewards base \\( a^\prime_I \\) is meant to capture the total rewards allocated
to all accounts up to round \\( r^\ast_I \\), expressed as a fraction of the total
stake (with limited precision as described below).

Given these two quantities, the normalized balance of an online account \\( I \\)
is \\( \frac{a_I}{(1+a^\prime_I)} \\).

{{#include ../_include/styles.md:example}}
> For example, if the total amount of rewards distributed up to round \\( r^\ast_I \\)
> is \\( 20\\% \\) of the total stake, then the normalized balance is \\( \frac{a_I}{1.2} \\).

To limit the required precision in this calculation, the system uses a parameter
\\( \RewardUnit \\) that specifies the rewards-earning unit, namely, accounts only
earn rewards for a whole number of \\( \RewardUnit \\) μALGO. (Currently \\( \RewardUnit = 1{,}000{,}000 \\),
so the rewards-earning unit is \\( 1 \\) ALGO.)

The parameter \\(a^\prime_I \\) above is an integer such that \\( \frac{a^\prime_I}{\RewardUnit} \\)
is the desired fraction, rounded down to the precision of \\( \frac{1}{\RewardUnit} \\).

The normalized balance is computed as:

$$
n_I = \left\lfloor \frac{a_I \cdot \RewardUnit}{(a^\prime_I + \RewardUnit)} \right\rfloor.
$$

## Parameters

- To limit the resources allocated for creating State Proofs, State Proof parameters
are set to \\( \StateProofTopVoters = 1024 \\),  \\( \StateProofInterval = 256 \\),
and \\( \StateProofVotersLookback = 16 \\).

- Setting \\( \StateProofStrengthTarget = \mathrm{target_{PQ}} \\) to achieve _post-quantum
security_ for State Proofs. For further details, refer to the State Proofs [normative
- specification](../crypto/crypto-state-proofs.md).

- Algorand assumes that at least \\( 70\\% \\) of the participating stake is honest.
Under this assumption, there can’t be a malicious State Proof that the _verifier_
would accept and have a signed weight of more than \\( 30\\% \\) of the total online
stake. Hence, we set \\( \StateProofWeightThreshold = 2^{32} \times \frac{30}{100} \\)
(as the numerator of a fraction out of \\( 2^{32} \\)).
