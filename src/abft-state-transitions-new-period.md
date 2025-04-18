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