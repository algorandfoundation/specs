# Messages

Players communicate with each other by exchanging _messages_.

A message is an opaque object containing arbitrary data, save for the fields defined
below.

> For a detailed overview of message composition, whether consensus or other types,
> see the [Algorand Network Overview](./network-overview.md).

## Elementary Data Types

A _period_ \\(p\\) is a 64-bit integer.

A _step_ \\(s\\) is an 8-bit integer.

Steps are named for clarity and are defined as follows:

| STEP          | ENUMERATIVE |
|---------------|-------------|
| \\(Propose\\) | \\(0\\)     |
| \\(Soft\\)    | \\(1\\)     |
| \\(Cert\\)    | \\(2\\)     |
| \\(Late\\)    | \\(253\\)   |
| \\(Redo\\)    | \\(254\\)   |
| \\(Down\\)    | \\(255\\)   |
| \\(Next_s\\)  | \\(s + 3\\) |

The following functions are defined on \\(s\\):

- _Committee Size_: \\(CommitteeSize(s)\\) is a 64-bit integer defined as follows:

  \\[
  CommitteeSize(s) =
  \begin{cases}
  20 & : s = Propose \\\\\\
  2990 & : s = Soft \\\\\\
  1500 & : s = Cert \\\\\\
  500 & : s = Late \\\\\\
  2400 & : s = Redo \\\\\\
  6000 & : s = Down \\\\\\
   5000 & : \text{otherwise}
  \end{cases}
  \\]

- _Committee Threshold_: \\(CommitteeThreshold(s)\\) is a 64-bit integer defined
as follows:

  \\[
  CommitteeThreshold(s) =
  \begin{cases} 
  0 & : s = Propose \\\\\\
  2267 & : s = Soft \\\\\\
  1112 & : s = Cert \\\\\\
  320 & : s = Late \\\\\\
  1768 & : s = Redo \\\\\\
  4560 & : s = Down \\\\\\
  3838 & : \text{otherwise}
  \end{cases}
  \\]

A _proposal-value_ is a tuple \\(v = (I, p, Digest(e), Hash(Encoding(e)))\\) where:

- \\(I\\) is an address (the "original proposer"),
- \\(p\\) is a period (the "original period"),
- \\(Hash\\) is some cryptographic hash function.

The special proposal-value where all fields are the zero-string is called the _bottom
proposal_ \\(\bot\\).

## Votes

Let

- \\(I\\) be an _address_,
- \\(r\\) be a _round_,
- \\(p\\) be a _period_,
- \\(s\\) be a _step_,
- \\(v\\) be a _proposal-value_.

