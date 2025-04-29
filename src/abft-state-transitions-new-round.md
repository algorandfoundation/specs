# New Round

When a player observes that a new round \\( (r, 0) \\) has begun, the player
sets

- \\( \bar{s} := s \\),

- \\( \bar{v} := \bot \\),

- \\( p := 0 \\),

- \\( s := 0 \\).

Specifically, if a new round has begun, then

$$
N((r-i, p, s, \bar{s}, V, P, \bar{v}), L, \ldots)
= ((r, 0, 0, s, V', P', \bot), L', \ldots)
$$

for some \\( i > 0 \\).

{{#include ./.include/styles.md:impl}}
> New round [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L454).