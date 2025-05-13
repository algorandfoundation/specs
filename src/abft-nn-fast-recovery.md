$$
\newcommand \Recovery {\mathrm{Recovery}}
\newcommand \FastRecovery {\mathrm{FastRecovery}}
\newcommand \Resync {\mathrm{Resync}}
\newcommand \Sortition {\mathrm{Sortition}}
\newcommand \Broadcast {\mathrm{Broadcast}}
\newcommand \IsCommittable {\mathrm{IsCommittable}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
\newcommand \Cert {\mathit{cert}}
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
\newcommand \vt {\mathit{vote}}
\newcommand \c {\mathit{credentials}}
$$

# Fast Recovery

The fast recovery algorithm is executed periodically every integer multiple of \\( \lambda_f \\)
seconds (plus random variance). This gives it an approximately linear rate of execution while the partition state affecting the network continues.

The algorithm makes use of the last three steps, named late, redo and down respectively for steps 253, 254 and 255.
These steps are by nature mutually exclusive:
- A late vote will be attempted if a staged value \\( \sigma \\) is available (for the current round and period).
- Otherwise, a redo vote will be attempted if the current period is greater than zero, and the last period was completed with a next threshold for a non-bottom proposal-value.
- Finally, as a fallback of sorts, a down vote is attempted if none of the above conditions were met.

Note that a down vote is always a vote for the bottom proposal-value, while late and redo must vote for a proposal-value _distinct_ from //( \bot )//.

## Algorithm

---

\\( \textbf{Algorithm 10} \text{: Fast Recovery} \\)

$$
\begin{aligned}
&\text{1: } \function \FastRecovery() \\\\
&\text{2: } \quad \Resync() \\\\
&\text{3: } \quad \for a \in A \do \\\\
&\text{4: } \quad \quad \if \IsCommittable(\bar{v}) \then \\\\
&\text{5: } \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Late) \\\\
&\text{6: } \quad \quad \quad \if \c_j > 0 \then \\\\
&\text{7: } \quad \quad \quad \quad \Broadcast(\Vote(r, p, \Late, \bar{v}, \c)) \\\\
&\text{8: } \quad \quad \quad \endif \\\\
&\text{9: } \quad \quad \elseif \nexists s_0 > \Cert \mid \Bundle(r, p - 1, s_0, \bot) \subseteq V \land \\\\
&\text{   } \quad \quad \quad \quad \quad \quad \exists s_1 > \Cert \mid \Bundle(r, p - 1, s_1, \bar{v}) \subseteq V \then \\\\
&\text{10:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Redo) \\\\
&\text{11:} \quad \quad \quad \if \c_j > 0 \then \\\\
&\text{12:} \quad \quad \quad \quad \Broadcast(\Vote(r, p, \Redo, \bar{v}, \c)) \\\\
&\text{13:} \quad \quad \quad \endif \\\\
&\text{14:} \quad \quad \else \\\\
&\text{15:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Down) \\\\
&\text{16:} \quad \quad \quad \if \c_j > 0 \then \\\\
&\text{17:} \quad \quad \quad \quad \Broadcast(\Vote(r, p, \Down, \bot, \c)) \\\\
&\text{18:} \quad \quad \quad \endif \\\\
&\text{19:} \quad \quad \endif \\\\
&\text{20:} \quad \endfor \\\\
&\text{21:} \quad \for \vt \in V \text{ such that } \vt_s \geq 253 \do \\\\
&\text{22:} \quad \quad \Broadcast(\vt) \\\\
&\text{23:} \quad \endfor \\\\
&\text{24: } \endfunction
\end{aligned}
$$

---

{{#include ./.include/styles.md:impl}}
> Fast recovery vote issuance [reference implementation](https://github.com/algorand/go-algorand/blob/d52e3dd8b31a17dfebac3d9158a76e8e62617462/agreement/player.go#L244).

\\( \FastRecovery \\) is functionally very close to the regular \\( \Recovery \\)
algorithm (outlined in the previous section), performing the same checks and similar outputs.

The main difference is that it emits votes for any of the three different steps
\\( \Late, \Redo, \Down \\), according to \\( \Sortition \\) results for every
selected account.

Nodes are forbidden to equivocate for \\( \Late, \Redo, \Down \\) votes.

Finally, the node broadcasts all fast recovery votes observed. That is, all votes
\\( \vt \in V \\) for which \\( \vt_s \\) is a fast recovery step (\\( \Late, \Redo, \Down \\)).

> For a formal definition of this functionality, refer to the ABFT [normative section](./abft.md#fast-recovery).