Let \\(x\\) be a canonical encoding of the 5-tuple \\((I, r, p, s, v)\\), and let
\\(x'\\) be a canonical encoding of the 4-tuple \\((I, r, p, s)\\).

Let \\(y\\) be an arbitrary bitstring.

Then we say that the tuple

\\[
(I, r, p, s, v, y)
\\]

is a _vote from \\(I\\) for \\(v\\) at round \\(r\\), period \\(p\\), step \\(s\\)_
(or _a vote from \\(I\\) for \\(v\\) at \\((r, p, s)\\)_), denoted

\\[
Vote(I, r, p, s, v)
\\]

> ⚙️ **IMPLEMENTATION**
>
> Vote [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L152).

Moreover, let \\(L\\) be a ledger where \\(|L| \geq \max\{\delta_b, \delta_s\}\\).

Let

- \\((sk, pk)\\) be a keypair,
- \\(B, \bar{B}\\) be 64-bit integers,
- \\(Q\\) be a 256-bit integer,
- \\(\tau, \bar{\tau}\\) 32-bit integers.

We say that this vote is _valid with respect to_ \\(L\\) (or simply _valid_ if
\\(L\\) is unambiguous) if the following conditions are true:

> ⚙️ **IMPLEMENTATION**
>
> The reference implementation builds an [asynchronous vote verifier](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/asyncVoteVerifier.go#L52),
> which builds a verification pool and under the hood uses two different verifying
> routines: one for [regular unauthenticated votes](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L97),
> and one for [unauthenticated equivocation votes](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L193).

> See the non-normative [Algorand ABFT Overview](./abft-overview.md) for further
> details.

- \\(r \leq |L| + 2\\)

- Let \\(v = (I_{orig}, p_{orig}, d, h)\\).

  - If \\(s = 0\\), then \\(p_{orig} \le p\\).
  - Furthermore, if \\(s = 0\\) and \\(p = p_{orig}\\), then \\(I = I_{orig}\\)$.

<!-- This condition is not enforced in the verifying side, only in the `makeVote()`
side. It would be easy to add this as an additional check. -->

- If \\(s \in \\{Propose, Soft, Cert, Late, Redo\\}\\), \\(v \neq \bot\\). Conversely,
if \\(s = Down\\), \\(v = \bot\\).

- Let

  - \\((pk, B, r_{fv}, r_{lv}) = Record(L, r - \delta_b, I)\\),
  - \\(\bar{B} = Stake(L, r - \delta_b, r)\\),
  - \\(Q = Seed(L, r - \delta_s)\\),
  - \\(\tau = CommitteeThreshold(s)\\)
  - \\(\bar{\tau} = CommitteeSize(s)\\).

  Then

  - \\(Verify(y, x, x', pk, B, \bar{B}, Q, \tau, \bar{\tau}) \neq 0\\),
  - \\(r_{fv} \leq r \leq r_{lv}\\).

Observe that valid votes contain outputs of the \\(Sign\\) procedure; i.e.,
\\(y := Sign(x, x', sk, B, \bar{B}, Q, \tau, \bar{\tau})\\).

> 📎 **EXAMPLE**
>
> Informally, these conditions check the following:
> 
> - The vote is not too far in the future for \\(L\\) to be able to validate.
> 
> - "Propose"-step votes can either propose a new _proposal-value_ for this period
> (\\(p_{orig} = p\\)) or claim to "re-propose" a value originally proposed in an 
> earlier period (\\(p_{orig} < p\\)). But they can't claim to "re-propose" a value
> from a future period. And if the proposal-value is new (\\(p_{orig} = p\\)) then
> the "original proposer" must be the voter.
>
> - The \\(Propose\\), \\(Soft\\), \\(Cert\\), \\(Late\\), and \\(Redo\\) steps
> must vote for an actual proposal. The \\(Down\\) step must only vote for $\bot$.
>
> - The last condition checks that the vote was properly signed by a voter who was
> selected to serve on the committee for this _round_, _period_, and _step_. The
> committee selection process uses the voter's stake and keys as of \\(\delta_b\\)
> rounds before the vote and the seed as of \\(\delta_s\\) rounds before the vote.
> It also checks if the vote's round is within the range associated with the voter's
> participation key.

An _equivocation vote pair_ or _equivocation vote_
\\(Equivocation(I, r, p, s)\\) is a pair of votes that differ in
their proposal values. In other words,

\\[
Equivocation(I, r, p, s) = (Vote(I, r, p, s, v_1), Vote(I, r, p, s, v_2))
\\]

for some \\(v_1 \neq v_2\\).

An equivocation vote pair is _valid with respect to_ \\(L\\) (or simply _valid_
if \\(L\\) is unambiguous) if both of its constituent votes are also valid with
respect to \\(L\\).

## Bundles

Let \\(V\\) be any set of votes and equivocation votes.

We say that \\(V\\) _is a bundle for \\(v\\) in round \\(r\\), period \\(p\\), and
step_ \\(s\\) (or a _bundle for \\(v\\) at_ \\((r, p, s)\\)), denoted \\(Bundle(r, p, s, v)\\).

> ⚙️ **IMPLEMENTATION**
>
> Bundle [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/bundle.go#L46).

Moreover, let \\(L\\) be a ledger where \\(|L| \geq \max\{\delta_b, \delta_s\}\\).

We say that this bundle is _valid with respect to_ \\(L\\) (or simply _valid_ if
\\(L\\) is unambiguous) if the following conditions are true:

> ⚙️ **IMPLEMENTATION**
>
> The reference implementation makes use of an asynchronous [Bundle verifying function](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/bundle.go#L147).

> See the non-normative [Algorand ABFT Overview](../md/abft-overview.md) for further
> details.

- \\(s \neq 0\\) (there are no bundles for the \\(Propose\\) step).

- Every element \\(a_i \in V\\) is valid with respect to \\(L\\).

- \\(|V| \leq CommitteeThreshold(s)\\).

> Intuitively, the largest possible bundle is a bundle where every vote's weight
> is exactly one.

- For any two elements \\(a_i, a_j \in V\\), \\(I_i \neq I_j\\).

<!-- These checks seem to be missing or not explicit in the reference implementation-->

- For any element \\(a_i \in V\\), \\(r_i = r, p_i = p, s_i = s\\).

<!-- These checks seem to be missing or not explicit in the reference implementation-->

- For any element \\(a_i \in V\\), either \\(a_i\\) is a vote and \\(v_i = v\\),
or \\(a_i\\) is an equivocation vote.

- Let \\(w_i\\) be the weight of the signature in \\(a_i\\). Then
\\(\sum_i w_i \geq CommitteeThreshold(s)\\).

## Proposals

Let \\(e = (o, Q)\\) be an entry and \\(y\\) be the output of a \\(Sign\\) procedure.

The pair \\((e, y)\\) is a _proposal_ or a _proposal payload_.

Moreover, let

- \\(L\\) be a ledger where \\(|L| \geq \delta_b\\),
- \\(v = (I, p, h, x)\\) be some proposal-value.

We say that this proposal is _a valid proposal matching \\(v\\) with respect to
\\(L\\)_ (or simply that this proposal _matches \\(v\\)_ if \\(L\\) is unambiguous)
if the following conditions are true:

- \\(ValidEntry(L, e) = 1\\),
- \\(h = Digest(e)\\),
- \\(x = Hash(Encoding(e))\\),
- The seed \\(Q\\) and seed proof are valid as specified in the following section,
- Let \\((pk, B, r_{fv}, r_{lv}) = Record(L, r - \delta_b, I)\\),
  - If \\(p = 0\\), then \\(Verify(y, Q_0, Q_0, pk, 0, 0, 0, 0, 0) \neq 0\\),
- Let \\((pk, B, r_{fv}, r_{lv}) = Record(L, r - \delta_b, I)\\). Then \\(r_{fv} \leq r \leq r_{lv}\\).

If \\(e\\) matches \\(v\\), we write \\(e = Proposal(v)\\).

## Seed

Informally, the protocol interleaves \\(\delta_s\\) seeds in an alternating
sequence. Each seed is derived from a seed \\(\delta_s\\) rounds in the past through
either a hash function or through a VRF, keyed on the entry
proposer. Additionally, every \\(\delta_s\delta_r\\) rounds, the digest of a previous entry
(specifically, from round \\(r-\delta_s\delta_r\\)) is hashed into the result. The seed
proof is the corresponding VRF proof, or 0 if the VRF was not used.

> This section makes use of the \\(VRF.Prove(.)\\), \\(VRF.ProofToHash(.)\\) and
> \\(VRF.Verify(.)\\) cryptographic low-leve functions defined in the reference
> implementation's Algorand Sodium Fork. They respectively output a \\(VRF\\) proof
> and a \\(VRF\\) hash for a given input, and perform verification of a \\(VRF\\)
> run. For details on the input structure and inner workings, please refer to the
> Appendix A in the [Algorand Crypto Specification](./crypto.md).

More formally, suppose \\(I\\) is a correct proposer in round \\(r\\) and period
\\(p\\).

Let

- \\((pk, B, r_{fv}, r_{lv}) = Record(L, r - \delta_b, I)\\),
- \\(sk\\) be the secret key corresponding to \\(pk\\),
- \\(\alpha\\) be a 256-bit integer.

Then \\(I\\) computes the seed proof \\(y\\) for a new entry as follows:

- If \\(p = 0\\):
  - \\(y = VRF.Prove(Seed(L, r-\delta_s), sk)\\),
  - \\(\alpha = Hash(I || VRF.ProofToHash(y))\\).

- If \\(p \ne 0\\):
  - \\(y = 0\\),
  - \\(\alpha = Hash(Seed(L, r-\delta_s))\\).

Now \\(I\\) computes the seed \\(Q\\) as follows:

\\[
Q =
\begin{cases}
  Hash(\alpha || DigestLookup(L, r-\delta_s\delta_r)) & : (r \bmod \delta_s\delta_r) < \delta_s \\\\\\
  Hash(\alpha) & : \text{otherwise}
\end{cases}
\\]

The seed is valid if the following verification procedure succeeds:

1. Let \\((\pk, B, r_{fv}, r_{lv}) = Record(L, r-\delta_b, I)\\); let \\(q_0 = Seed(L, r-\delta_s)\\).

2. If \\(p = 0\\), check \\(VRF.Verify(y, q_0, pk)\\), immediately returning
   failure if verification fails. Let
   \\(q_1 = Hash(I||VRF.ProofToHash(y))\\) and continue to step 4.

3. If \\(p \ne 0\\), let \\(q_1 = \Hash(q_0)\\). Continue.

4. If \\(r \equiv (r \bmod \delta_s) \mod \delta_r\delta_s\\), then check
   \\(Q = Hash(q_1||DigestLookup(L, r-\delta_s\delta_r))\\). Otherwise,
   check \\(Q = q_1\\).

> Round \\(r\\) leader selection and committee selection both use the seed from
\\(r-\delta_s\\) and the balances / public keys from \\(r-\delta_b\\).

> For re-proposals, the period \\(p\\) used in this section is the _original_
period, not the reproposal period.

> For a detailed overview of the seed computation algorithm and some explanatory
> examples, refer to the non-normative [Algorand ABFT Overview](./abft-overview.md).