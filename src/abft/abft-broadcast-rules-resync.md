$$
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Proposal {\mathrm{Proposal}}
$$

# Resynchronization Attempt

Where specified, a player attempts to resynchronize.

A resynchronization attempt involves the following stages.

First, the player broadcasts its _freshest bundle_, if one exists.

A player's freshest bundle is a complete bundle defined as follows:

- \\( \Bundle(r, p, \Soft, v) \subset V \\) for some \\( v \\), if it exists, or
else

- \\( \Bundle(r, p-1, s, \bot) \subset V \\) for some \\( s > \Cert \\), if it exists,
or else

- \\( \Bundle(r, p-1, s, v) \subset V \\) for some \\( s > \Cert, v \neq \bot \\),
if it exists.

{{#include ../_include/styles.md:impl}}
> Freshness relation [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/events.go#L745).

Second, if the player broadcasted a bundle \\( \Bundle(r, p, s, v) \\), and \\( v \neq \bot \\),
then the player broadcasts \\( \Proposal(v) \\) if the player has it.

Specifically, a resynchronization attempt:

- Corresponds to no additional outputs if no freshest bundle exists

$$
N(S, L, \ldots) = (S', L', \ldots),
$$

- Corresponds to a broadcast of the freshest bundle after a relay output and before
any subsequent broadcast outputs, if said bundle exists, no matching proposal exists

$$
N(S, L, \ldots) = (S', L', (\ldots, \Bundle^\ast(r, p, s, v), \ldots)),
$$

- Otherwise corresponds to a broadcast of both a bundle and its associated
proposal after a relay output and before any subsequent broadcast
outputs

$$
N(S, L, \ldots) = (S', L', (\ldots, \Bundle^\ast(r, p, s, v), \Proposal(v), \ldots)).
$$