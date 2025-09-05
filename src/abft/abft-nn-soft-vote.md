{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \Priority {\mathrm{Priority}}
\newcommand \VRF {\mathrm{VRF}}
\newcommand \ProofToHash {\mathrm{ProofToHash}}
\newcommand \SoftVote {\mathrm{SoftVote}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Sortition {\mathrm{Sortition}}
\newcommand \Broadcast {\mathrm{Broadcast}}
\newcommand \RetrieveProposal {\mathrm{RetrieveProposal}}
\newcommand \DynamicFilterTimeout {\mathrm{DynamicFilterTimeout}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Prop {\mathit{propose}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \loh {\mathit{lowestObservedHash}}
\newcommand \vt {\mathit{vote}}
\newcommand \ph {\mathit{priorityHash}}
\newcommand \c {\mathit{credentials}}
$$

# Soft Vote

The soft vote stage (also known as _"filtering"_) filters the proposal-value candidates
available for the round, selecting the one with the highest priority to vote for.

## Priority Function

Let \\( \Priority \\) be the function that determines which proposal-value to
_soft-vote_ for this round, as defined in the [normative section](./abft-player-state.md#special-values):

<!-- TODO: Replace with anchored include once the normative section is merged -->
$$
\Priority(v) = \min_{i \in [0, w_j)} \left\\{ \Hash \left( \VRF.\ProofToHash(y) || I_j || i \right) \right\\}
$$

Where:

- \\( v \\) is a _proposal value_ for this round,
- \\( I_j \\) is the _proposer_ address identified by the subscript \\( j \\),
- \\( w_j \\) is the weight of the credentials for \\( v \\) by proposer \\( I_j \\),
- \\( y \\) is the \\( \VRF \\) proof as computed by proposer \\( I_j \\) using
their \\( \VRF \\) secret key.

The function selects the minimum among a set of \\( w_j \\) hash values calculated
as \\(\Hash \left(\VRF.\ProofToHash(y) || I_j || i \right)\\), with \\(i \in [0, w_j)\\).

The higher the credentials’ weight \\( w_j \\), the larger the set, the higher the
chances for the proposer \\( I_j \\) to get the lowest value among all the players
for this round.

## Algorithm

---

\\( \textbf{Algorithm 4} \text{: Soft Vote} \\)

<!-- markdownlint-disable MD013 -->
$$
\begin{aligned}
&\text{1: } \PSfunction \SoftVote() \\\\
&\text{2: } \quad \loh \gets \infty \\\\
&\text{3: } \quad v \gets \bot \\\\
&\text{4: } \quad \PSfor \vt_p \in V^\ast \PSdo \PScomment{The subset of votes corresponding to proposals} \\\\
&\text{5: } \quad \quad \ph \gets \Priority(\vt_p)  \\\\
&\text{6: } \quad \quad \PSif \ph < \loh \PSthen \\\\
&\text{7: } \quad \quad \quad \loh \gets \ph \\\\
&\text{8: } \quad \quad \quad v \gets \vt_p \\\\
&\text{9: } \quad \quad \PSendif \\\\
&\text{10:} \quad \PSendfor \\\\
&\text{11:} \quad \PSif \loh < \infty \PSthen \\\\
&\text{12:} \quad \quad \PSfor a \in A \PSdo \\\\
&\text{13:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Soft) \\\\
&\text{14:} \quad \quad \quad \PSif \c_j > 0 \PSthen \\\\
&\text{15:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \Soft, v, \c)) \\\\
&\text{16:} \quad \quad \quad \quad \PSif \RetrieveProposal(v) \PSthen \\\\
&\text{17:} \quad \quad \quad \quad \quad \\Broadcast(\RetrieveProposal(v)) \\\\
&\text{18:} \quad \quad \quad \quad \PSendif \\\\
&\text{19:} \quad \quad \quad \PSendif \\\\
&\text{20:} \quad \quad \PSendfor \\\\
&\text{21:} \quad \PSendif \\\\
&\text{22: } \PSendfunction
\end{aligned}
$$
<!-- markdownlint-enable MD013 -->

---

{{#include ../_include/styles.md:impl}}
> Soft vote filtering [reference implementation](https://github.com/algoradam/go-algorand/blob/master/data/committee/credential.go#L160C1-L187C2).
>
> Soft vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/player.go#L170-L206).

The soft vote stage is run after a timeout of \\( \DynamicFilterTimeout(p) \\)
(where \\( p \\) is the executing period of the node) is observed by the node (see
the [dynamic filter timeout section](./abft-nn-dynamic-filter-timeout.md) for more
details).

Let \\( V \\) be the set of all _observed votes_ in the currently executing round.
For convenience, we define a subset, \\( V^\ast \\) to be all proposals received;
that is \\( V^\ast = \\{\vt \in V : \vt_s = \Prop\\} \\).

With the aid of a priority function, this stage performs a filtering action, selecting
the highest priority observed proposal to vote for, defined as the one with the
lowest hashed value.

The priority function (**Algorithm 4** - Lines 4 to 9) should be interpreted as
follows.

Consider every proposal value \\( \vt_p \\) in the subset \\( V^\ast \\)
and the hash of the \\( \VRF \\) proof \\( \ProofToHash(y) \\) obtained by its proposer
in the sortition.

For each index \\( i \\) in the interval from \\( 0 \\) (inclusive) up to the proposer
credentials’ weight[^1] \\( w_j \\) (exclusive), the node hashes the concatenation
of \\( \ProofToHash(y) \\), the proposer address \\( I_j \\) and the index \\( i \\),
as \\( \Hash(\VRF.\ProofToHash(y) || I_j || i) \\) (where \\( \Hash \\) is the
node’s general cryptographic hashing function.

<!-- TODO: VRF normative: See the cryptography [normative section]() for details on \\( VRF \\). -->

> See the cryptography [normative section](../crypto/crypto.md) for details
> on the \\( \Hash \\) function.

Then, the node keeps track of the proposal-value \\( v \\) that minimizes the concatenation
hashing (**Algorithm 4** - Lines 6 to 8).

After running the filtering algorithm for all proposal votes observed, and assuming
there was at least one proposal in \\( V^\ast \\), the broadcasting section of the
algorithm is executed (**Algorithm 4** - Lines 11 to 15).

For every _online_ account (registered on the node), selected to be part of the
\\( \Soft \\) voting committee, a \\( \Soft \\) vote is broadcast for the previously
filtered value \\( v \\).

If the corresponding _full proposal_ has already been observed and is available
in \\( P \\), it is also broadcast (**Algorithm 4** - Lines 16 to 17).

If the previous assumption of non-empty \\( V^\ast \\) does not hold, no broadcasting
is performed, and the node produces no output in its filtering step.

---

[^1]: Corresponds to the \\( j \\) output of \\( \Sortition \\), stored inside the
\\( \c \\) structure.
