$$
\newcommand \Vote {\mathrm{Vote}}
$$

# Garbage Collection

When a player observes that either a new _round_ or a new _period_
\\( (r, p) \\) has begun, then the player _garbage-collects_ old state.

In other words,

$$
N((r-i, p-i, s, \bar{s}, V, P, \bar{v}), L, \ldots)
= ((r, p, \bar{s}, 0, V' \setminus V^\ast_{r, p}, P' \setminus P^\ast_{r, p}, \bar{v}), L, \ldots)
$$

where

$$
\begin{aligned}
V^\ast_{r, p}
&=    \\{\Vote(I, r', p', \bar{s}, v) | \Vote \in V, r' < r\\} \\\\\\
&\cup \\{\Vote(I, r', p', \bar{s}, v) | \Vote \in V, r' = r, p' + 1 < p\\}
\end{aligned}
$$

and \\( P^\ast_{r, p} \\) is defined similarly.
