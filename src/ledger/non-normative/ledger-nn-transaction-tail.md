{{#include ../../_include/tex-macros/pseudocode.md}}

$$
\newcommand \TxTail {\mathrm{TxTail}}
\newcommand \CheckDuplicate {\mathrm{CheckDuplicate}}
\newcommand \Tx {\mathrm{Tx}}
\newcommand \ID {\mathrm{ID}}
\newcommand \Lease {\mathrm{Lease}}
\newcommand \FirstValid {\mathrm{FirstValid}}
\newcommand \LastValid {\mathrm{LastValid}}
\newcommand \LowWaterMark {\mathrm{LowWaterMark}}
\newcommand \FirstChecked {\mathrm{FirstChecked}}
\newcommand \LastChecked {\mathrm{LastChecked}}
\newcommand \RecentLeaseMap {\mathrm{RecentLeaseMap}}
\newcommand \LastValidMap {\mathrm{LastValidMap}}
$$

# Transaction Tail

The _Transaction Tail_ \\( \TxTail \\) is a data structure responsible for deduplication
and recent history lookups. It can be considered a rolling window of _recent_ transactions
and block headers observed in a reduced history of rounds, optimized for lookup
and retrieval.

{{#include ../../_include/styles.md:impl}}
> Transaction tail [reference implementation](https://github.com/algorand/go-algorand/blob/55011f93fddb181c643f8e3f3d3391b62832e7cd/ledger/txtail.go#L46).

It provides the following fields:

- `recentLeaseMap`\
A mapping of `round -> (TXLease -> round)` that saves the transaction `Lease` by
observation round, and the mapping uses `TXLease` as keys to store the `Lease` expiring
round.

- `blockHeaderData`\
Contains recent block header data. The expected availability range is `[Latest -
MaxTxnLife, Latest]`, allowing `MaxTxnLife + 1` rounds of lookback ( \\( 1001 \\)
with current parameters).

- `lastValidMap`\
A mapping of `round -> (txid -> uint16)` that enables the lookup of all transactions
expiring in a given round. For each round, the inner map stores `txid`s mapped to
16-bit unsigned integers representing the difference between the transaction’s `lastValid`
field and the round it was confirmed (`lastValid > confirmationRound` for all confirmed
transactions).

- `lowWaterMark`\
An unsigned 64-bit integer representing a round number such that for any transactions
where the `lastValid` field is `lastValid < lowWaterMark`, the node can quickly assert
that it is not present in the \\( \TxTail \\).

## Deduplication Check

A duplication check is the core functionality of \\( \TxTail \\).

---

\\( \textbf{Algorithm 1} \text{: Check Duplicate} \\)

<!-- markdownlint-disable MD013 -->
$$
\begin{aligned}
&\text{1: } \PSfunction \CheckDuplicate(\Tx_r, \FirstValid, \LastValid, \Tx_{\ID}, \Tx_{\Lease}) \\\\
&\text{2: } \quad \PSif \LastValid < \TxTail.\LowWaterMark \PSthen \\\\
&\text{3: } \quad \quad \PSreturn \Tx_{\ID} \text{ is not in } \TxTail \\\\
&\text{4: } \quad \PSendif \\\\
&\text{5: } \quad \PSif \Tx_{\Lease} \neq \emptyset \PSthen \\\\
&\text{6: } \quad \quad \FirstChecked \gets \FirstValid \\\\
&\text{7: } \quad \quad \LastChecked \gets \LastValid \\\\
&\text{8: } \quad \quad \PSfor r \in [\FirstChecked, \LastChecked] \PSdo \\\\
&\text{9: } \quad \quad \quad \PSif \Tx_{\Lease} \in \RecentLeaseMap(\Tx_r).\Lease \land r \leq \Tx_{\Lease}.\mathrm{Expiration} \PSthen \\\\
&\text{10:} \quad \quad \quad \quad \PSreturn \Lease \text{ is a duplicate} \\\\
&\text{11:} \quad \quad \quad \PSendif \\\\
&\text{12:} \quad \quad \PSendfor \\\\
&\text{13:} \quad \PSendif \\\\
&\text{14:} \quad \PSif \Tx_{\ID} \in \TxTail.\LastValidMap(\LastValid).\Tx_{\ID} \PSthen \\\\
&\text{15:} \quad \quad \PSreturn \Tx_{\ID} \text{ is a duplicate transaction} \\\\
&\text{16:} \quad \PSendif \\\\
&\text{17:} \quad \PSreturn \\\\
&\text{18: } \PSendfunction
\end{aligned}
$$
<!-- markdownlint-enable MD013 -->

---

The algorithm receives four fields of a transaction:

- The transaction round \\( \Tx_r \\),

- The transaction validity round fields \\( \FirstValid \\) and \\( \LastValid \\),

- The transaction identifier \\( \Tx_{\ID} \\),

- The transaction lease \\( \Tx_{\Lease} \\) (if set).

An early check is performed, where the \\( \LowWaterMark \\) field is used to quickly
discard transactions too far back in history and already purged from the \\( \ TxTail \\).

In case a \\( \Tx_{\Lease} \\) is set, the \\( \RecentLeaseMap \\) field is used
to deduplicate by \\( \Lease \\).

After checking for the \\( \Lease \\), the \\( \LastValidMap \\) is used and the
transaction is deduplicated through a lookup of \\( \Tx_{\ID} \\) by its \\( \LastValid \\)
round.

If the transaction is not found on the \\( \TxTail \\), the node can assume it is
not a duplicate, otherwise the validity interval would be too far back in the past
for the transaction to be confirmed anyway.
