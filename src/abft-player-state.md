$$
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Priority {\mathrm{Priority}}
\newcommand \VRF {\mathrm{VRF}}
\newcommand \ProofToHash {\mathrm{ProofToHash}}
\newcommand \Hash {\mathrm{Hash}}
$$

# Player State Definition

We define the _player state_ \\( S \\) to be the following tuple:

$$
S = (r, p, s, \bar{s}, V, P, \bar{v})
$$

where

- \\( r \\) is the current round,
- \\( p \\) is the current period,
- \\( s \\) is the current step,
- \\( \bar{s} \\) is the _last concluding step_,
- \\( V \\) is the set of all votes,
- \\( P \\) is the set of all proposals, and
- \\( \bar{v} \\) is the _pinned_ value.

We say that a player has _observed_

- \\( \Proposal(v) \\) if \\( \Proposal(v) \in P \\),
- \\( \Vote(r, p, s, v) \\) if \\( \Vote(r, p, s, v) \in V \\),
- \\( \Bundle(r, p, s, v) \\) if \\( \Bundle(r, p, s, v) \subset V \\),
- That the round \\( r \\) (period \\( p = 0 \\)) has _begun_ if there exists some
\\( p \\) such that \\( \Bundle(r-1, p, \Cert, v) \\) was also observed for some
\\( v \\),
- That the round \\( r \\), period \\( p > 0 \\) has _begun_ if there exists some
\\( p \\) such that either
  - \\( \Bundle(r, p-1, s, v) \\) was also observed for some \\( s > \Cert, v \\), or
  - \\( \Bundle(r, p, \Soft, v) \\) was observed for some \\( v \\).

An event causes a player to observe something if the player has not
observed that thing before receiving the event and has observed that
thing after receiving the event. For instance, a player may observe a
vote \\( \Vote \\), which adds this vote to \\( V \\):

$$
N((r, p, s, \bar{s}, V, P, \bar{v}), L_0, \Vote)
= ((r', p', \ldots, V \cup \\{\Vote\\}, P, \bar{v}'), L_1, \ldots)
$$

We abbreviate the transition above as

$$
N((r, p, s, \bar{s}, V, P, \bar{v}), L_0, \Vote)
= ((S \cup \Vote, P, \bar{v}), L_1, \ldots)
$$

Note that _observing_ a message is distinct from _receiving_ a
message. A message which has been received might not be observed (for
instance, the message may be from an old round). Refer to the [relay rules](#relay-rules)
for details.

## Special Values

We define two functions \\( \mu(S, r, p), \sigma(S, r, p) \\), which are
defined as follows:

The _frozen value_ \\( \mu(S, r, p) \\) is defined as the _proposal-value_ \\( v \\)
in the proposal vote in round \\( r \\) and period \\( p \\) with the minimal credential.

More formally, then, let

$$
V_{r, p, 0} = \\{\Vote(I, r, p, 0, v) | \Vote \in V\\}
$$

where \\( V \\) is the set of votes in \\( S \\).

Then if \\( \Vote_l(r, p, 0, v_l) \\) is the vote with the smallest weight in
\\( V_{r, p} \\), then \\( \mu(S, r, p) = v_l \\).

If \\( V_{r, p} \\) is empty, then \\( \mu(S, r, p) = \bot \\).

The _staged value_ \\( \sigma(S, r, p) \\) is defined as the sole _proposal-value_
for which there exists a soft-bundle in round \\( r \\) and period \\( p \\).

More formally, suppose \\( \Bundle(r, p, Soft, v) \subset V \\). Then
\\( \sigma(S, r, p) = v \\).

If no such soft-bundle exists, then \\( \sigma(S, r, p) = \bot \\).

If there exists a proposal-value \\( v \\) such that \\( \Proposal(v) \in P \\) and
\\( \sigma(S, r, p) = v \\), we say that \\( v \\) is _committable for round \\( r \\),
period_ \\( p \\) (or simply that \\( v \\) is _committable_ if \\( (r, p) \\) is
unambiguous).

{{#include ./.include/styles.md:impl}}
> The current implementation constructs a [Proposal Tracker](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/proposalTracker.go#L93)
> which, amongst other things, is in charge of handling both frozen and staged value
> tracking.