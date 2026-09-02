{{#include ../_include/tex-macros/domain-separators.md}}

$$
\newcommand \sk {\mathrm{sk}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Sign {\mathrm{Sign}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Entry {\mathrm{Entry}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Digest {\mathrm{Digest}}
\newcommand \Encoding {\mathrm{Encoding}}
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \Next {\mathit{next}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
$$

# Broadcast Rules

Upon observing messages or receiving timeout events, the player state
machine emits network outputs, which are externally visible. The
player may also append an entry to the ledger.

A correct player emits only valid votes. Suppose the player is identified
with the address \\( I \\) and possesses the secret key \\( \sk \\), and the
agreement is occurring on the ledger \\( L \\). The player constructs
\\( \Vote(I, r, p, s, v) \\) by attempting
\\( y := \Sign(x, x', \sk, B, \bar{B}, Q, \tau, \bar{\tau}) \\) with the
parameters of the [vote validity conditions](./abft-messages.md#votes). If
signing succeeds, the player broadcasts
\\( \Vote(I, r, p, s, v) = (I, r, p, s, v, y) \\); otherwise, the player does
not broadcast anything.

For certain broadcast vote-messages specified here, a node is
forbidden to _equivocate_ (i.e., produce a pair of votes which contain
the same round, period, and step but which vote for different proposal
values). These messages are marked with an asterisk (*) below.

> [!NOTE]
> Implementations typically checkpoint their state to crash-safe storage
> before sending these messages, preventing accidental equivocation after a
> power failure.
> For further details on these checkpoint strategies, refer to the
> [non-normative Ledger specification](../ledger/non-normative/ledger-nn.md). For an in-depth
> review of broadcasting functionalities, refer to the [non-normative Network specification](../network/network-overview.md).

## Resynchronization Attempt

Where specified, a player attempts to resynchronize.

A resynchronization attempt involves the following stages.

A resynchronization attempt has no output unless \\( s \geq \Next_3 \\) or \\( p \geq 3 \\).

First, the player broadcasts its _freshest bundle_, if one exists.

A player's freshest bundle is a bundle \\( \Bundle(r, q, s_q, v) \\) proving the
maximal threshold, under the ordering in [Player State](./abft-player-state.md),
among the thresholds observed for round \\( r \\).

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> Freshness relation [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/events.go#L745).

Second, let \\( q \\) be the period of the freshest bundle if \\( v \neq \bot \\),
or \\( q = 0 \\) if \\( p = 0 \\), and otherwise undefined. If \\( q \\) is
defined, the player broadcasts the payload \\( \Proposal(w) \\), where
\\( w = \sigma(S, r, q) \\) if it is committable, or else \\( w = \bar{v} \\) if
\\( \Proposal(\bar{v}) \in P \\); if neither exists, no payload is broadcast.
The relative order of these outputs is unspecified.

Specifically, a resynchronization attempt:

- Corresponds to no additional outputs if the attempt is inactive, or neither bundle nor payload is available

$$
N(S, L, \ldots) = (S', L, \ldots),
$$

- Corresponds to a broadcast of the freshest bundle, if said bundle exists and no proposal
payload is broadcast

$$
N(S, L, \ldots) = (S', L, (\ldots, \Bundle(r, q, s_q, v), \ldots)),
$$

- Corresponds to a broadcast of both the bundle and the selected proposal payload
\\( \Proposal(w) \\), if said bundle exists and a payload is broadcast

$$
N(S, L, \ldots) = (S', L, (\ldots, \Bundle(r, q, s_q, v), \Proposal(w), \ldots)).
$$

- In \\( p = 0 \\), may correspond to a payload broadcast without a bundle

$$
N(S, L, \ldots) = (S', L, (\ldots, \Proposal(w), \ldots)).
$$

## Proposals

Before entering a period \\( p \neq 0 \\), the player attempts to resynchronize
using its old state.

On observing that \\( (r, p) \\) has begun,

- if \\( p = 0 \\), or the period began due to a next threshold for \\( \bot \\), the
player generates a new proposal \\( (v', \Proposal(v')) \\) and
then broadcasts \\( (\Vote(I, r, p, 0, v'), \Proposal(v')) \\).

- if \\( p > 0 \\) and the period began due to a next threshold for
\\( v \neq \bot \\), the player broadcasts \\( \Vote(I, r, p, 0, v) \\); if
\\( \Proposal(v) \in P \\), the payload follows per [Reproposal Payloads](#reproposal-payloads).

A \\( \Soft \\) or \\( \Cert \\) threshold that fast-forwards the player to its period causes neither action.

A player generates a new proposal by executing the entry-generation
and [Seed](./abft-messages.md#seed) procedures; \\( Q \\) and \\( \gamma \\) are the
seed and proof defined by the latter. Specifically, the player creates a proposal payload
\\( \pi = (e, \gamma, p, I) \\) by setting

- \\( o := \Entry(L, Q) \\),

- \\( e := (o, Q) \\).

The matching proposal-value is \\( v' := (I, p, \Digest(e), \Hash(\Domain{PL} || \Encoding(\pi))) \\).

> [!NOTE]
> For an in-depth overview of how proposal generation may be implemented, refer
> to the Algorand Ledger [non-normative section](../ledger/non-normative/ledger-nn.md).

In other words, if the player generates a new proposal,

$$
N(S, L, \ldots) = (S', L, (\ldots, \Vote(I, r, p, 0, v'), \Proposal(v'))),
$$

while if the player broadcasts an old proposal,

$$
N(S, L, \ldots) = (S', L, (\ldots, \Vote(I, r, p, 0, v))).
$$

## Reproposal Payloads

On accepting a \\( \Vote(I, r, p, 0, v) \\), if \\( \Proposal(v) \in P \\), the
player broadcasts the proposal vote and proposal payload, in place of the vote
relay.

In other words, if \\( \Proposal(v) \in P \\),

$$
N(S, L, \Vote(I, r, p, 0, v)) = (S', L, (\Vote(I, r, p, 0, v), \Proposal(v))).
$$

## Filtering

On observing a timeout event of \\( \FilterTimeout(p) \\), let
\\( \mu = (I_\mu, p_\mu, d_\mu, h_\mu) = \mu(S, r, p) \\), and let
\\( (b, c) = C(S, r, p-1) \\) (see [Player State](./abft-player-state.md))
when \\( p > 0 \\), or \\( (b, c) = (0, \bot) \\) otherwise.
The first applicable rule is used:

- if \\( p > 0 \\), \\( b = 0 \\), and \\( c \neq \bot \\), the player broadcasts*
  \\( \Vote(I, r, p, \Soft, c) \\);

- if \\( \mu = \bot \\), the player does nothing;

- if \\( p_\mu < p \\), the player broadcasts* \\( \Vote(I, r, p, \Soft, \mu) \\)
  exactly when \\( c = \mu \\); and

- otherwise, the player broadcasts* \\( \Vote(I, r, p, \Soft, \mu) \\).

At most one soft vote is broadcast.

> [!NOTE]
> For a detailed overview of how the filtering step may be implemented, refer to
> the Algorand ABFT [non-normative section](./non-normative/abft-nn.md).

In other words, in the carried-value case,

$$
N(S, L, t(\FilterTimeout(p), p)) = (S', L, (\Vote(I, r, p, \Soft, c)));
$$

while in either frozen-value case,

$$
N(S, L, t(\FilterTimeout(p), p)) = (S', L, (\Vote(I, r, p, \Soft, \mu)));
$$

and otherwise,

$$
N(S, L, t(\FilterTimeout(p), p)) = (S', L, \epsilon).
$$

## Certifying

On observing that \\( v = \sigma(S, r, p) \\) becomes committable for the
player's current round and period, if no cert threshold for \\( v \\) was observed
and \\( s \leq \Cert \\), then the player broadcasts*
\\( \Vote(I, r, p, \Cert, v) \\). (It can be shown that this occurs either
after a proposal is received or a soft-vote, which can be part of a
bundle, is received.)

> [!NOTE]
> For a detailed overview of how the certification step may be implemented, refer
> to the Algorand ABFT [non-normative section](./non-normative/abft-nn.md).

In other words, if observing a soft-vote causes a proposal-value to
become committable,

$$
N(S, L, \Vote(I, r, p, \Soft, v)) = (S', L, (\ldots, \Vote(I, r, p, \Cert, v)));
$$

while if observing a bundle causes a proposal-value to become
committable,

$$
N(S, L, \Bundle(r, p, \Soft, v)) = (S', L, (\ldots, \Vote(I, r, p, \Cert, v)));
$$

and if observing a proposal causes a proposal-value to become
committable,

$$
N(S, L, \Proposal(v)) = (S', L, (\ldots, \Vote(I, r, p, \Cert, v)));
$$

as long as \\( s \leq \Cert \\) and commitment does not occur.

## Commitment

On observing \\( \Bundle(r, p, \Cert, v) \\) or its matching validated payload
\\( \Proposal(v) \\), if it has observed both, the player _commits_ the entry
\\( e \\) corresponding to \\( \Proposal(v) \\); i.e., the player appends \\( e \\)
to the sequence of entries on its ledger \\( L \\).

> [!NOTE]
> For further details on how entry commitment may be implemented, refer to the
> Algorand Ledger [non-normative section](../ledger/non-normative/ledger-nn.md).

In other words, if observing a cert-vote causes the player to commit
\\( e \\),

$$
N(S, L, \Vote(I, r, p, \Cert, v)) = (S', L || e, \ldots);
$$

while if observing a bundle causes the player to commit \\( e \\),

$$
N(S, L, \Bundle(r, p, \Cert, v)) = (S', L || e, \ldots);
$$

while if observing a proposal causes the player to commit \\( e \\),

$$
N(S, L, \Proposal(v)) = (S', L || e, \ldots).
$$

> [!NOTE]
> A player may observe \\( \Bundle(r, p, \Cert, v) \\) before holding the
> matching \\( \Proposal(v) \\); it may request \\( e \\) from its peers or
> continue running the protocol until \\( e \\) arrives.

## Recovery

On observing a timeout event \\( t(T, p) \\) that sets \\( s := \Next_h \\)
(see [New Step](./abft-state-transitions.md#new-step)), the player attempts to
resynchronize and broadcasts*
\\( \Vote(I, r, p, \Next_h, v) \\) where

- \\( v = \sigma(S, r, p) \\) if it is committable in \\( (r, p) \\),

- \\( v = c \\) if \\( p > 0 \\), \\( C(S, r, p-1) = (0, c) \\), and \\( c \neq \bot \\),

- and \\( v = \bot \\) otherwise.

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> Next vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L214).
>
> Next vote timeout ranges computation [reference implementation](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/agreement/types.go#L103).
>
> Call to \\( \Next_0 \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L125).
>
> Subsequent calls to \\( \Next_{st} \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L128).
>
> Step increase in recovery step timeouts [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L131).

> [!NOTE]
> For a detailed overview of how the recovery routine may be implemented, refer
> to the Algorand ABFT [non-normative section](./non-normative/abft-nn.md).

In other words, if a proposal-value \\( v \\) is committable in the current
period,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_h, v)));
$$

while in the carried-value case,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_h, c)));
$$

and otherwise,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_h, \bot))).
$$

## Fast Recovery

On observing a timeout event of \\( T = k\lambda_f + u \\), where \\( k \\) is a positive
integer and \\( u \in [0, \lambda_f) \\) is sampled uniformly at random, the player
attempts to resynchronize. The first such event after entering a round or period
lies in \\( [\lambda_f, 2\lambda_f) \\). Also,

- The player broadcasts* \\( \Vote(I, r, p, \Late, v) \\) if \\( v = \sigma(S, r, p) \\)
is committable in \\( (r, p) \\).

- The player broadcasts* \\( \Vote(I, r, p, \Redo, c) \\) if \\( p > 0 \\),
\\( C(S, r, p-1) = (0, c) \\), and \\( c \neq \bot \\).

- Otherwise, the player broadcasts* \\( \Vote(I, r, p, \Down, \bot) \\).

The player also broadcasts all observed \\( \Late \\), \\( \Redo \\), and \\( \Down \\)
votes for its current round and period. The relative order of these outputs is unspecified.

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> Fast recovery [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L150).

> [!NOTE]
> For a detailed pseudocode overview of the fast recovery routine, along with protocol
> recovery run examples, refer to the Algorand ABFT [non-normative section](./non-normative/abft-nn.md).
