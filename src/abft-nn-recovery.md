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
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \elseif {\textbf{else if }}
\newcommand \then {\textbf{ then}}
\newcommand \else {\textbf{else}}
\newcommand \endif {\textbf{end if}}
\newcommand \for {\textbf{for }}
\newcommand \do {\textbf{ do}}
\newcommand \endfor {\textbf{end for}}
\newcommand \c {\mathit{credentials}}
\newcommand \prop {\mathit{proposal}}
$$

# Recovery

The recovery algorithm is executed periodically, whenever a \\( \Bundle_\Cert \\)
has not been observed before \\( \DeadlineTimeout(p) \\) for a given period \\( p \\).

## Algorithm

---

\\( \textbf{Algorithm 9} \text{: Recovery} \\)

$$
\begin{aligned}
&\text{1: } \function \Recovery() \\\\
&\text{2: } \quad \ResynchronizationAttempt() \\\\
&\text{3: } \quad \for a \in A \do \\\\
&\text{4: } \quad \quad \c \gets \Sortition(a_I, r, p, s) \\\\
&\text{5: } \quad \quad \if \c_j > 0 \then \\\\
&\text{6: } \quad \quad \quad \if \exists v = \Proposal_v(\prop, \prop_p, \prop_I) \\\\
&\text{   } \quad \quad \quad \quad \quad \text{for some } \prop \in P \mid \IsCommittable(v) \then \\\\
&\text{7: } \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, s, v, \c)) \\\\
&\text{8: } \quad \quad \quad \elseif \exists s_0 > \Cert \mid \Bundle(r, p - 1, s_0, \bot) \subseteq V \land \\\\
&\text{   } \quad \quad \quad \quad \quad \quad \quad \exists s_1 > \Cert \mid \Bundle(r, p - 1, s_1, \bar{v}) \subseteq V \then \\\\
&\text{9: } \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, s, \bar{v}, \c)) \\\\
&\text{10:} \quad \quad \quad \else \\\\
&\text{11:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, s, \bot, \c)) \\\\
&\text{12:} \quad \quad \quad \endif \\\\
&\text{13:} \quad \quad \endif \\\\
&\text{14:} \quad \endfor \\\\
&\text{15:} \quad s:=s+1 \\\\
&\text{16: } \endfunction
\end{aligned}
$$

---

{{#include ./.include/styles.md:impl}}
> Next vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/d52e3dd8b31a17dfebac3d9158a76e8e62617462/agreement/player.go#L214).

The node starts by making a resynchronization attempt (Line 2).

Afterward, the node plays for each _online_ account (registered on the node). For
each account selected to be a part of the voting committee for the _current step_
\\( \Next_k \\), one of the following three different outputs is produced.

- If a _proposal-value_ \\( v \\) can be committed in the current context, then the
player broadcasts a \\( \Next_k \\) vote for \\( v \\).

- If no _proposal-value_ can be committed, and
  - No recovery step \\( \Bundle \\) for the _empty proposal-value_ (\\( \bot \\)) was observed in the _previous period_, and
  - A recovery step \\( \Bundle \\) for the _pinned value_ was observed in the _previous period_[^1],

  then a \\( \Next_k \\) vote for \\( \bar{v} \\) is broadcast by the player.

- Finally, if none of the above conditions were met, a \\( \Next_k \\) vote for
\\( \bot \\) is broadcast.

A player is forbidden from equivocating in \\( \Next_k \\) votes.
Lastly, the node's current step $s$ is updated.
> For a formal definition of this functionality, refer to the ABFT [normative section](./abft.md#recovery).

---

[^1]: This implies \\( \bar{v} \neq \bot \\).