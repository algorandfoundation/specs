$$
\newcommand \Bundle {\mathrm{Bundle}}
$$

# Bundles

On receiving a bundle \\( \Bundle(r_k, p_k, s_k, v) \\) a player

- Ignores* it if \\( Bundle(r_k, p_k, s_k, v) \\) is malformed or trivially invalid.

- Ignores it if
  - \\( r_k \neq r \\) or
  - \\( r_k = r \\) and \\( p_k + 1 < p \\).

- Otherwise, observes the votes in \\( \Bundle(r_k, p_k, s_k, v) \\) in sequence. If
there exists a vote that causes the player to observe some bundle \\( \Bundle(r_k, p_k, s_k, v') \\)
for some \\( s_k \\), then the player relays \\( \Bundle(r_k, p_k, s_k, v') \\), and
then executes any consequent action; if there does not, the player ignores it.

Specifically, if the player ignores the bundle without observing its
votes, then

$$
N(S, L, \Bundle(r_k, p_k, s_k, v)) = (S, L, \epsilon);
$$

while if a player ignores the bundle but observes its votes, then

$$
N(S, L, \Bundle(r_k, p_k, s_k, v))
= (S' \cup \Bundle(r_k, p_k, s_k, v), L, \epsilon);
$$

and if a player, on observing the votes in the bundle, observes a
bundle for some value (not necessarily distinct from the bundle's
value), then

$$
N(S, L, \Bundle(r_k, p_k, s_k, v))
= (S' \cup \Bundle(r_k, p_k, s_k, v), L', (\Bundle^\ast(r_, p_k, s_k, v'), \ldots)).
$$