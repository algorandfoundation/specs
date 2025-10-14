$$
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Bundle {\mathrm{Bundle}}
$$

# Recovery

On observing a timeout event of

- \\( T = \DeadlineTimeout(p) \\) or

- \\( T = \DeadlineTimeout(p) + 2^{s_t}\lambda + u \\) where
\\( u \in [0, 2^{s_t}\lambda] \\) sampled uniformly at random,

the player attempts to resynchronize and then broadcasts*
\\( \Vote(I, r, p, \Next_h, v) \\) where

- \\( v = \sigma(S, r, p) \\) if \\( v \\) is committable in \\( (r, p) \\),

- \\( v = \bar{v} \\) if there does not exist a \\( s_0 > \Cert \\) such that
\\( \Bundle(r, p-1, s_0, \bot) \\) was observed and there exists an \\( s_1 > \Cert \\)
such that \\( \Bundle(r, p-1, s_1, \bar{v} )\\) was observed,

- and \\( v = \bot \\) otherwise.

{{#include ../_include/styles.md:impl}}
> Next vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L214).
>
> Next vote timeout ranges computation [reference implementation](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/agreement/types.go#L103).
>
> Call to \\( \Next_0 \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L125).
>
> Subsequent calls to \\( \Next_{st} \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L128).
>
> Step increase in recovery step timeouts [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L131).

> For a detailed overview of how the recovery routine may be implemented, refer
> to the Algorand ABFT [non-normative section](./non-normative/abft-nn.md).

In other words, if a proposal-value \\( v \\) is committable in the current
period,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_h, v)));
$$

while in the second case,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_h, \bar{v})));
$$

and otherwise,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_h, \bot))).
$$
