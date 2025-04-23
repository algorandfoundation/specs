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

<!-- UPDATE PROPOSAL

We define a partial order relation of _freshness_, \\( f_> \\), in a hypothetical
set of complete bundles observed for the same round \\( r \\). Given two distinct
complete observed bundles, \\( \Bundle_e(r, p_e, s_e, v_e) \\) and \\( \Bundle_o(r, p_o, s_o, v_o) \\),
then:

- \\( \Bundle_e(r, p_e, \Cert, v_e) f_> \Bundle_o(r, p_o, s_o, v_o) \\) (note that it
is implicitly assumed that \\( s_o \neq \Cert \\)), or else

- \\( s_o, s_e \neq \Cert \\) and \\( \Bundle_e(r, p+i, s_e, v_e) f_> \Bundle_o(r, p, s_o, v_o) \\),
with \\( i > 0 \\), or else

- \\( \Bundle_e(r, p, Next_s, v_e) f_> \Bundle_o(r, p, \Soft, v_o )\\), otherwise

- \\( Bundle_e(r, p, \Next_s, \bot) \ f_> \Bundle_o(r, p, \Next_{s'}, v_o) \\)
(for any \\( v_o \neq \bot \\)).

For all other cases, the relation is undefined.

-->

> ⚙️ **IMPLEMENTATION**
>
> Freshness relation [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/events.go#L745).

Second, if the player broadcasted a bundle \\( \Bundle(r, p, s, v) \\), and \\( v \neq \bot \\),
then the player broadcasts \\( \Proposal(v) \\) if the player has it.

Third, if no \\( \Proposal(v) \\) associated with the freshest bundle exists, the protocol
still falls back to relaying the pinned value \\( \bar{v} \\) for liveness.

> ⚙️ **IMPLEMENTATION**
>
> In the [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L518),
> resynchronization attempts are performed by the `partitionPolicy(.)` function.

Specifically, a resynchronization attempt:

- Corresponds to no additional outputs if no freshest bundle exists

$$
N(S, L, \ldots) = (S', L', \ldots),
$$

- Corresponds to a broadcast of the freshest bundle after a relay output and before
any subsequent broadcast outputs, if said bundle exists, no matching proposal exists,
and the pinned value \\( \bar{v} = \bot \\) for the same round

$$
N(S, L, \ldots) = (S', L', (\ldots, \Bundle^\ast(r, p, s, v), \ldots)),
$

- Corresponds to a broadcast of the freshest bundle and the pinned value for the same
round after a relay output and before any subsequent broadcast outputs, if said bundle
exists, no matching proposal exists, and a pinned value \\( \bar{v} \\) for the same
round exists

$$
N(S, L, \ldots) = (S', L', (\ldots, \Bundle^\ast(r, p, s, v), \bar{v}, \ldots)),
$$

- Otherwise corresponds to a broadcast of both a bundle and its associated
proposal after a relay output and before any subsequent broadcast
outputs

$$
N(S, L, \ldots) = (S', L', (\ldots, \Bundle^\ast(r, p, s, v), \Proposal(v), \ldots)).
$$