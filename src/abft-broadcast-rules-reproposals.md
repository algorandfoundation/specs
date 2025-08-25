$$
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Proposal {\mathrm{Proposal}}
$$

# Reproposal Payloads

A proposal rebroadcasting behavior is in place to further mitigate the chance of
players reaching certification on a proposal-value for which its corresponding
proposal has not been observed.

On observing \\( \Vote(I, r, p, 0, v) \\), if \\( \Proposal(v) \in P \\) then the
player broadcasts \\( \Proposal(v) \\).

In other words, if \\( \Proposal(v) \in P \\),

$$
N(S, L, \Vote(I, r, p, 0, v)) = (S', L', (\Proposal(v))).
$$