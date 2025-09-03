{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \TP {\mathrm{TxPool}}
\newcommand \TG {\mathrm{TxnGroup}}
\newcommand \NB {\mathrm{newBlock}}
\newcommand \BlockEval {\mathrm{BlockEvaluator}}
\newcommand \Ledger {\mathrm{Ledger}}
\newcommand \CheckSufficientFee {\mathrm{CheckSufficientFee}}
\newcommand \now {\mathrm{now}}
\newcommand \Ingest {\mathrm{Ingest}}
$$

# Ingestion

This function determines which transaction groups should be passed to the pending
[Block Evaluator](ledger-nn-block-commitment.md) for possible inclusion in the
next block, and which ones should be deferred for evaluation in a future round.

When deferring transactions, the node checks that their remaining validity period
is sufficient for future inclusion; otherwise, they are marked for removal if they
exceed their validity period.

The \\( \TP \\) also verifies that each transaction group meets the minimum required
fee to qualify for execution.

A \\( \BlockEval \\) is the construct used to ingest \\( \TG \\).

The following pseudocode snippet illustrates how this ingestion process could be
implemented:

---

\\( \textbf{Algorithm 4} \text{: Transaction Ingestion} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \Ingest(\TG\ gtx) \\\\
&\text{2: } \quad \dots \\\\
&\text{3: } \quad \PSif \lnot \BlockEval \PSthen \\\\
&\text{4: } \quad \quad \PSreturn \PScomment{No pending Block Evaluator exists} \\\\
&\text{5: } \quad \PSendif \\\\
&\text{6: } \quad \PSif \lnot \texttt{recompute} \PSthen \\\\
&\text{7: } \quad \quad r \gets \Ledger.\mathrm{getLatestRound}() \\\\
&\text{8: } \quad \quad t^\ast \gets \now() + \delta_{\NB} \\\\
&\text{9: } \quad \quad \PSwhile \BlockEval.\mathrm{round}() \leq r \land \now() < t^\ast \PSdo \\\\
&\text{10:} \quad \quad \quad \textsf{Give time to the } \BlockEval \textsf{ to catch up} \\\\
&\text{11:} \quad \quad \PSendwhile \\\\
&\text{12:} \quad \quad \PSif \lnot \CheckSufficientFee(gtx) \PSthen \\\\
&\text{13:} \quad \quad \quad \PSreturn gtx \PScomment{Discarded for insufficient fees} \\\\
&\text{14:} \quad \quad \PSendif \\\\
&\text{15:} \quad \PSendif \\\\
&\text{16:} \quad \TP \gets \BlockEval.\mathrm{add}(gtx) \\\\
&\text{17:} \quad \dots \\\\
&\text{18: } \PSendfunction
\end{aligned}
$$

---

> Transaction ingestion [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/pools/transactionPool.go#L440).

This algorithm requires a pending \\( \BlockEval \\) to be already initialized and
ready to process transaction groups.

It uses a \\( \texttt{recompute} \\) flag to verify whether the `Update` function
has handled the latest block. If not, the algorithm enters a wait phase, controlled
by the \\( \delta_{NB} \\) parameter (as described in the [parameters section](ledger-nn-txpool-parameters.md)).

This waiting period can end early if the pending \\( \BlockEval \\) catches up to
the current round. Once synchronized, the algorithm performs a preliminary check
to ensure that the candidate transaction group \\( gtx \\) is adequately funded,
per the [fee prioritization rules](ledger-nn-txpool-prioritization.md).

Finally, an attempt is made to add \\( gtx \\) to the pending \\( \BlockEval \\).
After evaluating \\( gtx \\) and performing all necessary checks, this step effectively
enqueues the transaction group into the \\( \TP \\).