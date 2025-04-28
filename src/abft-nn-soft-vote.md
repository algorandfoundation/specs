$$
\newcommand \SoftVote {\mathrm{SoftVote}}
\newcommand \Prioritym {\mathrm{Priority}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Sortition {\mathrm{Sortition}}
\newcommand \Broadcast {\mathrm{Broadcast}}
\newcommand \RetrieveProposal {\mathrm{RetrieveProposal}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \endif {\textbf{end if}}
\newcommand \for {\textbf{for }}
\newcommand \do {\textbf{ do}}
\newcommand \endfor {\textbf{end for}}
\newcommand \loh {\mathit{lowestObservedHash}}
\newcommand \vt {\mathit{vote}}
\newcommand \ph {\mathit{priorityHash}}
\newcommand \c {\mathit{credentials}}
\newcommand \prop {\mathit{proposal}}
$$

# Soft Vote

Let \\( \Priority \\) be the function that determines which _proposal-value_ to
vote for this round, defined in the [normative section](./abft-player-state.md#special-values)
as:

$$
\Priority(v) = \min_{i \in [0, w_j)} \\{\Hash(\VRF.\ProofToHash(y) \ || \ i)\\}
$$

---

\\( \textbf{Algorithm 4} \text{: Soft Vote} \\)

$$
\begin{aligned}
&\text{1: } \function \SoftVote() \\\\
&\text{2: } \quad \loh \gets \infty \\\\
&\text{3: } \quad v \gets \bot \\\\
&\text{4: } \quad \for \vt' \in V \text{ with } \vt'_s = \prop \do \\\\
&\text{5: } \quad \quad \ph \gets \Priority(\vt')  \\\\
&\text{6: } \quad \quad \if \ph < \loh \then \\\\
&\text{7: } \quad \quad \quad \loh \gets \ph \\\\
&\text{8: } \quad \quad \quad v \gets \vt_v \\\\
&\text{9:} \quad \quad \endif \\\\
&\text{10:} \quad \endfor \\\\
&\text{11:} \quad \if \loh < \infty \then \\\\
&\text{12:} \quad \quad \for a \in A \do \\\\
&\text{13:} \quad \quad \quad \c \gets \Sortition(a_I, r, p, \Soft) \\\\
&\text{14:} \quad \quad \quad \if \c_j > 0 \then \\\\
&\text{15:} \quad \quad \quad \quad \Broadcast(\Vote(a_I, r, p, \Soft, v, \c)) \\\\
&\text{16:} \quad \quad \quad \quad \if \RetrieveProposal(v) \then \\\\
&\text{17:} \quad \quad \quad \quad \quad \\Broadcast(\RetrieveProposal(v)) \\\\
&\text{18:} \quad \quad \quad \quad \endif \\\\
&\text{19:} \quad \quad \quad \endif \\\\
&\text{20:} \quad \quad \endfor \\\\
&\text{21:} \quad \endif \\\\
&\text{22:} \endfunction
\end{aligned}
$$

---