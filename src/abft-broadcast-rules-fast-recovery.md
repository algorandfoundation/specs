Fast Recovery
-------------

On observing a timeout event of $T = k\lambda_f + r$ where $k$ is a positive
integer and $r \in [0, \lambda_f]$ sampled uniformly at random, the player
attempts to resynchronize.  Then,

 - The player broadcasts* $\Vote(I, r, p, \Late, v)$ if $v = \sigma(S, r, p)$ is
   committable in $(r, p)$.
 - The player broadcasts* $\Vote(I, r, p, \Redo, \vbar)$ if there does not exist
   a $s_0 > \Cert$ such that $\Bundle(r, p-1, s_0, \bot)$ was observed and there
   exists an $s_1 > \Cert$ such that $\Bundle(r, p-1, s_1, \vbar)$ was
   observed.
 - Otherwise, the player broadcasts* $\Vote(I, r, p, \Down, \bot)$.

Finally, the player broadcasts all $\Vote(I, r, p, \Late, v) \in V$, all
$\Vote(I, r, p, \Redo, v) \in V$, and all $\Vote(I, r, p, \Down, \bot) \in V$
that it has observed.