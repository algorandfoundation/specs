{{#include ../_include/tex-macros/domain-separators.md}}

$$
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
\newcommand \Priority {\mathrm{Priority}}
\newcommand \VRF {\mathrm{VRF}}
\newcommand \ProofToHash {\mathrm{ProofToHash}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Encoding {\mathrm{Encoding}}
$$

# Player State Definition

We define the _player state_ \\( S \\) to be the following tuple:

$$
S = (r, p, s, \bar{s}, V, P, \bar{v}, H)
$$

where

- \\( r \\) is the current round,
- \\( p \\) is the current period,
- \\( s \\) is the current step,
- \\( \bar{s} \\) is the _last concluding step_,
- \\( V \\) is the set of accepted votes,
- \\( P \\) is the set of validated proposal payloads,
- \\( \bar{v} \\) is the _pinned_ value,
- \\( H \\) is the ordered history of protocol events and outputs.

The definitions below are derived from \\( S \\).

We say that a player has _observed_

- \\( \Proposal(v) \\) if \\( \Proposal(v) \in P \\),
- \\( \Vote(r, p, s, v) \\) if \\( \Vote(r, p, s, v) \in V \\),
- \\( \Bundle(r, p, s, v) \\) if \\( \Bundle(r, p, s, v) \subset V \\) and its threshold
is fresher than every threshold previously observed for round \\( r \\),
- That the round \\( r > 0 \\) (period \\( p = 0 \\)) has _begun_ if an entry was
committed in round \\( r-1 \\),
- That the round \\( r \\), period \\( p > 0 \\) has _begun_ if either
  - \\( \Bundle(r, p-1, s, v) \\) was observed for some \\( s > \Cert, v \\), or
  - \\( \Bundle(r, p, s, v) \\) was observed for some \\( s \in \{ \Soft, \Cert \}, v \\).

An event causes a player to observe something if the player has not
observed that thing before receiving the event and has observed that
thing after receiving the event. For instance, a player may observe a
vote \\( \Vote \\), which adds this vote to \\( V \\):

$$
N((r, p, s, \bar{s}, V, P, \bar{v}, H), L_0, \Vote)
= ((r', p', s', \bar{s}', V \cup \\{\Vote\\}, P, \bar{v}', H'), L_1, \ldots)
$$

We write \\( S \cup \\{\Vote\\} \\) for \\( S \\) with \\( \Vote \\) added to
\\( V \\); thus the transition above is

$$
N((r, p, s, \bar{s}, V, P, \bar{v}, H), L_0, \Vote)
= (S \cup \\{\Vote\\}, L_1, \ldots)
$$

Note that _observing_ a message is distinct from _receiving_ a
message. A message which has been received might not be observed (for
instance, the message may be from an old round). Refer to the [relay rules](./abft-relay-rules.md)
for details.

## Special Values

We define two functions \\( \mu(S, r, p), \sigma(S, r, p) \\), which are
defined as follows:

The _frozen value_ \\( \mu(S, r, p) \\) is defined as the _proposal-value_ \\( v \\)
in the highest-priority accepted proposal vote in round \\( r \\) and period \\( p \\).

More formally, then, let

$$
V_{r, p, 0} = \\{\Vote(I, r, p, 0, v) | \Vote \in V\\}
$$

where \\( V \\) is the set of votes in \\( S \\).

Let \\( z_k \\) be the raw selection-VRF output in \\( \Vote_k \in V_{r, p, 0} \\)
and \\( w_k \\) its weight. Its priority is

$$
\Priority(\Vote_k) = \min_{1 \leq i \leq w_k}\Hash(\Domain{CR} || \Encoding((z_k, I_k, i))).
$$

Hash outputs are compared as unsigned big-endian integers. A proposal vote has
higher priority when its \\( \Priority \\) value is smaller.
\\( \mu(S, r, p) \\) is the value of the highest-priority accepted proposal vote.
It is fixed as soon as a value is staged for \\( (r, p) \\) or the player processes
the filter timeout of period \\( p \\), whichever occurs first; later proposal votes do not change it.

If \\( V_{r, p, 0} \\) is empty, then \\( \mu(S, r, p) = \bot \\).

The _staged value_ \\( \sigma(S, r, p) \\) is defined as the sole _proposal-value_
for which the player observed a soft or cert threshold in round \\( r \\) and period \\( p \\).

More formally, if the player observed a threshold \\( \Bundle(r, p, s, v) \\), where \\( s \in \\{\Soft, \Cert\\} \\), then
\\( \sigma(S, r, p) = v \\).

If no such threshold exists, then \\( \sigma(S, r, p) = \bot \\).

If there exists a proposal-value \\( v \\) such that \\( \Proposal(v) \in P \\) and
\\( \sigma(S, r, p) = v \\), we say that \\( v \\) is _committable for round \\( r \\),
period_ \\( p \\) (or simply that \\( v \\) is _committable_ if \\( (r, p) \\) is
unambiguous).

The _relevant value_ is

$$
\rho(S, r, p) =
\begin{cases}
\sigma(S, r, p) & \text{if } \sigma(S, r, p) \neq \bot, \\\\
\mu(S, r, p) & \text{otherwise}.
\end{cases}
$$

For each \\( (r, p) \\), let \\( C(S, r, p) = (b, v) \\) summarize the
thresholds with step at least \\( \Next_0 \\) formed in \\( H \\): \\( b = 1 \\)
if any has proposal value \\( \bot \\), and \\( v \\) is the proposal value of
the latest non-bottom threshold, or \\( \bot \\) if none exists.

For thresholds in one round, \\( T_1 \\) is _fresher_ than \\( T_0 \\) if the
first applicable condition holds:

1. \\( T_1 \\) is a cert threshold and \\( T_0 \\) is not;
1. neither is a cert threshold and \\( T_1 \\) has the later period;
1. they have the same period, \\( T_1 \\) is a next threshold, and \\( T_0 \\)
   is a soft threshold;
1. both are next thresholds in the same period, \\( T_1 \\) is for \\( \bot \\),
   and \\( T_0 \\) is not.

The numeric next-step index does not otherwise affect freshness. A threshold
for a future round is considered when that round begins. The summary \\( C \\)
includes thresholds that are not fresh enough to be observed.

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> The current implementation constructs a [Proposal Tracker](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/proposalTracker.go#L93)
> which, amongst other things, is in charge of handling both frozen and staged value
> tracking.
