$$
\newcommand \Resync {\mathrm{ResynchronizationAttempt}}
\newcommand \BlockProposal {\mathrm{BlockProposal}}
\newcommand \BlockAssembly {\mathrm{BlockAssembly}}
\newcommand \Sortition {\mathrm{Sortition}}
\newcommand \Broadcast {\mathrm{Broadcast}}
\newcommand \RetrieveProposal {\mathrm{RetrieveProposal}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \else {\textbf{else}}
\newcommand \endif {\textbf{end if}}
\newcommand \for {\textbf{for }}
\newcommand \do {\textbf{do}}
\newcommand \endfor {\textbf{end for}}
\newcommand \c {\mathit{credentials}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \prop {\mathit{proposal}}
$$

# Block Proposal

The following is an abstracted pseudocode of the \\( \BlockProposal \\) algorithm.

## Algorithm

---

\\( \textbf{Algorithm 3} \text{: Block Proposal} \\)

$$
\begin{aligned}
&\text{1: } \function \BlockProposal() \\\\
&\text{2: } \quad \if p \ne 0 \then \\\\
&\text{3: } \quad \quad \Resync() \\\\
&\text{4: } \quad \endif \\\\
&\text{5: } \quad \for a \in A \do \\\\
&\text{6: } \quad \quad \c \gets \Sortition(a_I, r, p, \prop) \\\\
&\text{7: } \quad \quad \if \c_j > 0 \then \\\\
&\text{8: } \quad \quad \quad \if p = 0 \lor \exists s' \text{ such that } \Bundle(r, p-1, s', \bot) \subset V \then \\\\
&\text{9: } \quad \quad \quad \quad (e, y) \gets \BlockAssembly(a_I) \\\\
&\text{10:} \quad \quad \quad \quad \prop \gets \Proposal(e, y, p, a_I) \\\\
&\text{11:} \quad \quad \quad \quad v \gets \Proposal_\text{value}(\prop) \\\\
&\text{12:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \prop, v, \c)) \\\\
&\text{13:} \quad \quad \quad \quad \Broadcast(\prop) \\\\
&\text{14:} \quad \quad \quad \else \\\\
&\text{15:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \prop, \bar{v}, \c)) \\\\
&\text{16:} \quad \quad \quad \quad \if \RetrieveProposal(\bar{v}) \ne \bot \then \\\\
&\text{17:} \quad \quad \quad \quad \quad \Broadcast(\RetrieveProposal(\bar{v})) \\\\
&\text{18:} \quad \quad \quad \quad \endif \\\\
&\text{19:} \quad \quad \quad \endif \\\\
&\text{20:} \quad \quad \endif \\\\
&\text{21:} \quad \endfor \\\\
&\text{22: } \endfunction
\end{aligned}
$$

---

> ⚙️ **IMPLEMENTATION**
>
> Block proposal [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/pseudonode.go#L286-L322).

This algorithm is the first routine called on every _round_ and _period_ where a
_reproposal_ is not possible.

Starting on **Algorithm 3** - Line 2, the node attempts a resynchronization (described
in the [corresponding section](#resynchronization-attempt)), which has only effect
on periods \\( p > 0 \\).

> ⚙️ **IMPLEMENTATION**
>
> The reference implementation executes a resynchronization attempt when entering
> into a [new period](https://github.com/algorand/go-algorand/blob/55011f93fddb181c643f8e3f3d3391b62832e7cd/agreement/player.go#L411).
> Functionally, the behavior is the same, as resynchronization is performed before
> starting a new _period_, save for \\( p = 0 \\).

The algorithm loops over all the _participating accounts_ (\\( a \in A \\)) registered
on the node. This is a typical pattern in every main algorithm subroutine performing
committee voting.

For each participating account, the [sortition algorithm](crypto.md#cryptographic-sortition)
runs to check if said account is allowed to participate in the proposal.

If an account \\( a \\) is selected by sortition (because \\( \c_j = \Sortition(a_I, r, p, \prop)_j > 0 \\))
there are two options:

1. If this is a _proposal step_ (\\( p = 0 \\)) or if the node has observed a bundle
\\( \Bundle(r, p-1, s', \bot) \\) (meaning there is no valid _pinned value_), then
the node:

   - Assembles a block (see the [Ledger non-normative section](ledger-overview.md#block-assembly)
   for details on this process),
   - Computes the proposal value for this block,
   - Broadcast a proposal vote by the account \\( a \\),
   - Broadcasts the full block in a \\( \texttt{Proposal} \\) type message.

1. Otherwise, a value \\( \bar{v} \\) has been pinned, supported by a bundle observed
in period \\( p - 1 \\), and on **Algorithm 3** - Line 15 the node:

   - Gets the pinned value, 
   - Assembles a vote \\( \Vote(a_I, r, p, \prop, \bar{v}, \c) \\),
   - Broadcasts this vote,
   - Broadcast the proposal for the pinned vote if it has already been observed.

> ⚙️ **IMPLEMENTATION**
>
> The reference implementation assembles a set of transactions and a block header
> independently of the proposer, in parallel with the proposer loop. This improves
> timing and guarantees the tight deadline constraints for the block proposal step.