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