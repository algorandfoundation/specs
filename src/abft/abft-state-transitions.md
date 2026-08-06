$$
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
\newcommand \Next {\mathit{next}}
$$

# State Transitions

After receiving message events or timeout events, the player may update some components
of its state.

## New Round

When a player observes that a new round \\( (r, 0) \\) has begun, the player
sets

- \\( \bar{s} := s \\),

- \\( \bar{v} := \bot \\),

- \\( p := 0 \\),

- \\( s := \Soft \\).

Specifically, if a new round has begun, then

$$
N((r-i, p, s, \bar{s}, V, P, \bar{v}, H), L, \ldots)
= ((r, 0, \Soft, s, V', P', \bot, H'), L', \ldots)
$$

for some \\( i > 0 \\).

Initially, the player starts round \\( |L|+1 \\) in \\( p = 0 \\) and \\( s = \Soft \\).

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> New round [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L454).

## New Period

When a player observes that a new period \\( (r, p) \\) has begun due to a threshold
\\( \Bundle(r, q, s_q, v) \\), the player sets

- \\( \bar{s} := s \\),

- \\( s := \Soft \\).

Also, the player sets \\( \bar{v} := v \\) if \\( v \neq \bot \\); otherwise,
the player sets \\( \bar{v} := \sigma(S, r, p-i) \\) if \\( \sigma(S, r, p-i) \neq \bot \\),
where \\( p-i \\) was the player's period immediately before observing the new period
and otherwise, the player does not update \\( \bar{v} \\).

In other words, if \\( v \neq \bot \\), then

$$
N((r, p-i, s, \bar{s}, V, P, \bar{v}, H), L, \ldots)
= ((r, p, \Soft, s, V', P, v, H'), L', \ldots);
$$

and otherwise, if \\( \sigma(S, r, p-i) \neq \bot \\), then

$$
N((r, p-i, s, \bar{s}, V, P, \bar{v}, H), L, \ldots)
= ((r, p, \Soft, s, V', P, \sigma(S, r, p-i), H'), L', \ldots);
$$

and otherwise

$$
N((r, p-i, s, \bar{s}, V, P, \bar{v}, H), L, \ldots)
= ((r, p, \Soft, s, V', P, \bar{v}, H'), L', \ldots);
$$

for some \\( i > 0 \\) (where \\( S = (r, p-i, s, \bar{s}, V, P, \bar{v}, H) \\)).

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> New period [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L411).

## Garbage Collection

When a player observes that either a new _round_ or a new _period_
\\( (r, p) \\) has begun, then the player _garbage-collects_ old votes and proposal payloads.

In other words,

$$
N((r_0, p_0, s, \bar{s}, V, P, \bar{v}, H), L, \ldots)
= ((r, p, \Soft, s, V' \setminus V^\ast_{r, p}, P' \setminus P^\ast_{r, p}, \bar{v}', H'), L', \ldots)
$$

where

$$
\begin{aligned}
V^\ast_{r, p}
&=    \\{\Vote(I, r', p', s', v) \in V' \mid r' < r\\} \\\\\\
&\cup \\{\Vote(I, r', p', s', v) \in V' \mid r' = r, p' + 1 < p\\}
\end{aligned}
$$

and

$$
P^\ast_{r, p} = \\{\mathrm{Proposal}(v) \in P' \mid v \neq \bar{v}'
\land \nexists I, r', p', s' : \Vote(I, r', p', s', v) \in V' \setminus V^\ast_{r, p}\\}.
$$

## New Step

A player may also update its step after receiving a timeout event.

On observing a timeout event of \\( \FilterTimeout(p) \\) for its current period \\( p \\),
the player freezes \\( \mu(S, r, p) \\) and sets \\( s := \Cert \\).

On observing a timeout event of \\( \DeadlineTimeout(p) \\) for its current period \\( p \\),
the player sets \\( s := \Next_0 \\).

For \\( 1 \leq s_t \leq 249 \\), on observing a timeout event of \\( \DeadlineTimeout(p) + (2^{s_t} - 1)\lambda + u \\)
for its current period, where \\( u \in [0, 2^{s_t}\lambda) \\) is sampled uniformly at random, the player sets
\\( s := \Next_{s_t} \\).

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> New step [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L94).

In other words,

$$
\begin{aligned}
&N((r, p, s, \bar{s}, V, P, \bar{v}, H), L, t(\FilterTimeout(p), p)) \\\\
&\qquad = ((r, p, \Cert, \bar{s}, V, P, \bar{v}, H'), L', \ldots) \\\\[0.35em]
&N((r, p, s, \bar{s}, V, P, \bar{v}, H), L, t(\DeadlineTimeout(p), p)) \\\\
&\qquad = ((r, p, \Next_0, \bar{s}, V, P, \bar{v}, H'), L', \ldots) \\\\[0.35em]
&N((r, p, s, \bar{s}, V, P, \bar{v}, H), L, t(\DeadlineTimeout(p) + (2^{s_t} - 1)\lambda + u, p)) \\\\
&\qquad = ((r, p, \Next_{s_t}, \bar{s}, V, P, \bar{v}, H'), L', \ldots).
\end{aligned}
$$
