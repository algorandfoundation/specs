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