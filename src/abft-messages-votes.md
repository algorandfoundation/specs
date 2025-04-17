# Votes

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