$$
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Bundle {\mathrm{Bundle}}
$$

# Filtering

On observing a timeout event of \\( \FilterTimeout(p) \\) (where
\\( \mu = (H, H', l, p_\mu) = \mu(S, r, p) \\)),

- if \\( \mu \neq \bot \\) and if
   - \\( p_\mu = p \\) or
   - there exists some \\( s > \Cert \\) such that \\( \Bundle(r, p-1, s, \mu) \\)
was observed then the player broadcasts \\( \Vote(I, r, p, \Soft, \mu) \\).

- if there exists some \\( s_0 > \Cert \\) such that \\( \Bundle(r, p-1, s_0, \bar{v}) \\)
was observed and there exists no \\( s_1 > \Cert \\) such that \\( \Bundle(r, p-1, s_1, \bot) \\)
was observed, then the player broadcasts* \\( \Vote(I, r, p, \Soft, \bar{v}) \\).

- otherwise, the player does nothing.

In other words, in the first case above,

$$
N(S, L, t(\FilterTimeout(p), p)) = (S, L, \Vote(I, r, p, \Soft, \mu));
$$

while in the second case above,

$$
N(S, L, t(\FilterTimeout(p), p)) = (S, L, \Vote(I, r, p, \Soft, \bar{v}));
$$

and if neither case is true,

$$
N(S, L, t(\FilterTimeout(p), p)) = (S, L, \epsilon).
$$