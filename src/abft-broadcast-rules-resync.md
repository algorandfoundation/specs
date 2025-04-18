Resynchronization Attempt
-------------------------

Where specified, a player attempts to resynchronize.  A
resynchronization attempt involves the following:

 - First, the player broadcasts its _freshest bundle_, if one exists.
   A player's freshest bundle is a complete bundle defined as follows:
    - $\Bundle(r, p, \Soft, v) \subset V$ for some $v$, if it exists,
      or else
    - $\Bundle(r, p-1, s, \bot) \subset V$ for some $s > \Cert$, if it
      exists, or else
    - $\Bundle(r, p-1, s, v) \subset V$ for some
      $s > \Cert, v \neq \bot$, if it exists.

 - Second, if the player broadcasted a bundle $\Bundle(r, p, s, v)$,
   and $v \neq \bot$, then the player broadcasts $\Proposal(v)$ if the
   player has it.

Specifically, a resynchronization attempt corresponds to no additional
outputs if no freshest bundle exists
$$
N(S, L, \ldots) = (S', L', \ldots),
$$
corresponds to a broadcast of a bundle after a relay output and before
any subsequent broadcast outputs, if a freshest bundle exists but no
matching proposal exists
$$
N(S, L, \ldots) = (S', L', (\ldots, \Bundle^*(r, p, \Soft, v), \ldots)),
$$
and otherwise corresponds to a broadcast of both a bundle and a
proposal after a relay output and before any subsequent broadcast
outputs
$$
 N(S, L, \ldots) = (S', L',
    (\ldots, \Bundle^*(r, p, \Soft, v), \Proposal(v), \ldots)).
$$