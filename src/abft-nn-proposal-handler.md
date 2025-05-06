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
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
\newcommand \function {\textbf{function }}
\newcommand \return {\textbf{return }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \endif {\textbf{end if}}
\newcommand \for {\textbf{for }}
\newcommand \do {\textbf{ do}}
\newcommand \endfor {\textbf{end for}}
\newcommand \not {\textbf{not }}
\newcommand \comment {\qquad \small \textsf}
\newcommand \pr {\mathit{proposal}}
\newcommand \c {\mathit{credentials}}
$$

# Proposal Handler

The proposal handler is triggered when a node receives a _full proposal_[^1] message.

## Algorithm

In the following pseudocode the _frozen value_ \\( \mu \\) is either:

- The highest priority observed proposal-value in the current \\((r, p)\\) context
(i.e., the lowest hashed according to the [priority function](./abft.md#special-values)), or
- \\( \bot \\) if the node has observed no valid proposal vote.

The _staged value_ \\( \sigma \\) is either:

- The sole proposal-value for which a \\( \Bundle_\Soft \\) has been observed in
the current \\((r, p)\\) context (see [normative section](abft.md#special-values)), or
- \\( \bot \\) if the node has observed no valid \\( \Bundle_\Soft \\).

The _pinned value_ \\( \bar{v} \\) is a proposal-value that was a _staged value_
in a previous period. When available, this value is used to fast-forward the first
steps of the protocol when a \\( \Next \\) vote has been successful.

---

\\( \textbf{Algorithm 6} \text{: Handle Proposal} \\)

$$
\begin{aligned}
&\text{1: } \function \HandleProposal(\pr) \\\\
&\text{2: } \quad v \gets \Proposal_v(\pr, \pr_p, \pr_I) \\\\
&\text{3: } \quad \if \exists \Bundle(r+1, 0, \Soft, v) \in B \then \\\\
&\text{4: } \quad \quad \Relay(\pr) \\\\
&\text{5: } \quad \quad \return \comment{# Future round, do not observe (node is behind)} \\\\
&\text{6: } \quad \endif \\\\
&\text{7: } \quad \if \not \VerifyProposal(\pr) \lor \pr \in P \then \\\\
&\text{8: } \quad \quad \return \comment{# Ignore proposal} \\\\
&\text{9: } \quad \endif \\\\
&\text{10:} \quad \if v \notin \\{\sigma, \bar{v}, \mu\\} \then \\\\
&\text{11:} \quad \quad \return \comment{# Ignore proposal} \\\\
&\text{12:} \quad \endif \\\\
&\text{13:} \quad \Relay(\pr) \\\\
&\text{14:} \quad P \gets P \cup \pr \\\\
&\text{15:} \quad \if \IsCommittable(v) \land s \le \Cert \then \\\\
&\text{16:} \quad \quad \for a \in A \do \\\\
&\text{17:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Cert) \\\\
&\text{18:} \quad \quad \quad \if \c_j > 0 \then \\\\
&\text{19:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \Cert, v, \c)) \\\\
&\text{20:} \quad \quad \quad \endif \\\\
&\text{21:} \quad \quad \endfor \\\\
&\text{22:} \quad \endif \\\\
&\text{23: } \endfunction
\end{aligned}
$$

---

{{#include ./.include/styles.md:impl}}
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

> For formal details on special values, refer to the [normative section](./abft.md#special-values).

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

---

[^1]: A _full proposal_ differs from a _proposal-value_ in that the former contains
the whole block body, including transactions (the _payset_), while the latter is
just a block header with credentials.