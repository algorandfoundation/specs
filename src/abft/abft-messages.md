{{#include ../_include/tex-macros/domain-separators.md}}

$$
\newcommand \Propose {\mathit{propose}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
\newcommand \Next {\mathit{next}}
\newcommand \CommitteeSize {\mathrm{CommitteeSize}}
\newcommand \CommitteeThreshold {\mathrm{CommitteeThreshold}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Digest {\mathrm{Digest}}
\newcommand \Encoding {\mathrm{Encoding}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \pk {\mathrm{pk}}
\newcommand \sk {\mathrm{sk}}
\newcommand \fv {\text{first}}
\newcommand \lv {\text{last}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Equivocation {\mathrm{Equivocation}}
\newcommand \Seed {\mathrm{Seed}}
\newcommand \Record {\mathrm{Record}}
\newcommand \Stake {\mathrm{Stake}}
\newcommand \Sign {\mathrm{Sign}}
\newcommand \Verify {\mathrm{Verify}}
\newcommand \abs[1] {\lvert #1 \rvert}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \ValidEntry {\mathrm{ValidEntry}}
\newcommand \VRF {\mathrm{VRF}}
\newcommand \Prove {\mathrm{Prove}}
\newcommand \ProofToHash {\mathrm{ProofToHash}}
\newcommand \DigestLookup {\mathrm{DigestLookup}}
$$

# Messages

Players communicate with each other by exchanging _messages_.

A message is an opaque object containing arbitrary data, save for the fields defined
below.

Let \\( \Hash \\) be the protocol hash function.

Domain separators are defined in the [cryptographic specification](../crypto/crypto-domain-separators.md).

> [!NOTE]
> For a detailed overview of message composition, whether consensus or other types,
> see the [Algorand Network non-normative section](../network/network-overview.md).

## Elementary Data Types

A _period_ \\( p \\) is a 64-bit integer.

A _step_ \\( s \\) is an 8-bit integer.

Steps are named for clarity and are defined as follows:

|       STEP       |  ENUMERATIVE  |
|:----------------:|:-------------:|
| \\( \Propose \\) |   \\( 0 \\)   |
|  \\( \Soft \\)   |   \\( 1 \\)   |
|  \\( \Cert \\)   |   \\( 2 \\)   |
|  \\( \Late \\)   |  \\( 253 \\)  |
|  \\( \Redo \\)   |  \\( 254 \\)  |
|  \\( \Down \\)   |  \\( 255 \\)  |
| \\( \Next_s \\)  | \\( s + 3 \\) |

The following functions are defined on \\( s \\):

- \\( \CommitteeSize(s) \\) is a 64-bit integer defined as follows:

$$
\CommitteeSize(s) = \left\\{
\begin{array}{rl}
     20 & : s = \Propose \\\\
   2990 & : s = \Soft \\\\
   1500 & : s = \Cert \\\\
    500 & : s = \Late \\\\
   2400 & : s = \Redo \\\\
   6000 & : s = \Down \\\\
   5000 & : \text{otherwise}
\end{array}
\right.
$$

- \\( \CommitteeThreshold(s) \\) is a 64-bit integer defined as follows:

$$
\CommitteeThreshold(s) = \left\\{
\begin{array}{rl}
     0 & : s = \Propose \\\\
  2267 & : s = \Soft \\\\
  1112 & : s = \Cert \\\\
   320 & : s = \Late \\\\
  1768 & : s = \Redo \\\\
  4560 & : s = \Down \\\\
  3838 & : \text{otherwise}
\end{array}
\right.
$$

A _proposal-value_ associated with a _proposal payload_ \\( \pi \\) containing entry
\\( e \\) is a tuple \\( v = (I, p, d, h) \\) where:

- \\( I \\) is an address (the "original proposer"),

- \\( p \\) is a period (the "original period"),

- \\( d = \Digest(e) \\) is the entry digest,

- \\( h = \Hash(\Domain{PL} || \Encoding(\pi)) \\) is the payload commitment.

The special proposal-value where all fields are the zero-string is called the _bottom
proposal_ \\( \bot \\).

## Votes

Let

- \\( I \\) be an _address_,

- \\( r \\) be a _round_,

- \\( p \\) be a _period_,

- \\( s \\) be a _step_,

- \\( v \\) be a _proposal-value_.

Let \\( y \\) be an arbitrary bitstring.

Then we say that the tuple

$$
(I, r, p, s, v, y)
$$

is a _vote from \\( I \\) for \\( v \\) at round \\( r \\), period \\( p \\), step
\\( s \\)_ (or _a vote from \\( I \\) for \\( v \\) at \\( (r, p, s) \\)_), denoted

$$
\Vote(I, r, p, s, v)
$$

Two votes with equal \\( (I, r, p, s, v) \\) are the _same vote_, regardless of
\\( y \\); membership of a vote in a set is evaluated on this identity.

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> Vote [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L152).

Moreover, let \\( L \\) be a ledger.

Let

- \\( (\sk, \pk) \\) be a keypair,
- \\( B, \bar{B} \\) be 64-bit integers,
- \\( Q \\) be a 256-bit integer,
- \\( \tau, \bar{\tau} \\) 32-bit integers.

Let \\( x = \Domain{VO} || \Encoding((I, r, p, s, v)) \\), and
let \\( x' = \Domain{AS} || \Encoding((Q, r, p, s)) \\).

We say that this vote is _valid with respect to_ \\( L \\) (or simply _valid_ if
\\( L \\) is unambiguous) if the following conditions are true:

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> The reference implementation builds an [asynchronous vote verifier](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/asyncVoteVerifier.go#L52),
> which builds a verification pool and under the hood uses two different verifying
> routines: one for [regular unauthenticated votes](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L97),
> and one for [unauthenticated equivocation votes](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L193).

> [!NOTE]
> See the [Algorand ABFT non-normative section](./non-normative/abft-nn.md) for further
> details.

- \\( r \leq |L| + 2 \\)

- Let \\( v = (I_{orig}, p_{orig}, d, h )\\).
  - If \\( s = 0 \\), then \\( p_{orig} \le p \\).
  - Furthermore, if \\( s = 0 \\) and \\( p = p_{orig} \\), then \\( I = I_{orig} \\).

- If \\( s \in \\{ \Propose, \Soft, \Cert\\} \\), then \\( v \neq \bot \\).

- Let
  - \\( (\pk, B, r_\fv, r_\lv) = \Record(L, r - \delta_b, I) \\),
  - \\( \bar{B} = \Stake(L, r - \delta_b, r) \\),
  - \\( Q = \Seed(L, r - \delta_s) \\),
  - \\( \tau = \CommitteeThreshold(s) \\),
  - \\( \bar{\tau} = \CommitteeSize(s) \\).

  Then
  - \\( \Verify(y, x, x', \pk, B, \bar{B}, Q, \tau, \bar{\tau}) \neq 0 \\),
  - \\( r_\fv \leq r \leq r_\lv \\).

Observe that valid votes contain outputs of the \\( \Sign \\) procedure; i.e.,
\\( y := \Sign(x, x', \sk, B, \bar{B}, Q, \tau, \bar{\tau}) \\).

A correct player emits only votes with \\( v \neq \bot \\) in \\( \Propose \\),
\\( \Soft \\), \\( \Cert \\), \\( \Late \\), and \\( \Redo \\). Conversely, if
\\( s = \Down \\), \\( v = \bot \\). Either value is permitted in \\( \Next_s \\).

Informally, these conditions check the following:

- The vote is not too far in the future for \\( L \\) to be able to validate.

- "Propose"-step votes can either propose a new _proposal-value_ for this period
(\\( p_{orig} = p \\)) or claim to "re-propose" a value originally proposed in an
earlier period (\\( p_{orig} < p \\)). But they can't claim to "re-propose" a value
from a future period. And if the proposal-value is new (\\( p_{orig} = p \\)) then
the "original proposer" must be the voter.

- The \\( \Propose \\), \\( \Soft \\), and \\( \Cert \\) steps must vote for an
actual proposal. Correct players also \\( \Late \\)-vote and \\( \Redo \\)-vote only
for an actual proposal, and \\( \Down \\)-vote only for \\( \bot \\).

- The last condition checks that the vote was properly signed by a voter who was
selected to serve on the committee for this _round_, _period_, and _step_. The
committee selection process uses the voter's stake and keys as of \\( \delta_b \\)
rounds before the vote and the seed as of \\(\delta_s\\) rounds before the vote.
It also checks if the vote's round is within the range associated with the voter's
participation key.

An _equivocation vote pair_ or _equivocation vote_
\\( \Equivocation(I, r, p, s) \\) is a pair of votes that differ in
their proposal values. In other words,

$$
\begin{aligned}
\Equivocation(I, r, p, s)
 = (&\Vote(I, r, p, s, v_1), \\\\
    &\Vote(I, r, p, s, v_2))
\end{aligned}
$$

for some \\( v_1 \neq v_2 \\).

An equivocation vote pair is _valid with respect to_ \\( L \\) (or simply _valid_
if \\( L \\) is unambiguous) if both of its constituent votes are also valid with
respect to \\( L \\).

An equivocation vote pair is transmitted as a single record carrying the
common \\( (I, r, p, s) \\) and credential, with the two proposal-values and
their two signatures.

## Bundles

Let \\( V \\) be any set of votes and equivocation votes.

We say that \\( V \\) _is a bundle for \\( v \\) in round \\( r \\), period \\( p \\),
and step_ \\( s \\) (or a _bundle for \\( v \\) at_ \\( (r, p, s) \\)), denoted
\\( \Bundle(r, p, s, v) \\).

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> Bundle [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/bundle.go#L46).

A bundle is transmitted as \\( (r, p, s, v) \\) together with its vote and
equivocation-vote records; a vote record carries only the sender, credential,
and signature, the omitted fields being the bundle's, while an equivocation
record is transmitted as above.

Moreover, let \\( L \\) be a ledger.

We say that this bundle is _valid with respect to_ \\( L \\) (or simply _valid_ if
\\( L \\) is unambiguous) if the following conditions are true:

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> The reference implementation makes use of an asynchronous [Bundle verifying function](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/bundle.go#L147).

> [!NOTE]
> See the [Algorand ABFT non-normative section](./non-normative/abft-nn.md) for
> further details.

- \\( s \neq \Propose \\).

- \\( |V| \leq \CommitteeThreshold(s) \\).

- Every element \\( a_i \in V \\) is valid with respect to \\( L \\).

- For any two elements \\( a_i, a_j \in V \\), \\( I_i \neq I_j \\).

- For any element \\( a_i \in V \\), \\( r_i = r, p_i = p, s_i = s \\).

- For any element \\( a_i \in V \\), either \\( a_i \\) is a vote and \\( v_i = v \\),
or \\( a_i \\) is an equivocation vote.

- Let \\( w_i \\) be the weight of \\( a_i \\), where an equivocation vote has the
common weight of its constituent votes. Then
\\( \sum_i w_i \geq \CommitteeThreshold(s) \\).

## Proposals

Let \\( e = (o, Q) \\) be an entry, \\( \gamma \\) a seed proof, \\( I_o \\) an
address, and \\( p_o \\) a period.

The tuple \\( \pi = (e, \gamma, p_o, I_o) \\) is a _proposal_ or _proposal payload_.

Moreover, let

- \\( L \\) be a ledger,

- \\( r \\) be the round being decided,

- \\( v \\) be some proposal-value.

We say that this proposal is _a valid proposal matching \\( v \\) with respect to
\\( L \\)_ (or simply that this proposal _matches \\( v \\)_ if \\( L \\) is unambiguous)
if the following conditions are true:

- \\( \ValidEntry(L, o) = 1 \\),

- \\( v = (I_o, p_o, \Digest(e), \Hash(\Domain{PL} || \Encoding(\pi))) \\),

- The entry's round is \\( r \\),

- The seed \\( Q \\) and seed proof \\( \gamma \\) are valid as specified in the following section,

- If \\( e \\) identifies a proposer, that proposer is \\( I_o \\).

If \\( \pi \\) matches \\( v \\), we write \\( \pi = \Proposal(v) \\).

A proposal payload is transmitted, and relayed, as a pair \\( (\pi, a) \\),
where \\( a \\) is either empty or a proposal-vote whose proposal-value matches
\\( \pi \\), called the payload's _authenticator_. A player receiving such a
pair processes \\( a \\), if present, before \\( \pi \\).

## Seed

Informally, the protocol interleaves \\( \delta_s \\) seeds in an alternating
sequence. Each seed is derived from a seed \\( \delta_s \\) rounds in the past through
either a hash function or through a \\( \VRF \\), keyed on the entry
proposer. Additionally, every \\( \delta_s\delta_r \\) rounds, the digest of a previous
entry (specifically, from round \\( r-\delta_s\delta_r \\)) is hashed into the result.
The seed proof is the corresponding VRF proof, or 0 if the \\( \VRF \\) was not used.

More formally, suppose \\( I \\) is a correct proposer in round \\( r \\) and period
\\( p \\).

Let

- \\( (\pk, B, r_\fv, r_\lv) = \Record(L, r - \delta_b, I) \\),

- \\( \sk_{\mathrm{sel}} \\) be the \\( \VRF \\) secret key associated with \\( \pk \\),

- \\( q_0 = \Seed(L, r - \delta_s) \\),

- \\( \alpha \\) be a 256-bit integer.

Then \\( I \\) computes the seed proof \\( \gamma \\) for a new entry as follows:

- If \\( p = 0 \\):
  - \\( \gamma = \VRF.\Prove(\Domain{SD} || q_0, \sk_{\mathrm{sel}}) \\),
  - \\( z = \VRF.\ProofToHash(\gamma) \\),
  - \\( \alpha = \Hash(\Domain{PS} || \Encoding((I, z))) \\).

- If \\( p \ne 0 \\):
  - \\( \gamma = 0 \\),
  - \\( \alpha = \Hash(\Domain{SD} || q_0) \\).

Now \\( I \\) computes the seed \\( Q \\) as follows:

$$
Q = \left\\{
\begin{array}{rl}
  \Hash(\Domain{PS} || \Encoding((\alpha, \DigestLookup(L, r-\delta_s\delta_r)))) & : (r \bmod \delta_s\delta_r) < \delta_s \\\\
  \Hash(\Domain{PS} || \Encoding((\alpha, 0))) & : \text{otherwise}
\end{array}
\right.
$$

where \\( 0 \\) denotes the zero digest.

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> Seed computation [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/proposal.go#L155).

The seed is valid if the following verification procedure succeeds:

1. Let \\( (\pk, B, r_\fv, r_\lv) = \Record(L, r-\delta_b, I) \\);
let \\( \pk_{\mathrm{sel}} \\) be the \\( \VRF \\) public key associated with
\\( \pk \\), and
let \\( q_0 = \Seed(L, r-\delta_s) \\).

1. If \\( p = 0 \\), check \\( \VRF.\Verify(\gamma, \Domain{SD} || q_0, \pk_{\mathrm{sel}}) = 1 \\), immediately
returning failure if verification fails. Let \\( q_1 = \Hash(\Domain{PS} || \Encoding((I, \VRF.\ProofToHash(\gamma)))) \\)
and continue to step 4.

1. If \\( p \ne 0 \\), let \\( q_1 = \Hash(\Domain{SD} || q_0) \\). Continue.

1. If \\( (r \bmod \delta_s\delta_r) < \delta_s \\), then check
\\( Q = \Hash(\Domain{PS} || \Encoding((q_1, \DigestLookup(L, r-\delta_s\delta_r)))) \\). Otherwise,
check \\( Q = \Hash(\Domain{PS} || \Encoding((q_1, 0))) \\).

> [!NOTE]
> Round \\( r \\) leader selection and committee selection both use the seed from
> \\( r-\delta_s \\) and the balances / public keys from \\( r-\delta_b \\).

> [!NOTE]
> For re-proposals, the period \\( p \\) used in this section is the _original_
> period, not the reproposal period.

> [!NOTE]
> For a detailed overview of the seed computation algorithm and some explanatory
> examples, refer to the Algorand ABFT [non-normative specification](./non-normative/abft-nn.md).
