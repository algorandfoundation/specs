$$
\newcommand \Commit {\mathrm{Commit}}
\newcommand \RetrieveProposal {\mathrm{RetrieveProposal}}
\newcommand \ApplyDeltas {\mathrm{ApplyDeltas}}
\newcommand \TP {\mathrm{TransactionPool}}
\newcommand \Update {\mathrm{Update}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \pset {\mathit{payset}}
$$

# Commitment

The commitment is the final stage that updates the copy of the Ledger on the node,
applying all the state deltas (e.g., account balances, application state, etc.)
related to the transactions contained in the committed block proposal.

## Algorithm

In the following pseudocode \\( e_t \\) denotes the body (transactions) of the
proposal (a.k.a. the _payset_).

---

\\( \textbf{Algorithm 8} \text{: Commit} \\)

$$
\begin{aligned}
&\text{1: } \function \Commit(v) \\\\
&\text{2: } \quad e \gets \RetrieveProposal(v)_e \\\\
&\text{3: } \quad L \gets L || e \\\\
&\text{4: } \quad \ApplyDeltas(e) \\\\
&\text{5: } \quad \TP.\Update(e_t) \\\\
&\text{6:  } \endfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Commit block proposal [reference implementation](https://github.com/algorand/go-algorand/blob/55011f93fddb181c643f8e3f3d3391b62832e7cd/agreement/player.go#L366-L374).

The function commits to the Ledger the block corresponding to the received
_proposal-value_.

The _proposal-value_ must be committable, which implies both _validity_ and _availability_
of the full block body and seed.

The node retrieves the full block \\( e \\) related to the _proposal-value_ (Line 2),
and appends it to the Ledger \\( L \\) (Line 3).

Then, the node updates the Ledger state (and trackers) with all state changes (deltas)
produced by the new committed block.

> For further details, refer to the Ledger [normative section](./ledger.md#state-deltas).

The \\( \TP \\) is then purged of all transactions in the committed block.

> For further details on this process, see the Ledger [non-normative section](./ledger-overview.md#transaction-pool).