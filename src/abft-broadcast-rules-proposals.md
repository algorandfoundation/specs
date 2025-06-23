$$
\newcommand \pk {\mathrm{pk}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Entry {\mathrm{Entry}}
\newcommand \Seed {\mathrm{Seed}}
\newcommand \Sign {\mathrm{Sign}}
\newcommand \Rand {\mathrm{Rand}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Digest {\mathrm{Digest}}
\newcommand \Encoding {\mathrm{Encoding}}
$$

# Proposals

On observing that \\( (r, p) \\) has begun, the player attempts to
resynchronize, and then

- if \\( p = 0 \\) or there exists some \\( s > \Cert \\) where \\( \Bundle(r, p-1, s, \bot) \\)
was observed, then a player generates a new proposal \\( (v', \Proposal(v')) \\) and
then broadcasts \\( (\Vote(I, r, p, 0, v'), \Proposal(v')) \\).

- if \\( p > 0 \\) and there exists some \\( s_0 > \Cert, v \\) where \\( \Bundle(r, p-1, s_0, v) \\)
was observed, while there exists no \\( s_1 > \Cert \\) where \\( \Bundle(r, p-1, s_1, \bot) \\)
was observed, then the player broadcasts \\( \Vote(I, r, p, 0, v) \\). Moreover, if
\\( \Proposal(v) \in P \\), the player then broadcasts \\( \Proposal(v) \\).
   
A player generates a new proposal by executing the entry-generation
procedure and by setting the fields of the proposal
accordingly. Specifically, the player creates a proposal payload
\\( ((o, s), y) \\) by setting

- \\( o := \Entry(L) \\),

- \\( Q := \Seed(L, r-1) \\),

- \\( y := \Sign(Q, Q, 0, 0, 0, 0, 0, 0) \\),

- and \\( s := \Rand(y, \pk)\\) if \\( p = 0 \\) or \\( s := \Hash(\Seed(L, r-1)) \\)
otherwise. 

This consequently defines the matching proposal-value \\( v = (I, p, \Digest(e), \Hash(\Encoding(e))) \\).

> For an in-depth overview of how proposal generation may be implemented, refer
> to the Algorand Ledger [non-normative section](./ledger-overview.md).

In other words, if the player generates a new proposal,

$$
N(S, L, \ldots) = (S', L', (\ldots, \Vote(I, r, p, 0, v'), \Proposal(v'))),
$$

while if the player broadcasts an old proposal,

$$
N(S, L, \ldots) = (S', L', (\ldots, \Vote(I, r, p-1, 0, v), \Proposal(v)))
$$

if \\( \Proposal(v) \in P \\) and

$$
N(S, L, \ldots) = (S', L', (\ldots, \Vote(I, r, p-1, 0, v)))
$$

otherwise.