$$
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Bundle {\mathrm{Bundle}}
$$

# New Period

When a player observes that a new period \\( (r, p) \\) has begun, the player sets

- \\( \bar{s} := s \\),

- \\( s := 0 \\).

Also, the player sets \\( \bar{v} := v \\) if the player has observed \\( \Bundle(r, p-1, s, v) \\)
given some values \\( s > \Cert \\) (or \\( s = \Soft \\)), \\( v \neq \bot \\); if none
exist, the player sets \\( \bar{v} := \sigma(S, r, p-i) \\) if it exists, where \\( p-i \\)
was the player's period immediately before observing the new period; and if none exist, the
player does not update \\( \bar{v} \\).

In other words, if \\( \Bundle(r, p-1, s, v) \in V' \\) for some \\( v \neq \bot, s > \Cert \\)
or \\( s = \Soft \\), then

$$
N((r, p-i, s, \bar{s}, V, P, \bar{v}), L, \ldots)
= ((r, p, 0, s, V', P, v), L', \ldots);
$$

and otherwise, if \\( \Bundle(r, p-1, s, \bot) \in V' \\) for some \\( s > \Cert \\)
with \\( \sigma(S, r, p-i) \\) defined, then

$$
N((r, p-i, s, \bar{s}, V, P, \bar{v}), L, \ldots)
= ((r, p, 0, s, V', P, \sigma(S, r, p-i)), L', \ldots);
$$

and otherwise

$$
N((r, p-i, s, \bar{s}, V, P, \bar{v}), L, \ldots)
= ((r, p, 0, s, V', P, \bar{v}), L', \ldots);
$$

for some \\( i > 0 \\) (where \\( S = (r, p-i, s, \bar{s}, V, P, \bar{v}) \\)).

{{#include ../_include/styles.md:impl}}
> New period [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L411).
