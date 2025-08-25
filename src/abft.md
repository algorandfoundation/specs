---
numbersections: true
title: "Algorand Byzantine Fault Tolerance Protocol Specification"
date: \today
abstract: >
  The _Algorand Byzantine Fault Tolerance protocol_ is an interactive protocol which produces a sequence of common information between a set of participants.
---



Relay Rules
===========

Here we describe how players handle message events.

Whenever the player receives a message event, it may decide to _relay_
that or another message. In this case, the player will produce that
output before producing any subsequent output (which may result from
the player's observation of that message; see the [broadcast
rules][Broadcast Rules] below).

A player may receive messages from a peer which indicates that the
peer is misbehaving. These cases are marked with an asterisk (*) and
enable the node to perform a special action (e.g., disconnect from the
peer).

We say that a player _ignores_ a message if it produces no outputs on
receiving that message.


Votes
-----

On receiving a vote $Vote_k(r_k, p_k, s_k, v)$ a player

 - Ignores* it if $\Vote_k$ is invalid.
 - Ignores it if $s = 0$ and $\Vote_k \in V$.
 - Ignores it if $s = 0$ and $\Vote_k$ is an equivocation.
 - Ignores it if $s > 0$ and $\Vote_k$ is a second equivocation.
 - Ignores it if
    - $r_k \notin [r,r+1]$ or
    - $r_k = r + 1$ and either
       - $p_k > 0$ or
       - $s_k \in (\Next_0, \Late)$ or
    - $r_k = r$ and one of
       - $p_k \notin [p-1,p+1]$ or
       - $p_k = p + 1$ and $s_k \in (\Next_0, \Late)$ or
       - $p_k = p$ and $s_k \in (\Next_0, \Late)$ and $s_k \notin [s-1,s+1]$ or
       - $p_k = p - 1$ and $s_k \in (\Next_0, \Late)$ and
	     $s_k \notin [\sbar-1,\sbar+1]$.
 - Otherwise, relays $\Vote_k$, observes it, and then produces any
   consequent output.

Specifically, if a player ignores the vote,
$$
N(S, L, \Vote_k(r_k, p_k, s_k, v)) = (S, L, \epsilon)
$$
while if a player relays the vote,
$$
 N(S, L, \Vote_k(r_k, p_k, s_k, v))
= (S' \cup \Vote(I, r_k, p_k, s_k, v), L',
   (\Vote_k^*(r_k, p_k, s_k, v),\ldots)).
$$


Bundles
-------

On receiving a bundle $\Bundle(r_k, p_k, s_k, v)$ a player

 - Ignores* it if $\Bundle(r, p, s, v)$ is invalid.
 - Ignores it if
    - $r_k \neq r$ or
    - $r_k = r$ and $p_k + 1 < p$.
 - Otherwise, observes the votes in $\Bundle(r_k, p_k, s_k, v)$ in
   sequence. If there exists a vote which causes the player to observe
   some bundle $\Bundle(r_k, p_k, s_k, v')$ for some $s_k$, then the
   player relays $\Bundle(r_k, p_k, s_k, v')$, and then executes any
   consequent action; if there does not, the player ignores it.
   
Specifically, if the player ignores the bundle without observing its
votes,
$$
N(S, L, \Bundle(r_k, p_k, s_k, v)) = (S, L, \epsilon);
$$
while if a player ignores the bundle but observes its votes,
$$
N(S, L, \Bundle(r_k, p_k, s_k, v))
= (S' \cup \Bundle(r_k, p_k, s_k, v), L, \epsilon);
$$
and if a player, on observing the votes in the bundle, observes a
bundle for some value (not necessarily distinct from the bundle's
value),
$$
N(S, L, \Bundle(r_k, p_k, s_k, v))
= (S' \cup \Bundle(r_k, p_k, s_k, v), L',
   (\Bundle^*(r_, p_k, s_k, v'), \ldots)).
$$


Proposals
---------

On receiving a proposal $\Proposal(v)$ a player

 - Relays $\Proposal(v)$ if $\sigma(S, r+1, 0) = v$.
 - Ignores it if it is invalid.
 - Ignores it if $\Proposal(v) \in P$.
 - Relays $\Proposal(v)$, observes it, and then produces any
   consequent output,
   if $v \in \{\sigma(S, r, p), \vbar, \mu(S, r, p)\}$.
 - Otherwise, ignores it.

Specifically, if the player ignores a proposal,
$$
N(S, L, \Proposal(v)) = (S, L, \epsilon)
$$
while if a player relays the proposal _after_ checking if it is valid,
$$
N(S, L, \Proposal(v))
= (S' \cup \Proposal(v), L', (\Proposal^*(v), \ldots)).
$$

However, in the first condition above, the player relays
$\Proposal(v)$ _without_ checking if it is valid.  Since the proposal
has not been seen to be valid, the player cannot observe it yet, so
$$
N(S, L, \Proposal(v)) = (S, L, (\Proposal^*(v))).
$$
Note: An implementation may _buffer_ a proposal in this case.
Specifically, an implementation which relays a proposal without
checking that it is valid may optionally choose to replay this event
when it observes that a new round has begun (see [below][Internal
Transitions]).  In this case, on the conclusion of a new round, this
proposal is processed once again as input.

Implementations may store and relay fewer proposals than specified
here to improve efficiency. However, implementations are always
required to relay proposals which match the following proposal-values
(where $r$ is the current round and $p$ is the current period):

 - $\vbar$
 - $\sigma(S, r, p), \sigma(S, r, p-1)$
 - $\mu(S, r, p)$ if $\sigma(S, r, p)$ is not set and $\mu(S, r, p+1)$
   if $\sigma(S, r, p+1)$ is not set
