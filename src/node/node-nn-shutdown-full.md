{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \Node {\mathrm{node}}
\newcommand \FullNode {\mathrm{FullNode}}
\newcommand \Network {\mathrm{Network}}
\newcommand \Stop {\mathrm{Stop}}
\newcommand \Close {\mathrm{Close}}
\newcommand \Config {\mathrm{nodeConfig}}
\newcommand \Catchup {\mathrm{Catchup}}
\newcommand \Service {\mathrm{Service}}
\newcommand \Ledger {\mathrm{Ledger}}
\newcommand \AccountManager {\mathrm{AccountManager}}
\newcommand \Registry {\mathrm{Registry}}
\newcommand \TP {\mathrm{TxPool}}
\newcommand \Handler {\mathrm{Handler}}
\newcommand \Handlers {\mathrm{Handlers}}
\newcommand \Catchpoint {\mathrm{Catchpoint}}
$$

# Shutdown Full Node

The pseudocode below outlines how a Full Node is gracefully shut down.

This process ensures all services are stopped, garbage collection is performed,
resources are released, and the internal state is properly cleaned up.

By following this structured approach, the node avoids corrupting data or leaving
the Algorand network in an inconsistent state, which is critical for maintaining
the integrity of the system.

---

\\( \textbf{Algorithm 3} \text{: Full Node Shutdown} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \FullNode.\Stop() \\\\
&\text{2: } \PScomment{# Network Cleanup} \\\\
&\text{3: } \quad \Node.\Network.\Stop\Handlers() \\\\
&\text{4: } \quad \Node.\Network.\Stop\mathrm{Validator}\Handlers() \\\\
&\text{5: } \quad \PSif \neg \Node.\Config.\Stop\Network \PSthen \\\\
&\text{6: } \quad \quad \Node.\Network.\Stop() \\\\
&\text{7: } \quad \PSendif \\\\
&\text{8: } \PScomment{# Service Shutdown} \\\\
&\text{9: } \quad \PSif \exists \Node.\Catchpoint\Catchup\Service \PSthen \\\\
&\text{10:} \quad \quad \Node.\Catchpoint\Catchup\Service.\Stop() \\\\
&\text{11:} \quad \PSelse \\\\
&\text{12:} \PScomment{# Full Node Services} \\\\
&\text{13:} \quad \quad \Node.\Stop\mathrm{AllServices}() \\\\
&\text{14:} \quad \PSendif \\\\
&\text{15:} \PScomment{# Resource Cleanup} \\\\
&\text{16:} \quad \Node.\TP.\Stop() \\\\
&\text{17:} \PScomment{# Final Cleanup} \\\\
&\text{18:} \quad \Node.\Ledger.\Close() \\\\
&\text{19:} \PScomment{# Post-Shutdown Cleanup} \\\\
&\text{20:} \quad \mathrm{WaitMonitoringRoutines}() \\\\
&\text{21:} \quad \Node.\AccountManager.\Registry.\Close() \\\\
&\text{22:} \quad \PSfor \Handler \in \Node.\mathrm{Database}\Handlers \PSdo \\\\
&\text{23:} \quad \quad \Handler.\Close() \\\\
&\text{24:} \quad \PSendfor \\\\
&\text{25:} \PSendfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Full node shutdown [reference implementation](https://github.com/algorand/go-algorand/blob/e60d3ddd1d63e60f32bda6935554b34fdb0e1515/node/node.go#L444-L487).

This structured shutdown process helps ensure that Full Nodes exit cleanly, preserving
correctness, avoiding data leaks, and minimizing node and network risk.