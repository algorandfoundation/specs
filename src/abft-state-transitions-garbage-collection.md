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