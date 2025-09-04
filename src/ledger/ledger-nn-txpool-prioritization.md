{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \TP {\mathrm{TxPool}}
\newcommand \FeePB {\mathrm{feePerByte}}
\newcommand \FeeMul {\mathrm{feeThresholdMultiplier}}
\newcommand \FeeExp {\mathrm{expFeeFactor}}
\newcommand \PendingFB {\mathrm{pendingFullBlocks}}
\newcommand \ComputeFeePerByte {\mathrm{ComputeFeePerByte}}
$$

# Prioritization

When the \\( \TP \\) becomes congested, a _fee prioritization_ algorithm determines
which transactions are enqueued into the pool and which are rejected.

The key parameter in this process is \\( \FeePB \\), which is calculated dynamically
based on the number of pending blocks awaiting evaluation.

The \\( \PendingFB \\) is an unsigned integer that represents the number of uncommitted
full blocks present in the \\( \TP_{pq} \\).

The function `computeFeePerByte` below demonstrates how this value is computed:

---

\\( \textbf{Algorithm 2} \text{: Compute Fee per Byte} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \ComputeFeePerByte() \\\\
&\text{2: } \quad \FeePB \gets \FeeMul \\\\
&\text{3: } \quad \PSif \FeePB = 0 \land \TP.\PendingFB > 1 \PSthen \\\\
&\text{4: } \quad \quad \FeePB \gets 1 \\\\
&\text{5: } \quad \PSendif \\\\
&\text{6: } \quad \PSfor i {\textbf{ from }} 0 \textbf{ to } \TP.\PendingFB \PSdo \\\\
&\text{7: } \quad \quad \FeePB \gets \FeePB \cdot \TP.\FeeExp \\\\
&\text{8: } \quad \PSendfor \\\\
&\text{9: } \quad \PSreturn \FeePB \\\\
&\text{10: } \PSendfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Compute fee per byte [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/pools/transactionPool.go#L328).

The `computeFeePerByte` function begins by setting \\( \FeePB \\) equal to the \\( \FeeMul \\).
When there is no congestion in \\( \TP \\), this value is \\( 0 \\).

However, if there are any full blocks currently pending in \\( \TP_{pq} \\), \\( \FeePB \\)
is initially set to \\( 1 \\). This setup ensures that the subsequent multiplication
step accumulates due to a non-zero base.

Next, for each of these full pending blocks, the \\( \FeeExp \\) is multiplied by
the current \\( \FeePB \\) value—causing \\( \FeePB \\) to grow exponentially with
the level of congestion.

The resulting \\( \FeePB \\) is then:

$$
\FeePB = \max\\{1, \FeeMul \\} \times \FeeExp^{\TP.\PendingFB}
$$
