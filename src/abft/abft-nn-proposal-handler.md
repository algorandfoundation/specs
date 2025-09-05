{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \HandleProposal {\mathrm{HandleProposal}}
\newcommand \VerifyProposal {\mathrm{VerifyProposal}}
\newcommand \IsCommittable {\mathrm{IsCommittable}}
\newcommand \Relay {\mathrm{Relay}}
\newcommand \Broadcast {\mathrm{Broadcast}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Sortition {\mathrm{Sortition}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Encode {\mathrm{Encode}}
\newcommand \bh {\mathrm{bh}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
\newcommand \pr {\mathit{proposal}}
\newcommand \c {\mathit{credentials}}
$$

# Proposal Handler

The proposal handler is triggered when a node receives a _full proposal_ message.

A _proposal-value_ and a _full proposal_ are related but separate constructions.
This is motivated by a slower gossiping time of a _full proposal_, compared to a
much more succinct and therefore quickly gossiped _proposal-value_.

A proposal-value contains four fields:

1. The original _period_ in which this block was proposed.

1. The original proposer’s address.

1. The block digest, equal to the block header’s hash (including a domain separator).
This field expands to \\( \Hash(\texttt{"BH"} || \Encode(\bh)) \\), where \\( \texttt{"BH"} \\)
is the domain separator for a “block header”, and the encoding function is the msgpack
of the block header (\\( \bh \\)).

1. A hash of the proposal, \\( \Hash(\Proposal) \\). This field expands to
\\( \Hash(\texttt{"PL"} || \Encode(\Proposal)) \\), where \\( \Proposal \\)
represents the unauthenticated proposal, \\( \texttt{"PL"} \\) is the domain separator
for a “payload”, and the encoding function is the msgpack of the \\( \Proposal \\).

{{#include ../_include/styles.md:impl}}
> Proposal-value [structure](https://github.com/algorand/go-algorand/blob/8341e41c3a4b9c7819cb3f89f319626f5d7b68d5/agreement/proposal.go#L37).
>
> Domain separators for [block header](https://github.com/algorand/go-algorand/blob/8341e41c3a4b9c7819cb3f89f319626f5d7b68d5/protocol/hash.go#L43)
> and [payload](https://github.com/algorand/go-algorand/blob/8341e41c3a4b9c7819cb3f89f319626f5d7b68d5/protocol/hash.go#L60).

On the other hand, an _unauthenticated proposal_ contains a full block and all extra
data for the block validation:

1. The original period in which this block was proposed.

1. The original proposer’s address.

1. A full block (header and payset).

1. A seed proof \\( \pi_{seed} \\).

Note that the _original period_ and proposer’s address are the same as the associated
_proposal-value_. The seed proof \\( \pi_{seed} \\) is used to verify the seed computation.

{{#include ../_include/styles.md:impl}}
> Unauthenticated proposal [structure](https://github.com/algorand/go-algorand/blob/8341e41c3a4b9c7819cb3f89f319626f5d7b68d5/agreement/proposal.go#L55).

{{#include ../_include/styles.md:impl}}
> In the reference implementation, the _unauthenticated proposal_ is sent to
> the network linked to a previously emitted proposal vote. These are sent together
> in a struct defined as a [compound message](https://github.com/algorand/go-algorand/blob/8341e41c3a4b9c7819cb3f89f319626f5d7b68d5/agreement/message.go#L56),
> which avoids the edge case of receiving _proposal_ and _proposal-value_ messages
> in an unfavorable order. Consider the following edge case: a node observes a
> _proposal_ before receiving its supporting _proposal-value_. It discards the
> _proposal_ (to avoid DDoS attacks). Right after the node receives the related
> _proposal-value_, it goes through all the steps, and certifies this block, but
> needs to request the previously discarded proposal to be able to commit it and
> advance a round. If this happens to enough nodes (voting stake), the network
> might move to a second period. In the new period, the proposal is broadcast and
> committed fast, since the proposal step is skipped (having carried over the _staged_
> and _frozen_ values).

## Algorithm

In the following pseudocode the _frozen value_ \\( \mu \\) is either:

- The highest priority observed proposal-value in the current \\((r, p)\\) context
(i.e., the lowest hashed according to the [priority function](../abft/abft-player-state.md#special-values)), or
- \\( \bot \\) if the node has observed no valid proposal vote.

The _staged value_ \\( \sigma \\) is either:

- The sole proposal-value for which a \\( \Bundle_\Soft \\) has been observed in
the current \\((r, p)\\) context (see [normative section](../abft/abft-player-state.md#special-values)), or
- \\( \bot \\) if the node has observed no valid \\( \Bundle_\Soft \\).

The _pinned value_ \\( \bar{v} \\) is a proposal-value that was a _staged value_
in a previous period. When available, this value is used to fast-forward the first
steps of the protocol when a \\( \Next \\) vote has been successful.

---

\\( \textbf{Algorithm 6} \text{: Handle Proposal} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \HandleProposal(\pr) \\\\
&\text{2: } \quad v \gets \Proposal_v(\pr, \pr_p, \pr_I) \\\\
&\text{3: } \quad \PSif \exists \Bundle(r+1, 0, \Soft, v) \in B \PSthen \\\\
&\text{4: } \quad \quad \Relay(\pr) \\\\
&\text{5: } \quad \quad \PSreturn \PScomment{Future round, do not observe (node is behind)} \\\\
&\text{6: } \quad \PSendif \\\\
&\text{7: } \quad \PSif \PSnot \VerifyProposal(\pr) \lor \pr \in P \PSthen \\\\
&\text{8: } \quad \quad \PSreturn \PScomment{Ignore proposal} \\\\
&\text{9: } \quad \PSendif \\\\
&\text{10:} \quad \PSif v \notin \\{\sigma, \bar{v}, \mu\\} \PSthen \\\\
&\text{11:} \quad \quad \PSreturn \PScomment{Ignore proposal} \\\\
&\text{12:} \quad \PSendif \\\\
&\text{13:} \quad \Relay(\pr) \\\\
&\text{14:} \quad P \gets P \cup \pr \\\\
&\text{15:} \quad \PSif \IsCommittable(v) \land s \le \Cert \PSthen \\\\
&\text{16:} \quad \quad \PSfor a \in A \PSdo \\\\
&\text{17:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Cert) \\\\
&\text{18:} \quad \quad \quad \PSif \c_j > 0 \PSthen \\\\
&\text{19:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \Cert, v, \c)) \\\\
&\text{20:} \quad \quad \quad \PSendif \\\\
&\text{21:} \quad \quad \PSendfor \\\\
&\text{22:} \quad \PSendif \\\\
&\text{23: } \PSendfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Proposal handler [reference implementation](https://github.com/algorand/go-algorand/blob/c60db8dbc4b0dd164f0bb764e1464d4ebef38bb4/agreement/proposalManager.go#L57).

The node starts by performing a series of checks, after which it will either:

- Ignore the received proposal, discarding it and emitting no output, or

- Relay, observe, and produce an output according to the current context and the
characteristics of the proposal.

The node checks if the proposal is from the first period of the next round (Line
3), in which case, the node relays this proposal and then ignores it for the operations
of the current round.

Whenever the node catches up (i.e., observes a round change), and only if necessary,
it will request this proposal back from the network.

The node checks (Line 7) if the proposal is invalid or has already been observed.
Any one of those conditions is enough to discard and ignore the incoming proposal.

Finally, the node checks (Line 10) if the associated proposal value is either a
_special proposal-value_ for the current round and period (\\( \sigma \\), \\( \mu \\))
or the _pinned proposal-value_ (\\( \bar{v} \\)). Any _full proposal_ whose _proposal-value_
does not match one of these is ignored.

> For formal details on special values, refer to the [normative section](../abft/abft-player-state.md#special-values).

Once the checks have been passed, the node relays and observes the proposal (Lines
13 and 14), by adding it to the observed proposals set \\( P \\).

Next, only if the _proposal-value_ is committable (meaning the _staged value_ is
set for a proposal, and said proposal has already been observed and is available)
and the current step is lower than or equal to a \\( \Cert \\) step (i.e., is not
yet in a recovery step), the node plays for each _online_ account (registered on
the node), performing a \\( \Sortition \\)to select the certification committee
members.

For each selected account, a \\( \Vote_\Cert \\) for the current _proposal-value_
is broadcast.
