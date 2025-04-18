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