{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
\newcommand \Recovery {\mathrm{Recovery}}
\newcommand \ResynchronizationAttempt {\mathrm{ResynchronizationAttempt}}
\newcommand \Sortition {\mathrm{Sortition}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \IsCommittable {\mathrm{IsCommittable}}
\newcommand \Broadcast {\mathrm{Broadcast}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
\newcommand \c {\mathit{credentials}}
\newcommand \prop {\mathit{proposal}}
\newcommand \s {\mathit{step}}
$$

# Recovery

The recovery algorithm is executed periodically, whenever a \\( \Bundle_\Cert \\)
has not been observed before \\( \DeadlineTimeout(p) \\) for a given period \\( p \\).

## Algorithm

---

\\( \textbf{Algorithm 9} \text{: Recovery} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \Recovery() \\\\
&\text{2: } \quad \ResynchronizationAttempt() \\\\
&\text{3: } \quad \PSfor a \in A \PSdo \\\\
&\text{4: } \quad \quad \c \gets \Sortition(a_I, r, p, s) \\\\
&\text{5: } \quad \quad \PSif \c_j > 0 \PSthen \\\\
&\text{6: } \quad \quad \quad \PSif \exists v = \Proposal_v(\prop, \prop_p, \prop_I) \\\\
&\text{   } \quad \quad \quad \quad \quad \text{for some } \prop \in P \mid \IsCommittable(v) \PSthen \\\\
&\text{7: } \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, s, v, \c)) \\\\
&\text{8: } \quad \quad \quad \PSelseif \exists s_0 > \Cert \mid \Bundle(r, p - 1, s_0, \bot) \subseteq V \land \\\\
&\text{   } \quad \quad \quad \quad \quad \quad \quad \exists s_1 > \Cert \mid \Bundle(r, p - 1, s_1, \bar{v}) \subseteq V \PSthen \\\\
&\text{9: } \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, s, \bar{v}, \c)) \\\\
&\text{10:} \quad \quad \quad \PSelse \\\\
&\text{11:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, s, \bot, \c)) \\\\
&\text{12:} \quad \quad \quad \PSendif \\\\
&\text{13:} \quad \quad \PSendif \\\\
&\text{14:} \quad \PSendfor \\\\
&\text{15:} \quad \s \gets \s + 1 \\\\
&\text{16: } \PSendfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Next vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/d52e3dd8b31a17dfebac3d9158a76e8e62617462/agreement/player.go#L214).

The node starts by making a resynchronization attempt (Line 2).

Afterward (Lines 3:5), the node plays independently for each _online_ account (registered
on the node). This means that for _every account_ available in \\( A \\), the
\\( \Sortition \\) algorithm is run, and accounts selected in the recovery committee
(i.e., the players) for the _current step_ \\( \Next_k \\) (that is, those whose
\\( \c_j > 0 \\)) will produce one of the following three distinct outputs (Lines 6:14):

- If a _proposal-value_ \\( v \\) can be committed in the current context, then the
player broadcasts a \\( \Next_k \\) vote for \\( v \\).

- If no _proposal-value_ can be committed, and
  - No recovery step \\( \Bundle \\) for the _empty proposal-value_ (\\( \bot \\))
  was observed in the _previous period_, and
  - A recovery step \\( \Bundle \\) for the _pinned value_ was observed in the
  _previous period_[^1],

  then a \\( \Next_k \\) vote for \\( \bar{v} \\) is broadcast by the player.

- Finally, if none of the above conditions were met, a \\( \Next_k \\) vote for
\\( \bot \\) is broadcast.

A player is forbidden from equivocating in \\( \Next_k \\) votes.

Lastly (Line 15), the node’s current \\( \s \\) is updated.

> For a formal definition of this functionality, refer to the ABFT [normative section](./abft.md#recovery).

---

[^1]: This implies \\( \bar{v} \neq \bot \\).