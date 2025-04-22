$$
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
$$

# New Step

A player may also update its step after receiving a timeout event.

On observing a timeout event of \\( \FilterTimeout(p) \\) for a period \\( p \\), the
player sets \\( s := \Cert \\).

On observing a timeout event of \\( \DeadlineTimeout(p) \\) for a period \\( p \\), the
player sets \\( s := \Next_0 \\).

On observing a timeout event of \\( \DeadlineTimeout(p) + 2^{s_t}\lambda + u \\) where
\\( u \in [0, 2^{s_t}\lambda) \\) sampled uniformly at random, the player sets
\\( s := s_t = \Next_{s_t-3} \\).

In other words,

$$
\begin{aligned}
&N((r, p, s, \bar{s}, V, P, \bar{v}), L, t(\FilterTimeout(p), p))
&&= ((r, p, \Cert, \bar{s}, V, P, \bar{v}), L', \ldots) \\\\\
&N((r, p, s, \bar{s}, V, P, \bar{v}), L, t(\DeadlineTimeout(p), p))
&&= ((r, p, \Next_0, \bar{s}, V, P, \bar{v}), L', \ldots) \\\\\
&N((r, p, s, \bar{s}, V, P, \bar{v}), L,
t(\DeadlineTimeout(p) + 2^{s_t}\lambda + u, p))
&&= ((r, p, \Next_{s_t-3}, \bar{s}, V, P, \bar{v}), L', \ldots).
\end{aligned}
$$

> ⚙️ **IMPLEMENTATION**
>
> New step [reference implementation.](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L94)