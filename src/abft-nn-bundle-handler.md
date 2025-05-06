$$
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \HandleBundle {\mathrm{HandleBundle}}
\newcommand \VerifyBundle {\mathrm{VerifyBundle}}
\newcommand \HandleVote {\mathrm{HandleVote}}
\newcommand \SenderPeer {\mathrm{SenderPeer}}
\newcommand \DisconnectFromPeer {\mathrm{DisconnectFromPeer}}
\newcommand \function {\textbf{function }}
\newcommand \return {\textbf{return }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \endif {\textbf{end if}}
\newcommand \for {\textbf{for }}
\newcommand \do {\textbf{ do}}
\newcommand \endfor {\textbf{end for}}
\newcommand \not {\textbf{not }}
\newcommand \vt {\mathit{vote}}
\newcommand \b {\mathit{bundle}}
$$

# Bundle Handler

The node runs a bundle handler when receiving a message with a _full bundle_.

## Algorithm

---

\\( \textbf{Algorithm 6} \text{: Handle Bundle} \\)

$$
\begin{aligned}
&\text{1: } \function \HandleBundle(\b): \\\\
&\text{2: } \quad \if \not \VerifyBundle(\b) \then \\\\
&\text{3: } \quad \quad \DisconnectFromPeer(\SenderPeer(\b)) \\\\
&\text{4: } \quad \quad \return \\\\
&\text{5: } \quad \endif \\\\
&\text{6: } \quad \if \b_r = r \land \b_p + 1 \ge p \then \\\\
&\text{7: } \quad \quad \for \vt \in \b \do \\\\
&\text{8: } \quad \quad \quad \HandleVote(\vt) \\\\
&\text{9: } \quad \quad \endfor \\\\
&\text{10:} \quad \endif \\\\
&\text{11: } \endfunction
\end{aligned}
$$

---

{{#include ./.include/styles.md:impl}}
> Bundle verification [reference implementation](https://github.com/algorand/go-algorand/blob/1f5c06b559ffe6485a47b623997684430bc18337/agreement/bundle.go#L147).
>
> Bundle handling in [general message handler](https://github.com/algorand/go-algorand/blob/55011f93fddb181c643f8e3f3d3391b62832e7cd/agreement/player.go#L753-L770).

The bundle handler is invoked whenever a bundle message is received.

The received bundle is immediately discarded if it is invalid (Line 2). The node
may penalize the malicious sending peer (e.g., disconnecting from or “blacklisting”
it).

If the received bundle (Line 6):

- Is for round equal to the node’s _current round_, and
- Is for at most one period behind the node’s _current period_.

Then the bundle is processed, calling the vote handler _for each vote_ in the bundle
(Lines 7 and 8).

Note that multiple bundles can be processed concurrently. Therefore, while handling
votes from a bundle \\( b \\) for _proposal-value_ \\( v \\) _separately_, if another
bundle \\( \b\prime = \Bundle(\b_r, \b_p, \b_s, v\prime) \\) is formed and observed
first (with \\( v\prime \\) not necessarily equal to \\( v \\)[^1]), votes in
\\( \b\prime \\) are relayed individually, and any output or state changes caused
by observing \\( \b\prime \\) is produced.

All leftover votes in \\( b \\) are then processed according to the new node state
determined by \\( \b\prime \\) observation (e.g., votes are discarded if the executing
step was _certification_ and a new round has started, and so \\( b_r < r \\)).

If \\( \b \\) does not pass the previous check (Line 6), then no output is produced,
and the bundle is ignored and discarded.

---

[^1]: Consider what would happen if equivocation votes contained in \\( b \\) cause
a bundle for \\( v\prime \\) to reach the required threshold before the player may
finish observing every single vote in \\( b \\).