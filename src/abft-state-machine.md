# State Machine

This specification defines the Algorand agreement protocol as a state
machine. The input to the state machine is some serialization of
events, which in turn results in some serialization of network
transmissions from the state machine.

We can define the operation of the state machine as transitions
between different states.

A transition \\(N\\) maps some initial state
\\(S_0\\), a ledger \\(L_0\\), and an event \\(\mathbf{e}\\) to an output state
\\(S_1\\), an output ledger \\(L_1\\), and a sequence of output network transmissions
\\(\mathbf{a} = (a_1, a_2, \ldots, a_n)\\).

We write this as

\\[
N(S_0, L_0, \mathbf{e}) = (S_1, L_1, \mathbf{a})
\\]

If no transmissions are output, we write that \\(\mathbf{a} = \epsilon\\).

## Events

The state machine _receives_ two types of events as inputs.

1. _message events_: A message event is received when a vote, a
   proposal, or a bundle is received. A message event is simply
   written as the message that is received.
2. _timeout events_: A timeout event is received when a specific
   amount of time passes after the beginning of a period. A timeout
   event \\(\lambda\\) seconds after a period \\(p\\) begins is denoted
   \\(t(\lambda, p)\\).

> For more detail on the way these events may be constructed from an implementation
> point of view, refer to the non-normative [Algorand ABFT Overview](./abft-overview.md).

## Outputs

The state machine produces a series of network transmissions as
output. In each transmission, the player broadcasts a vote, a
proposal, or a bundle to the rest of the network.

A player may perform a special broadcast called a _relay_. In a
relay, the data received from another peer is broadcast to all peers
except for the sender.

A broadcast action is simply written as the message to be
transmitted. A relay action is written as the same message except
with an asterisk. For instance, an action to relay a vote is written
as \\(Vote^*(r, p, s, v)\\).

> For implementation details on relay and broadcasting actions, refer to the non-normative
> [Algorand Network Overview](.//network-overview.md).

# Player State Definition

We define the _player state_ \\(S\\) to be the following tuple:

\\[
S = (r, p, s, \bar{s}, V, P, \bar{v})
\\]

where

- \\(r\\) is the current round,
- \\(p\\) is the current period,
- \\(s\\) is the current step,
- \\(\bar{s}\\) is the _last concluding step_,
- \\(V\\) is the set of all votes,
- \\(P\\) is the set of all proposals, and
- \\(\bar{v}\\) is the _pinned_ value.

We say that a player has _observed_

- \\(Proposal(v)\\) if \\(Proposal(v) \in P\\),
- \\(Vote(r, p, s, v)\\) if \\(Vote(r, p, s, v) \in V\\),
- \\(Bundle(r, p, s, v)\\) if \\(Bundle(r, p, s, v) \subset V\\),
- That the round \\(r\\) (period \\(p = 0\\)) has _begun_ if there exists some
\\(p\\) such that \\(Bundle(r-1, p, Cert, v)\\) was also observed for some \\(v\\),
- that the round \\(r\\), period \\(p > 0\\) has _begun_ if there exists some \\(p\\)
such that either
  - \\(Bundle(r, p-1, s, v)\\) was also observed for some \\(s > Cert, v\\), or
  - \\(Bundle(r, p, Soft, v)\\) was observed for some \\(v\\).

An event causes a player to observe something if the player has not
observed that thing before receiving the event and has observed that
thing after receiving the event. For instance, a player may observe a
vote \\(Vote\\), which adds this vote to \\(V\\):

\\[
N((r, p, s, \bar{s}, V, P, \bar{v}), L_0, Vote) = ((r', p', \ldots, V \cup \\{Vote\\}, P, \bar{v}'), L_1, \ldots)
\\]

We abbreviate the transition above as

\\[
N((r, p, s, \bar{s}, V, P, \bar{v}), L_0, Vote) = ((S \cup Vote, P, \bar{v}), L_1, \ldots)
\\]

Note that _observing_ a message is distinct from _receiving_ a
message. A message which has been received might not be observed (for
instance, the message may be from an old round). Refer to the [relay rules](#relay-rules) for details.

## Special Values

We define two functions \((\mu(S, r, p), \sigma(S, r, p)\)), which are
defined as follows:

The _frozen value_ \\(\mu(S, r, p)\\) is defined as the _proposal-value_ \\(v\\)
in the proposal vote in round \\(r\\) and period \\(p\\) that minimizes a credential
priority function \\(prio(v)\\).

Consider \\(w_j\\) is the weight of said proposal vote for \\(v\\), and \\(y\\)
is the result of the signing procedure for \\(v\\), then the priority function is
defined as

\\[
prio(v) = \min_{i \in [0, w_j)} \\{ \mathsf{H}(\mathrm{VRF.ProofToHash}(y) \ || \ i) \\}
\\]

where \\(w_j\\) is the weight of the proposal vote for player \\(I\\).

More formally then, let

\\[
V_{r, p} = \\{ Vote(I, r, p, 0, v) | Vote \in V \\}
\\]

where \\(V\\) is the set of votes in \\(S\\). Then if \\(Vote_l(r, p, 0, v_{min})\\)
is the vote such that

\\[
\forall \ Vote(I,r,p,0,v) \in V_{r, p}, v_{min} \neq v \implies prio(v_{min}) < prio(v)
\\]

then $\mu(S, r, p) = v_{min}$.

If \\(V_{r, p}\\) is empty, then \\(\mu(S, r, p) = \bot\\).

The _staged value_ \\(\sigma(S, r, p)\\) is defined as the sole _proposal-value_
for which there exists a soft-bundle in round \\(r\\) and period \\(p\\).

More formally, suppose \\(Bundle(r, p, Soft, v) \subset V\\). Then \\(\sigma(S, r, p) = v\\).

If no such soft-bundle exists, then \\(\sigma(S, r, p) = \bot\\).

If there exists a proposal-value \\(v\\) such that \\(Proposal(v) \in P\\) and
\\(\sigma(S, r, p) = v\\), we say that \\(v\\) is _committable for round \\(r\\),
period_ \\(p\\) (or simply that \\(v\\) is _committable_ if \\((r, p)\\) is unambiguous).

> ⚙️ **IMPLEMENTATION**
>
> The current implementation constructs a [Proposal Tracker](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/proposalTracker.go#L93)
> which, amongst other things, is in charge of handling both frozen and staged value
> tracking.