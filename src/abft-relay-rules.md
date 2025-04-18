# Relay Rules

Here we describe how players handle message events.

Whenever the player receives a message event, it may decide to _relay_
that or another message. In this case, the player will produce that
output before producing any subsequent output (which may result from
the player's observation of that message; see the [broadcast rules](#broadcast-rules)
below).

A player may receive messages from a misbehaving peer. These cases are marked with
an asterisk (*) and enable the node to perform a special action (e.g., disconnect
from the peer).

> For examples of what these special actions may involve, see the non-normative
> [Algorand Network Overview](./network-overview.md).

We say that a player _ignores_ a message if it produces no outputs on
Receiving that message.

## Proposals

On receiving a proposal \\(Proposal(v)\\) a player

- Relays \\(Proposal(v)\\) if \\(\sigma(S, r+1, 0) = v\\).

- Ignores* it if it is malformed or trivially invalid.

- Ignores it if \\(Proposal(v) \in P\\).

- Relays \\(Proposal(v)\\), observes it, and then produces any consequent output,
if \\(v \in \\{ \sigma(S, r, p), \bar{v}, \mu(S, r, p) \\}\\).

- Otherwise, ignores it.

Specifically, if the player ignores a proposal, then

\\[
N(S, L, Proposal(v)) = (S, L, \epsilon)
\\]

while if a player relays the proposal _after_ checking if it is valid, then

\\[
N(S, L, Proposal(v)) = (S' \cup Proposal(v), L', (Proposal^*(v), \ldots)).
\\]

However, in the first condition above, the player relays \\(Proposal(v)\\) _without_
checking if it is valid.

Since the proposal has not been seen to be valid, the player cannot observe it yet,
so

\\[
N(S, L, Proposal(v)) = (S, L, (Proposal^*(v))).
\\]

> An implementation may _buffer_ a proposal in this case. Specifically, an implementation
> which relays a proposal without checking that it is valid, may optionally choose
> to replay this event when it observes that a new round has begun (see [State Transition section](#internal-transitions)).
> In this case, at the conclusion of a new round, this proposal is processed once
> again as input.

Implementations **MAY** store and relay fewer proposals than specified
here to improve efficiency. However, implementations **MUST** relay proposals which
match the following proposal-values (where \\(r\\) is the current round and \\(p\\)
is the current period):

- \\(\bar{v}\\),

- \\(\sigma(S, r, p), \sigma(S, r, p-1)\\),

- \\(\mu(S, r, p)\\) if \\(\sigma(S, r, p)\\) is not set and \\(\mu(S, r, p+1)\\)
if \\(\sigma(S, r, p+1)\\) is not set.