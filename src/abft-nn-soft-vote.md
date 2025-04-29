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
\newcommand \Vote {\mathrm{Vote}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \endif {\textbf{end if}}
\newcommand \for {\textbf{for }}
\newcommand \do {\textbf{ do}}
\newcommand \endfor {\textbf{end for}}
\newcommand \loh {\mathit{lowestObservedHash}}
\newcommand \vt {\mathit{vote}}
\newcommand \ph {\mathit{priorityHash}}
\newcommand \c {\mathit{credentials}}
\newcommand \prop {\mathit{proposal}}
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

- \\( w_j \\) be the weight of the credentials for \\( v \\) by player \\( I_j \\),
- \\( y \\) be the VRF proof as computed by player \\( I_j \\) using their VRF secret key.

The function selects the minimum among a set of \\( w_j \\) hash values calculated
as \\(\Hash \left(\VRF.\ProofToHash(y) || i \right)\\), with \\(i \in [0, w_j)\\).

The higher the credentials’ weight \\( w_j \\), the larger the set, the higher the
chances for the player \\( I_j \\) to get the lowest value among all the players
for this round.

## Algorithm

---

\\( \textbf{Algorithm 4} \text{: Soft Vote} \\)

$$
\begin{aligned}
&\text{1: } \function \SoftVote() \\\\
&\text{2: } \quad \loh \gets \infty \\\\
&\text{3: } \quad v \gets \bot \\\\
&\text{4: } \quad \for \vt^\prime \in V \text{ with } \vt^\prime_s = \prop \do \\\\
&\text{5: } \quad \quad \ph \gets \Priority(\vt^\prime)  \\\\
&\text{6: } \quad \quad \if \ph < \loh \then \\\\
&\text{7: } \quad \quad \quad \loh \gets \ph \\\\
&\text{8: } \quad \quad \quad v \gets \vt_v \\\\
&\text{9: } \quad \quad \endif \\\\
&\text{10:} \quad \endfor \\\\
&\text{11:} \quad \if \loh < \infty \then \\\\
&\text{12:} \quad \quad \for a \in A \do \\\\
&\text{13:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Soft) \\\\
&\text{14:} \quad \quad \quad \if \c_j > 0 \then \\\\
&\text{15:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \Soft, v, \c)) \\\\
&\text{16:} \quad \quad \quad \quad \if \RetrieveProposal(v) \then \\\\
&\text{17:} \quad \quad \quad \quad \quad \\Broadcast(\RetrieveProposal(v)) \\\\
&\text{18:} \quad \quad \quad \quad \endif \\\\
&\text{19:} \quad \quad \quad \endif \\\\
&\text{20:} \quad \quad \endfor \\\\
&\text{21:} \quad \endif \\\\
&\text{22: } \endfunction
\end{aligned}
$$

---

> ⚙️ **IMPLEMENTATION**
>
> Soft vote filtering [reference implementation](https://github.com/algoradam/go-algorand/blob/master/data/committee/credential.go#L160C1-L187C2).
> Soft vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/player.go#L170-L206).

The soft vote stage is run after a timeout of \\( \DynamicFilterTimeout(p) \\)
(where \\( p \\) is the executing period of the node) is observed by the node (see
the [dynamic filter timeout section](./abft-nn-dynamic-filter-timeout.md) for more
details).

Let \\( V^\ast \\) be all proposal votes received, e.g., \\( V^\ast = \\{vt^\prime \in V : vt^\prime_s = \prop\\} \\).
With the aid of a priority hash function (see the [normative section](./abft.md#special-values)),
this stage performs a filtering action, keeping the lowest hashed value observed.

The priority function (**Algorithm 4** - Lines 4 to 9) should be interpreted as
follows.

Consider every proposal \\( \vt \\) in \\( V^\ast \\). Given the sortition
hash \\( \ProofToHash(.) \\) output by the \\( \VRF \\) for the proposer account
(see the cryptography [normative section](./crypto.md#verifiable-random-function)
for details on \\( VRF \\)). For each \\( i \\) in the interval from \\( 0 \\) (inclusive)
to the proposer credentials’ weight \\( w_j \\) (exclusive; the \\( j \\) output of \\( \Sortition(.) \\)
inside the \\( \c \\) structure), the node hashes the concatenation of \\( \ProofToHash(y) \\), the player address \\( I_j \\) and \\( i \\), as \\( \Hash(\VRF.\ProofToHash(y) || I_j || i) \\) (where \\( \Hash(.) \\) is
the node’s general cryptographic hashing function, see the cryptography [normative section](crypto.md#hash-functions) for details).

Then (**Algorithm 4** - Lines 6 to 8), the node keeps track of the proposal-value
that minimizes the concatenation hashing.

After running the filtering algorithm for all proposal votes observed, and assuming
there was at least one vote in \\( V^\ast \\), the broadcasting section of the filtering
algorithm is executed (**Algorithm 4** - Lines 11 to 15). For every _online_ registered
account, selected to be part of the \\( \Soft \\) voting committee, a \\( \Soft \\)
vote is broadcast for the previously found filtered value \\( v \\).

If the full proposal has already been observed and is available in \\( P \\), it
is also broadcast (**Algorithm 4** - Lines 16 to 17).

If the previous assumption of non-empty \\( V^\ast \\) does not hold, no broadcasting
is performed, and the node produces no output in its filtering step.