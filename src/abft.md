---
numbersections: true
title: "Algorand Byzantine Fault Tolerance Protocol Specification"
date: \today
abstract: >
  The _Algorand Byzantine Fault Tolerance protocol_ is an interactive protocol which produces a sequence of common information between a set of participants.
---



State Machine
=============

\newcommand \Player {\mathrm{Player}}
\newcommand \abold {\mathbf{a}}
\newcommand \vbar {\bar{v}}
\newcommand \Timer {\mathcal{T}}

This specification defines the Algorand agreement protocol as a state
machine.  The input to the state machine is some serialization of
events, which in turn results in some serialization of network
transmissions from the state machine.

We can define the operation of the state machine as transitions
between different states.  A transition $N$ maps some initial state
$S_0$, a ledger $L_0$, and an event $e$ to an output state $S_1$, an
output ledger $L_1$, and a sequence of output network transmissions
$\abold = (a_1, a_2, \ldots, a_n)$.
We write this as
$$
N(S_0, L_0, e) = (S_1, L_1, \abold).
$$
If no transmissions are output, we write that $\abold = \epsilon$.


Events
------

The state machine _receives_ two types of events as inputs.

1. _message events_: A message event is received when a vote, a
   proposal, or a bundle is received.  A message event is simply
   written as the message that is received.
2.  _timeout events_: A timeout event is received when a specific
   amount of time passes after the beginning of a period.  A timeout
   event $\lambda$ seconds after period $p$ begins is denoted
   $t(\lambda, p)$.


Outputs
-------

The state machine produces a series of network transmissions as
output.  In each transmission, the player broadcasts a vote, a
proposal, or a bundle to the rest of the network.

A player may perform a special broadcast called a _relay_.  In a
relay, the data received from another peer is broadcast to all peers
except for the sender.

A broadcast action is simply written as the message to be
transmitted.  A relay action is written as the same message except
with an asterisk.  For instance, an action to relay a vote is written
as $\Vote^*(r, p, s, v)$.


Player State Definition
=======================

\newcommand \sbar {\bar{s}}

We define the _player state_ $S$ to be the following tuple:
$$
S = (r, p, s, \sbar, V, P, \vbar)
$$
where

 - $r$ is the current round,
 - $p$ is the current period,
 - $s$ is the current step,
 - $\sbar$ is the _last concluding step_,
 - $V$ is the set of all votes,
 - $P$ is the set of all proposals, and
 - $\vbar$ is the _pinned_ value.
 
We say that a player has _observed_ 

 - $\Proposal(v)$ if $\Proposal(v) \in P$
 - $\Vote_l(r, p, s, v)$ if $\Vote_l(r, p, s, v) \in V$
 - $\Bundle(r, p, s, v)$ if $\Bundle_l(r, p, s, v) \subset V$
 - that round $r$ (period 0) has _begun_ if there exists some $p$ such
   that $\Bundle(r-1, p, \Cert, v)$ was also observed
 - that round $r$, period $p > 0$ has _begun_ if there exists some $p$
   such that either
    - $\Bundle(r, p-1, s, v)$ was also observed for some 
      $s > \Cert, v$, or
    - $\Bundle(r, p, \Soft, v)$ was observed for some $v$.

An event causes a player to observe something if the player has not
observed that thing before receiving the event and has observed that
thing after receiving the event. For instance, a player may observe a
vote $\Vote$, which adds this vote to $V$:
$$
 N((r, p, s, \sbar, V, P, \vbar), L_0, \Vote)
