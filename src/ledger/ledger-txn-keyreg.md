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

- The _vote public key_ \\( \VoteKey \\), encoded as msgpack field `votekey`, is
the (root) public authentication key of an account's participation keys (\\( \PartKey \\)).

- The _selection public key_ \\( \SelectionKey \\), encoded as msgpack field `selkey`,
is the public [VRF]() key of an account's participation keys (\\( \PartKey \\)). 

- The _state proof public key_ \\( \StateProofKey \\), encoded as msgpack field `sprfkey`,
is the 64-bytes public commitment to the account's State Proof keys \\( \StateProofKey \\).

> If \\( \VoteKey \\), \\( \SelectionKey \\), and \\( \StateProofKey \\) are all
> omitted, the transaction deregisters the account's participation key set and as
> a result marks the account as _offline_ (that is, non-participating in the agreement).

- The _vote first_ \\( \VoteFirstValid \\), encoded as msgpack field `votefst`, is
a 64-bit unsigned integer that indicates _first valid round_ (inclusive) of an account's
participation key sets.

- The _vote last_ \\( \VoteLastValid \\), encoded as msgpack field `votelst`, is
a 64-bit unsigned integer that indicates _last valid round_ (inclusive) of an account's
participation key sets.

- The _vote key dilution_ \\( \KeyDilution \\), encoded as msgpack field `votekd`,
is a 64-bit unsigned integer that defines the number of rounds for generating a new
(second level) ephemeral participation key. The higher the number, the more “dilution”
added to the authentication key’s security.

> For further details on the two-level ephemeral key scheme used for consensus participation
> authentication, refer to the Algorand [Participation Key Specification]().

- The _non participation flag_ \\( \NonPart \\), encoded as msgpack field `nonpart`,
is an **OPTIONAL** boolean flag which, when deregistering keys, specifies whether
to mark the account just as _offline_ (if \\( \NonPart \\) is _false_) or as _non-participatory_
(if \\( \NonPart \\) is _true_).

> The _non-participatory_ status is set to _true_ the account is irreversibly excluded
> from consensus participation (i.e., can no longer be marked as _online_) and from
> the legacy distribution rewards mechanism.

## Semantic

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
  is the current network round (the round of the last block commited).

  - \\( \VoteFirstValid \leq \LastValidRound + 1 \\).

  - \\( \VoteLastValid - \VoteFirstValid < \MaxKeyregValidPeriod \\).

> It is **RECOMMENDED** that \\( \VoteLastValid - \VoteFirstValid \leq 3{,}000{,}000 \\)
> rounds for security reasons, to ensure safe rotation of participation keys.