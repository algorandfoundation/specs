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