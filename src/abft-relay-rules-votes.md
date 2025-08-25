$$
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Late {\mathit{late}}
\newcommand \Down {\mathit{down}}
\newcommand \Next {\mathit{next}}
$$

# Votes

On receiving a vote \\( \Vote_k(r_k, p_k, s_k, v) \\) a player

- Ignores* it if \\( \Vote_k \\) is malformed or trivially invalid.

- Ignores it if \\( s = 0 \\) and \\( \Vote_k \in V \\).

- Ignores it if \\( s = 0 \\) and \\( \Vote_k \\) is an equivocation.

- Ignores it if \\( s > 0 \\) and \\( \Vote_k \\) is a second equivocation.

- Ignores it if

  - \\( r_k \notin [r,r+1] \\) or
  - \\( r_k = r + 1 \\) and either
    - \\( p_k > 0 \\) or
    - \\( s_k \in (\Next_0, \Late) \\) or

  - \\( r_k = r \\) and one of
    - \\( p_k \notin [p-1,p+1] \\) or
    - \\( p_k = p + 1 \\) and \\( s_k \in (\Next_0, \Late) \\) or
    - \\( p_k = p \\) and \\( s_k \in (\Next_0, \Late) \\) and \\( s_k \notin [s-1,s+1] \\) or
    - \\( p_k = p - 1 \\) and \\( s_k \in (\Next_0, \Late) \\) and \\( s_k \notin [\bar{s}-1,\bar{s}+1] \\).

- Otherwise, relays \\( \Vote_k \\), observes it, and then produces any consequent
output.

Specifically, if a player ignores the vote, then

$$
N(S, L, \Vote_k(r_k, p_k, s_k, v)) = (S, L, \epsilon)
$$

while if a player relays the vote, then

$$
N(S, L, \Vote_k(r_k, p_k, s_k, v))
= (S' \cup \Vote(I, r_k, p_k, s_k, v), L', (\Vote_k^\ast(r_k, p_k, s_k, v),\ldots)).
$$