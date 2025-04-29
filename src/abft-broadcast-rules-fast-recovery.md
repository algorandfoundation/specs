$$
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
$$

# Fast Recovery

On observing a timeout event of \\( T = k\lambda_f + r \\) where \\( k \\) is a positive
integer and \\( r \in [0, \lambda_f] \\) sampled uniformly at random, the player
attempts to resynchronize. Then,

- The player broadcasts* \\( \Vote(I, r, p, \Late, v) \\) if \\( v = \sigma(S, r, p) \\)
is committable in \\( (r, p) \\).

- The player broadcasts* \\( \Vote(I, r, p, \Redo, \bar{v}) \\) if there does not exist
a \\( s_0 > \Cert \\) such that \\( \Bundle(r, p-1, s_0, \bot) \\) was observed and there
exists an \\( s_1 > \Cert \\) such that \\( \Bundle(r, p-1, s_1, \bar{v}) \\) was observed.

- Otherwise, the player broadcasts* \\( \Vote(I, r, p, \Down, \bot \\).

Finally, the player broadcasts all \\( \Vote(I, r, p, \Late, v) \in V\\), all
\\( \Vote(I, r, p, \Redo, v) \in V\\), and all \\( \Vote(I, r, p, \Down, \bot) \in V \\)
that it has observed.

{{#include ./.include/styles.md:impl}}
> Fast recovery [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/player.go#L150).

> For a detailed pseudocode overview of the fast recovery routine, along with protocol
> recovery run examples, refer to the Algorand ABFT [non-normative section](./abft-overview.md).