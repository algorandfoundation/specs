$$
\newcommand \Cert {\mathit{cert}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Proposal {\mathrm{Proposal}}
$$

# Certifying

On observing that some proposal-value \\( v \\) is committable for its
current round \\( r \\), and some period \\( p' \geq p \\) (its current period),
if \\( s \leq \Cert \\), then the player broadcasts*
\\( \Vote(I, r, p, \Cert, v) \\). (It can be shown that this occurs either
after a proposal is received or a soft-vote, which can be part of a
bundle, is received.)

> For a detailed overview of how the certification step may be implemented, refer
> to the Algorand ABFT [non-normative section](./abft-overview.md).

In other words, if observing a soft-vote causes a proposal-value to
become committable,

$$
N(S, L, \Vote(I, r, p, \Soft, v)) = (S', L, (\ldots, \Vote(I, r, p, \Cert, v)));
$$

while if observing a bundle causes a proposal-value to become
committable,

$$
N(S, L, \Bundle(r, p, \Soft, v)) = (S', L, (\ldots, \Vote(I, r, p, \Cert, v)));
$$

and if observing a proposal causes a proposal-value to become
committable,

$$
N(S, L, \Proposal(v)) = (S', L, (\ldots, \Vote(I, r, p, \Cert, v)));
$$

as long as \\( s \leq \Cert \\).