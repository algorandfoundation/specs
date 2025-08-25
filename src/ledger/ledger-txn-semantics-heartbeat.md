$$
\newcommand \Fee {\mathrm{fee}}
\newcommand \MinTxnFee {T_{\Fee,\min}}
\newcommand \RekeyTo {\mathrm{RekeyTo}}
\newcommand \Heartbeat {\mathrm{hb}}
\newcommand \PayoutsChallengeBits {\Heartbeat_\mathrm{bits}}
$$

# Heartbeat Transaction Semantics

If a [_heartbeat transaction_](./ledger-txn-heartbeat.md)'s [_group_](./ledger-transactions.md#group)
is empty, and the [_fee_](./ledger-transactions.md#fee) is less than \\( \MinTxnFee \\),
the transaction **FAILS** to execute unless:

- The [_note_](./ledger-transactions.md#note) \\( N \\) is empty;

- The [_lease_](./ledger-transactions.md#lease) \\( x \\) is empty;

- The [_rekey to address_](./ledger-transactions.md#rekey-to) \\( \RekeyTo \\) is
empty;

- The [_heartbeat_address_](./ledger-txn-heartbeat.md#heartbeat-address), \\( a \\),
is `Online`;

- The [_heartbeat_address_](./ledger-txn-heartbeat.md#heartbeat-address), \\( a \\),
_eligibility_ flag (`ie`) is `True`;

- The [_heartbeat_address_](./ledger-txn-heartbeat.md#heartbeat-address), \\( a \\),
is _at risk_ of suspension.

An account is _at risk_ of suspension if the current round (\\( r \\)) is

$$
100\mod1000 \leq r \leq 200\mod1000,
$$

and the [_block seed_](./ledger-block.md#seed) of the most recent round that is
\\( 0 \mod 1000 \\) matches \\( a \\) in the first \\( \PayoutsChallengeBits \\) bits.

If successful, the `LastHeartbeat` of the specified heartbeat address \\( a \\)
is updated to the current round.