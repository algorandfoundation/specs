$$
\newcommand \function {\textbf{function }}
\newcommand \return {\textbf{return }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \else {\textbf{else}}
\newcommand \then {\textbf{ then}}
\newcommand \endif {\textbf{end if}}
\newcommand \comment {\qquad \small \textsf}
\newcommand \Node {\mathrm{node}}
\newcommand \FollowerNode {\mathrm{FollowerlNode}}
\newcommand \Stop {\mathrm{Stop}}
\newcommand \Handlers {\mathrm{Handlers}}
\newcommand \Network {\mathrm{Network}}
\newcommand \Config {\mathrm{nodeConfig}}
\newcommand \Catchup {\mathrm{Catchup}}
\newcommand \Catchpoint {\mathrm{Catchpoint}}
\newcommand \Service {\mathrm{Service}}
\newcommand \Block {\mathrm{Block}}
\newcommand \Auth {\mathrm{Authenticator}}
\newcommand \CryptoPool {\mathrm{CryptoPool}}
$$

# Shutdown Follower Node

The following pseudocode describes how a node running in Follower Node mode is gracefully
shutdown.

The shutdown procedure ensures that all services are stopped and resources are properly
deallocated. This prevents data corruption and ensures the node stops in a stable
and predictable state.

---

\\( \textbf{Algorithm 4} \text{: Follower Node Shutdown} \\)

$$
\begin{aligned}
&\text{1: } \function \FollowerNode.\Stop() \\\\
&\text{2: } \comment{# Network Cleanup} \\\\
&\text{3: } \quad \Node.\Network.\Stop\Handlers() \\\\
&\text{4: } \quad \if \neg \Node.\Config.\Stop\Network \then \\\\
&\text{5: } \quad \quad \Node.\Network.\Stop() \\\\
&\text{6: } \quad \endif \\\\
&\text{7: } \comment{# Service Shutdown} \\\\
&\text{8: } \quad \if \exists \Node.\Catchpoint\Catchup\Service \then \\\\
&\text{9: } \quad \quad \Node.\Catchpoint\Catchup\Service.\Stop() \\\\
&\text{10:} \quad \else \\\\
&\text{11:} \comment{# Follower Services Only} \\\\
&\text{12:} \quad \quad \Node.\Catchup\Service.\Stop() \\\\
&\text{13:} \quad \quad \Node.\Block\Service.\Stop() \\\\
&\text{14:} \quad \endif \\\\
&\text{15:} \comment{# Resource Cleanup} \\\\
&\text{16:} \quad \Node.\Catchup.\Block\Auth.\Stop() \\\\
&\text{17:} \quad \Node.\CryptoPool.\mathrm{lowPriority}.\Stop() \\\\
&\text{18:} \quad \Node.\CryptoPool.\Stop() \\\\
&\text{19:} \endfunction
\end{aligned}
$$

---

{{#include ../.include/styles.md:impl}}
> Follower node shutdown [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/node/follower_node.go#L211-L229).