= ((r', p', \ldots, V \cup \{\Vote\}, P, \vbar'), L_1, \ldots).
$$
We abbreviate the transition above as
$$
 N((r, p, s, \sbar, V, P, \vbar), L_0, \Vote)
 = ((S \cup \Vote, P, \vbar), L_1, \ldots).
$$
Note that _observing_ a message is distinct from _receiving_ a
message.  A message which has been received might not be observed (for
instance, the message may be from an old round).  Refer to the [relay
rules][Relay Rules] for details.


Special Values
--------------

We define two functions $\mu(S, r, p), \sigma(S, r, p)$, which are
defined as follows:

$\mu(S, r, p)$ is defined as the proposal-value in the vote in round
$r$ and period $p$ with the minimal credential. More formally, let
$$
V_{r, p} = \{\Vote(I, r, p, 0, v) | \Vote \in V\}
$$
where $V$ is the set of votes in $S$. Then if $\Vote_l(r, p, 0, v_l)$
is the vote with the smallest weight in $V_{r, p}$, then
$\mu(S, r, p) = v_l$.

If $V_{r, p}$ is empty, then $\mu(S, r, p) = \bot$.

$\sigma(S, r, p)$ is defined as the sole proposal-value for which
there exists a soft-bundle in round $r$ and period $p$. More formally,
suppose $\Bundle(r, p, \Soft, v) \subset V$. Then
$\sigma(S, r, p) = v$.

If no such soft-bundle exists, then $\sigma(S, r, p) = \bot$.

If there exists a proposal-value $v$ such that $\Proposal(v) \in V$
and $\sigma(S, r, p) = v$, we say that $v$ is _committable for round
$r$, period $p$_ (or simply that $v$ is _committable_ if $(r, p)$ is
unambiguous).


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


Internal Transitions
====================

After receiving message events, the player updates some components of
its state.


New Round
---------

When a player observes that a new round $(r, 0)$ has begun, the player
sets $\sbar := s, \vbar := \bot, p := 0, s := 0$. Specifically,
if a new round has begun,
$$
 N((r-i, p, s, \sbar, V, P, \vbar), L, \ldots)
 = ((r, 0, 0, s, V', P', \bot), L', \ldots)
$$
for some $i > 0$.


New Period
----------

When a player observes that a new period $(r, p)$ has begun, the
player sets $\sbar := s, s := 0$. Also, the player sets $\vbar := v$ if
the player has observed $\Bundle(r, p-1, s, v)$ given some values $s > \Cert$
(or $s = \Soft$), $v \neq \bot$; if none exist, the player sets $\vbar :=
\sigma(S, r, p-i)$ if it exists, where $p-i$ was the player's period
immediately before observing the new period; and if none exist, the
player does not update $\vbar$.

In other words, if $\Bundle(r, p-1, s, v) \in V'$ for some
$v \neq \bot, s > \Cert$ or $s = \Soft$,
$$
 N((r, p-i, s, \sbar, V, P, \vbar), L, \ldots)
 = ((r, p, 0, s, V', P, v), L', \ldots);
$$
and otherwise, if $\Bundle(r, p-1, s, \bot) \in V'$ for some $s > \Cert$
with $\sigma(S, r, p-i)$ defined,
$$
 N((r, p-i, s, \sbar, V, P, \vbar), L, \ldots)
 = ((r, p, 0, s, V', P, \sigma(S, r, p-i)), L', \ldots);
$$
and otherwise
$$
 N((r, p-i, s, \sbar, V, P, \vbar), L, \ldots)
 = ((r, p, 0, s, V', P, \vbar), L', \ldots);
$$
for some $i > 0$ (where $S = (r, p-i, s, \sbar, V, P, \vbar))$.


Garbage Collection
------------------

When a player observes that either a new round or a new period
$(r, p)$ has begun, then the player _garbage-collects_ old state. In
other words,
$$
 N((r-i, p-i, s, \sbar, V, P, \vbar), L, \ldots)
 = ((r, p, \sbar, 0, V' \setminus V^*_{r, p}, P' \setminus P^*_{r, p},
    \vbar), L, \ldots).
$$
where
$$
\begin{aligned}
V^*_{r, p}
 &=    \{\Vote(I, r', p', \sbar, v) | \Vote \in V, r' < r\} \\
 &\cup \{\Vote(I, r', p', \sbar, v) | \Vote \in V, r' = r, p' + 1 < p\}
\end{aligned}
$$
and $P^*_{r, p}$ is defined similarly.


New Step
--------

A player may also update its step after receiving a timeout event.

On observing a timeout event of $\FilterTimeout(p)$ for period $p$, the player sets
$s := \Cert$.

On observing a timeout event of $\DeadlineTimeout(p)$ for period $p$, the
player sets $s := \Next_0$.

On observing a timeout event of
$\DeadlineTimeout(p) + 2^{s_t}\lambda + r$ where
$r \in [0, 2^{s_t}\lambda]$ sampled uniformly at random, the player sets
$s := s_t$.

In other words,
$$
\begin{aligned}
  &N((r, p, s, \sbar, V, P, \vbar), L, t(\FilterTimeout(p), p))
 &&= ((r, p, \Cert, \sbar, V, P, \vbar), L', \ldots) \\
  &N((r, p, s, \sbar, V, P, \vbar), L, t(\DeadlineTimeout(p), p))
 &&= ((r, p, \Next_0, \sbar, V, P, \vbar), L', \ldots) \\
  &N((r, p, s, \sbar, V, P, \vbar), L,
     t(\DeadlineTimeout(p) + 2^{s_t}\lambda + r, p))
 &&= ((r, p, s_t, \sbar, V, P, \vbar), L', \ldots).
 \end{aligned}
$$