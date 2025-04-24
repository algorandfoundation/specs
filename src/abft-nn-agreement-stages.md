$$
\newcommand \BlockProposal {\mathrm{BlockProposal}}
\newcommand \SoftVote {\mathrm{SoftVote}}
\newcommand \CertificationVote {\mathrm{CertificationVote}}
\newcommand \Commitment {\mathrm{Commitment}}
\newcommand \Recovery {\mathrm{Recovery}}
\newcommand \FastRecovery {\mathrm{FastRecovery}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
\newcommand \HandleProposal {\mathrm{HandleProposal}}
\newcommand \HandleVote {\mathrm{HandleVote}}
\newcommand \HandleBundle {\mathrm{HandleBundle}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \else {\textbf{else}}
\newcommand \elseif {\textbf{else if }}
\newcommand \endif {\textbf{end if}}
\newcommand \ev {\mathit{ev}}
\newcommand \t {\mathit{time}}
\newcommand \s {\mathit{step}}
\newcommand \data {\mathit{msg}_\text\{data}}
\newcommand \TimeoutEvent {\texttt{TimeoutEvent}}
\newcommand \DynamicFilterTimeout {\mathrm{DynamicFilterTimeout}}
$$

# Agreement Stages

The Algorand Agreement Protocol can be split into a series of stages.

In the normative section, these stages are univocally associated with infinite subsets
of protocol states. These subsets are disjoint and together represent the whole
space of possible states for the node state machine to be in.

The stages are, in chronological order within a given round:

- \\( \BlockProposal \\),
- \\( \SoftVote \\),
- \\( \CertificationVote \\), which includes a final \\( \Commitment \\).

If \\( \Commitment \\) is not possible because of external reasons (i.e., a network
partition), two fallback stages:

- \\( \FastRecovery \\),
- \\( \Recovery \\).

By abstracting away some implementation-specific complexity, we propose a model for
the Agreement Protocol state machine that captures how and when transitions between
different states happen.

We may model the state machine’s main algorithm in the following way:

---

\\( \textbf{Algorithm 2} \text{: Main State Machine} \\)

$$
\begin{aligned}
&\text{1: } \function \mathrm{EventHandler}(ev) \\\\
&\text{2. } \qquad \if \ev \text{ is } \TimeoutEvent \then \\\\
&\text{3. } \qquad \quad \t \gets \ev_\t \\\\
&\text{4. } \qquad \quad \if \t = 0 \then \\\\
&\text{5. } \qquad \quad \quad \BlockProposal() \quad \text{// Last round should have left us with s = 0} \\\\
&\text{6. } \qquad \quad \quad \if \text{finished a block} \lor \mathrm{CurrentTime}() = \mathrm{AssemblyDeadline}() \then \\\\
&\text{7. } \qquad \quad \quad \quad \s \gets \mathrm{soft} \\\\
&\text{8. } \qquad \quad \quad \endif \\\\
&\text{9. } \qquad \quad \elseif time = \DynamicFilterTimeout(p) \then \\\\
&\text{10.} \qquad \quad \quad \SoftVote() \\\\
&\text{11.} \qquad \quad \quad \s \gets \mathrm{cert} \\\\
&\text{12.} \qquad \quad \elseif \t = \DeadlineTimeout(p) \then \\\\
&\text{13.} \qquad \quad \quad \s \gets \mathrm{next\_0} \\\\
&\text{14.} \qquad \quad \quad \Recovery() \\\\
&\text{15.} \qquad \quad \elseif \t = \DeadlineTimeout(p) + 2^{s_t - 3}\lambda \text{ for } 4 \le s_t \le 252 \then \\\\
&\text{16.} \qquad \quad \quad \s \gets s_t \\\\
&\text{17.} \qquad \quad \quad \Recovery() \\\\
&\text{18.} \qquad \quad \elseif \t = k\lambda_f + rnd \text{ for } k, rnd \in \mathbb{Z}, k > 0, 0 \le rnd \le \lambda_f \then \\\\
&\text{19.} \qquad \quad \quad \FastRecovery() \\\\
&\text{20.} \qquad \quad \endif \\\\
&\text{21.} \qquad \else \quad \text{// These MessageEvents could trigger a commitment and round advancement} \\\\
&\text{22.} \qquad \quad msg \gets ev_{msg} \\\\
&\text{23.} \qquad \quad \if \data \text{ is of type } \texttt{Proposal } pp \then \\\\
&\text{24.} \qquad \quad \quad \HandleProposal(pp) \\\\
&\text{25.} \qquad \quad \elseif \data \text{ is of type } \texttt{Vote } v \then \\\\
&\text{26.} \qquad \quad \quad \HandleVote(v) \\\\
&\text{27.} \qquad \quad \elseif \data \text{ is of type } \texttt{Bundle } b \then \\\\
&\text{28.} \qquad \quad \quad \HandleBundle(b) \\\\
&\text{29.} \qquad \quad \endif \\\\
&\text{30.} \qquad \endif \\\\
&\text{31: } \endfunction
\end{aligned}
$$

---