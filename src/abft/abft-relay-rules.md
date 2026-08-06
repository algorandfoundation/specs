$$
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Late {\mathit{late}}
\newcommand \Down {\mathit{down}}
\newcommand \Next {\mathit{next}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Proposal {\mathrm{Proposal}}
$$

# Relay Rules

Here we describe how players handle message events.

Whenever the player receives a message event, it may decide to _relay_
that or another message. In this case, the player will produce that
output before producing any subsequent output (which may result from
the player's observation of that message; see the [broadcast rules](./abft-broadcast-rules.md)
below).

A player may receive messages from a misbehaving peer. These cases are marked with
an asterisk (*) and enable the node to perform a special action (e.g., disconnect
from the peer).

> [!NOTE]
> For examples of what these special actions may involve, see the
> [Algorand Network non-normative section](../network/network-overview.md).

We say that a player _ignores_ a message if it produces no outputs on
receiving that message.

## Votes

On receiving a vote \\( \Vote_k(r_k, p_k, s_k, v) \\) a player

- Ignores* it if \\( \Vote_k \\) is malformed or trivially invalid.

- Ignores it if \\( \Vote_k \in V \\).

- Ignores it if \\( s_k = 0 \\) and \\( \Vote_k \\) is an equivocation.

- Ignores it if \\( s_k > 0 \\) and \\( \Vote_k \\) is a second equivocation.

- Ignores it if

  - \\( r_k \notin [r,r+1] \\) or
  - \\( r_k = r + 1 \\) and either
    - \\( p_k > 0 \\) or
    - \\( s_k \in (\Next_0, \Late) \\) or

  - \\( r_k = r \\) and one of
    - \\( p_k \notin [p-1,p+1] \\) or
    - \\( p_k = p + 1 \\) and \\( s_k \in (\Next_0, \Late) \\) or
    - \\( p_k = p \\) and \\( s_k \in (\Next_0, \Late) \\) and \\( s_k \notin [s-1,s+1] \\) or
    - \\( p > 0 \\) and \\( p_k = p - 1 \\) and \\( s_k \in (\Next_0, \Late) \\) and
      \\( s_k \notin [\bar{s}-1,\bar{s}+1] \\).

- **MAY** ignore it if \\( s_k = 0 \\) and its credential does not have higher
priority than that of every proposal-vote accepted or relayed for
\\( (r_k, p_k) \\).

- Otherwise, relays \\( \Vote_k \\), observes it, and then produces any consequent
output.

A player **MAY** also relay a verified proposal-vote with \\( r_k < r \\) and
\\( p_k = s_k = 0 \\), without observing it, if its credential has higher
priority than that of every proposal-vote accepted or relayed for \\( (r_k, 0) \\).

> [!NOTE]
> The reference implementation does so within a bounded window of past rounds,
> supporting the adaptive filter timeout described in the
> [non-normative section](./non-normative/abft-nn-dynamic-filter-timeout.md).

Specifically, if a player ignores the vote, then

$$
N(S, L, \Vote_k(r_k, p_k, s_k, v)) = (S, L, \epsilon)
$$

while if a player relays the vote, then

$$
N(S, L, \Vote_k(r_k, p_k, s_k, v))
= (S' \cup \\{\Vote_k(r_k, p_k, s_k, v)\\}, L', (\Vote_k^\ast(r_k, p_k, s_k, v),\ldots));
$$

and if a player relays the vote without observing it, then

$$
N(S, L, \Vote_k(r_k, p_k, s_k, v)) = (S, L, (\Vote_k^\ast(r_k, p_k, s_k, v))).
$$

## Bundles

On receiving a bundle \\( \Bundle(r_k, p_k, s_k, v) \\) a player

- Ignores* it if \\( \Bundle(r_k, p_k, s_k, v) \\) is malformed or trivially invalid.

- Ignores it if
  - \\( r_k \neq r \\) or
  - \\( s_k \neq \Cert \\) and \\( p_k + 1 < p \\).

- Otherwise, verifies and observes the votes in \\( \Bundle(r_k, p_k, s_k, v) \\) in sequence. If
there exists a vote that causes the player to observe some bundle \\( \Bundle(r_k, p_k, s_k, v') \\),
then the player relays it and executes any consequent action; otherwise, the player ignores it.

Specifically, if the player ignores the bundle without observing its
votes, then

$$
N(S, L, \Bundle(r_k, p_k, s_k, v)) = (S, L, \epsilon);
$$

while if a player ignores the bundle but observes its votes, then

$$
N(S, L, \Bundle(r_k, p_k, s_k, v))
= (S', L, \epsilon);
$$

and if a player, on observing the votes in the bundle, observes a
bundle for some value (not necessarily distinct from the bundle's
value), then

$$
N(S, L, \Bundle(r_k, p_k, s_k, v))
= (S', L', (\Bundle^\ast(r_k, p_k, s_k, v'), \ldots)).
$$

## Proposals

On receiving a proposal \\( \Proposal(v) \\) a player

- Ignores* it if it is malformed or trivially invalid.

- Ignores it if \\( \Proposal(v) \in P \\).

- Relays \\( \Proposal(v) \\) if \\( v = \bar{v} \\), \\( v = \rho(S, r, q) \\) for
\\( q \in \\{p-1, p, p+1\\} \\) when not \\( \bot \\), or \\( v = \rho(S, r+1, 0) \\).

- Otherwise, ignores it.

A relayed proposal is observed and produces any consequent output only if it is valid.

When relaying \\( Proposal(v) \\), the player **SHOULD** attach an accepted current-period
proposal-vote for \\( v \\) as authenticator, when available.

Specifically, if the player ignores a proposal, then

$$
N(S, L, \Proposal(v)) = (S, L, \epsilon)
$$

while if a player relays a valid proposal, then

$$
N(S, L, \Proposal(v))
= (S' \cup \Proposal(v), L', (\Proposal^\ast(v), \ldots)).
$$

If a relayed proposal is invalid, it is not observed:

$$
N(S, L, \Proposal(v)) = (S', L, (\Proposal^\ast(v))).
$$

> [!NOTE]
> Implementations **MAY** store and relay fewer proposals than specified
> here to improve efficiency. However, implementations **MUST** relay, at least
> once, proposals which match the following proposal-values (where \\( r \\) is
> the current round and \\( p \\) is the current period):
>
> - \\( \bar{v} \\),
>
> - \\( \rho(S, r, q) \\) for \\( q \in \\{p-1, p, p+1\\} \\) when not \\( \bot \\),
>
> - \\( \rho(S, r+1, 0) \\).
