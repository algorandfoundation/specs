{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \TP {\mathrm{TxPool}}
\newcommand \AD {\mathrm{assemblyDeadline}}
\newcommand \AW {\mathrm{assemblyWait}}
\newcommand \AssembleBlock {\mathrm{AssembleBlock}}
\newcommand \BlockEval {\mathrm{BlockEvaluator}}
\newcommand \EB {\mathrm{emptyBlock}}
\newcommand \r {\mathrm{round}}
\newcommand \nil {\mathit{nil}}
$$

# Block Assembly

The \\( \TP \\) is responsible for populating the `payset` of a block, a process
referred to as `BlockAssembly`.

The `BlockAssembly` is a time-bound algorithm that manages the flow of transactions
into the pending \\( \BlockEval \\) and stops ingestion once timing constraints are reached.

It also handles possible desynchronizations between the \\( \TP.\r \\) (the current
round as perceived by the \\( \TP \\)) and the actual round being assembled by the
pending \\( \BlockEval \\). This discrepancy arises based on how often the `Update`
function has been invoked.

The following pseudocode outlines a high-level view of how `BlockAssembly` operates:

---

\\( \textbf{Algorithm 5} \text{: Block Assembly} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \AssembleBlock(r) \\\\
&\text{2: } \quad \PSif \TP.\r < r - 2 \PSthen \\\\
&\text{3: } \quad \quad \PSreturn \AssembleBlock.\EB(r) \\\\
&\text{4: } \quad \PSendif \\\\
&\text{5: } \quad \PSif r < \TP.\r \PSthen \\\\
&\text{6: } \quad \quad \PSreturn \nil \\\\
&\text{7: } \quad \PSendif \\\\
&\text{8: } \quad \AD \gets \r.\mathrm{startTime}() + \delta_{\AD} \\\\
&\text{9: } \quad \text{Wait until } \AD \lor (\TP.\r = r \land \BlockEval \text{ is done}) \\\\
&\text{10:} \quad \PSif \lnot \BlockEval.\mathrm{done}() \PSthen \\\\
&\text{11:} \quad \quad \PSif \TP.\r > r \PSthen \\\\
&\text{12:} \quad \quad \quad \PSreturn \nil \PScomment{r is behind } \TP.\r \\\\
&\text{13:} \quad \quad \PSendif \\\\
&\text{14:} \quad \quad \AD \gets \AD + \epsilon_{\AW} \\\\
&\text{15:} \quad \quad \text{Wait until } \AD \lor (\TP.\r = r \land \BlockEval \text{ is done}) \\\\
&\text{16:} \quad \quad \PSif \lnot \BlockEval.\mathrm{done}() \PSthen \\\\
&\text{17:} \quad \quad \quad \PSreturn \AssembleBlock.\EB(r) \PScomment{Ran out of time} \\\\
&\text{18:} \quad \quad \PSendif \\\\
&\text{19:} \quad \quad \PSif \TP.\r > r \PSthen \\\\
&\text{20:} \quad \quad \quad \PSreturn \nil \PScomment{Requested round is behind transaction pool round} \\\\
&\text{21:} \quad \quad \PSelseif \TP.\r = r - 1 \PSthen \\\\
&\text{22:} \quad \quad \quad \PSreturn \AssembleBlock.\EB(r) \\\\
&\text{23:} \quad \quad \PSelseif \TP.\r < r \PSthen \\\\
&\text{24:} \quad \quad \quad \PSreturn \nil \\\\
&\text{25:} \quad \quad \PSendif \\\\
&\text{26:} \quad \PSendif \\\\
&\text{27:} \quad \PSreturn \BlockEval.\mathrm{block} \\\\
&\text{28: } \PSendfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Block assembly [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/pools/transactionPool.go#L860).

This algorithm begins by taking a target round \\( r \\), for which a new block
is to be assembled.

It first checks the round currently perceived by the \\( \TP \\), which matches the
round being handled by the pending \\( \BlockEval \\).

- If the \\( \TP.\r \\) is significantly behind \\( r \\): an _empty block_ is immediately
assembled and returned, as there’s no time to catch up.

- If the \\( \TP \\) is already ahead of \\( r \\): no action is needed, as \\( \TP \\)
is simply ahead of the network’s current state.

Next, the algorithm waits for the assembly deadline \\( \delta_{\AD} \\). During
this time, the pending \\( \BlockEval \\) is expected to notify the completed block
assembly in the background via the `Ingestion` function, and that it is caught
up to the round \\( r \\).

If this doesn’t happen by the deadline, the algorithm performs another round of checks:

- If the \\( \TP.\r \\) is now ahead of \\( r \\): the process is aborted, waiting
for the network to catch up. This should rarely happen.

- Othwewise, if the \\( \TP \\) is still behind: an additional wait period \\( \epsilon_{\AW} \\)
is introduced.

After this extra wait, similar checks are repeated:

- If the \\( \TP \\) is still too far behind: there is no more time to wait, and
the algorithm exits.

- Otherwise: the algorithm proceeds.

If all checks pass and timing constraints are met without returning early (an _empty
block_ or a \\( \nil \\) value), the pending \\( \BlockEval \\) finally provides
the fully _assembled block_ for round \\( r \\).