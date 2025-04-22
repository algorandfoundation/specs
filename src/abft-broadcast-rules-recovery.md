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

- \\( T = \DeadlineTimeout(p) + 2^{s_t}\lambda + r \\) where \\( r \in [0, 2^{s_t}\lambda] \\)
sampled uniformly at random, 

the player attempts to resynchronize and then broadcasts*
\\( \Vote(I, r, p, \Next_s, v) \\) where

- \\( v = \sigma(S, r, p) \\) if \\( v \\) is committable in \\( (r, p) \\),

- \\( v = \bar{v} \\) if there does not exist a \\( s_0 > \Cert \\) such that
\\( \Bundle(r, p-1, s_0, \bot) \\) was observed and there exists an \\( s_1 > \Cert \\)
such that \\( \Bundle(r, p-1, s_1, \bar{v} )\\) was observed,

- and \\( v = \bot \\) otherwise.

In other words, if a proposal-value \\( v \\) is committable in the current
period,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_s, v)));
$$

while in the second case,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_s, \bar{v})));
$$

and otherwise,

$$
N(S, L, t(T, p)) = (S', L, (\ldots, \Vote(I, r, p, \Next_s, \bot))).
$$