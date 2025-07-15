$$
\newcommand \PartKey {\mathrm{PartKey}}
\newcommand \VoteKey {\mathrm{vpk}}
\newcommand \SelectionKey {\mathrm{spk}}
\newcommand \StateProofKey {\mathrm{sppk}}
\newcommand \VoteFirstValid {v_\mathrm{fv}}
\newcommand \VoteLastValid {v_\mathrm{lv}}
\newcommand \KeyDilution {\mathrm{KeyDilution}}
\newcommand \NonPart {\mathrm{nonpart}}
\newcommand \LastValidRound {r_\mathrm{lv}}
\newcommand \MaxKeyregValidPeriod {K_{\Delta r,\max}}
$$

# Key Registration Transaction

## Fields

A _key registration_ transaction additionally has the following fields:

| FIELD                   |   MSGPACK    |    TYPE    | OPTIONAL |
|:------------------------|:------------:|:----------:|:--------:|
| Vote Public Key         |  `votekey`   | `[32]byte` |    No    |
| Selection Public Key    |   `selkey`   | `[32]byte` |    No    |
| State Proof Public Key  |  `sprfkey`   | `[64]byte` |    No    |
| Vote First              |  `votefst`   |  `uint64`  |    No    |
| Vote Last               |  `votelst`   |  `uint64`  |    No    |
| Vote Key Dilution       |   `votekd`   |  `uint64`  |    No    |
| Non-Participation       |  `nonpart`   |   `bool`   |   Yes    |

### Vote Public Key

The _vote public key_ \\( \VoteKey \\) is the (root) [Ed25519]() public authentication
key of an account’s participation keys (\\( \PartKey \\)).

### Selection Public Key

The _selection public key_ \\( \SelectionKey \\) is the public [VRF]() key of an
account's participation keys (\\( \PartKey \\)). 

### State Proof Public Key

The _state proof public key_ \\( \StateProofKey \\) is the public commitment to
the account’s State Proof keys \\( \StateProofKey \\).

> If \\( \VoteKey \\), \\( \SelectionKey \\), and \\( \StateProofKey \\) are all
> omitted, the transaction deregisters the account’s participation key set, and as
> a result marks the account as _offline_ (that is, non-participating in the agreement).

### Vote First

The _vote first_ \\( \VoteFirstValid \\) indicates _first valid round_ (inclusive)
of an account’s participation key sets.

### Vote Last

The _vote last_ \\( \VoteLastValid \\) indicates _last valid round_ (inclusive)
of an account’s participation key sets.

### Vote Key Dilution

The _vote key dilution_ defines the number of rounds for generating a new (second-level)
ephemeral participation key. The higher the number, the more “dilution” is added
to the authentication key’s security.

> For further details on the two-level ephemeral key scheme used for consensus participation
> authentication, refer to the Algorand [Participation Key Specification]().

### Non-Participation

The _non-participation_ \\( \NonPart \\) is flag which, when deregistering keys,
specifies whether to mark the account just as _offline_ (if \\( \NonPart \\) is
`false`) or as _non-participatory_ (if \\( \NonPart \\) is `true`).

> The _non-participatory_ status is set to _true_ the account is irreversibly excluded
> from consensus participation (i.e., can no longer be marked as _online_) and from
> the legacy distribution rewards mechanism.

## Semantic

TODO

## Validation

For a _key registration_ transaction to be valid, the following conditions **MUST** apply:

- The elements of the set \\( (\VoteKey, \SelectionKey, \StateProofKey, \KeyDilution) \\)
are **REQUIRED** to be _all present_, or _all omitted_ (clear).

> Providing the _default value_ or the _empty value_, for any of the set members,
> would be interpreted as if these values were omitted.

- \\( \VoteFirstValid \leq \VoteLastValid \\).

- If the set \\( (\VoteKey, \SelectionKey, \StateProofKey, \KeyDilution) \\) is
_clear_, then \\( \VoteFirstValid \\) and \\( \VoteLastValid \\) **MUST** be clear
as well.

- If the set \\( (\VoteKey, \SelectionKey, \StateProofKey, \KeyDilution) \\) is
_not clear_, the following **MUST** apply:

<!-- TODO: Verify the correctness of the following with respect to the implementation -->

  - \\( \VoteFirstValid \leq r + 1 \\) and \\( \VoteLastValid > r \\), where \\( r \\)
  is the current network round (the round of the last block committed).

  - \\( \VoteFirstValid \leq \LastValidRound + 1 \\).

  - \\( \VoteLastValid - \VoteFirstValid < \MaxKeyregValidPeriod \\).

> It is **RECOMMENDED** that \\( \VoteLastValid - \VoteFirstValid \leq 3{,}000{,}000 \\)
> rounds for security reasons, to ensure safe rotation of participation keys.