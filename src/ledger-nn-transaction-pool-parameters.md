$$
\newcommand \TP {\mathrm{TxPool}}
\newcommand \AD {\mathrm{assemblyDeadline}}
\newcommand \AW {\mathrm{assemblyWait}}
\newcommand \NB {\mathrm{newBlock}}
\newcommand \FeeMul {\mathrm{feeThresholdMultiplier}}
\newcommand \FeeExp {\mathrm{expFeeFactor}}
\newcommand \FeePB {\mathrm{feePerByte}}
\newcommand \ExpiredHistory {\mathrm{expiredHistory}}
$$

> In the context of this section, the phrase _“giving up”_ refers to finalizing
> the current block under assembly; this includes completing the `payset` and calculating
> all associated metadata that depends on it.

# Parameters

This section presents a list of some relevant parameters that govern the behavior
of the \\( \TP \\).

In the case that there are leftover transactions in the \\( \TP_{pq} \\), the \\( \TP \\)
saves them for the next block assembly.

## \\( \TP.\mathrm{Size} \\)

A [consensus parameter](./infrastructure.md#node-configuration-values) that defines
the maximum number of transactions the transaction pool queue can hold. When this
limit is reached, any new incoming transactions, even if valid, are not enqueued
and are instead dropped.

{{#include ./.include/styles.md:impl}}
> In the `go-algorand` reference implementation, this limit is set to \\( 75{,}000 \\)
> transactions.

## \\( \FeeMul \\)

This dynamic parameter is updated each time a new block is observed. Under normal
conditions, when the \\( TP \\) is not congested, its value is \\( 0 \\). However,
if the queues become congested, this parameter increases. As it grows, it raises
the _minimum fee_ threshold required for transactions to be accepted into \\( TP \\).

> For more details, see the [update](./ledger-nn-transaction-pool-update.md) and
> [fee prioritization](./ledger-nn-fee-prioritization.md) sections.

## \\( \FeeExp \\)

A [consensus parameter](./infrastructure.md#node-configuration-values), denoted as
`TxPoolExponentialIncreaseFactor`, which determines how sharply the required transaction
fee increases based on the number of full blocks pending (an indicator of \\( TP \\)
congestion). This factor amplifies the fee threshold in congested conditions. The
default value in `go-algorand` consensus parameters is currently set to \\( 2 \\).

## \\( \FeePB \\)

A dynamically computed parameter that defines the current minimum number of μALGO
per byte that a transaction must pay to be accepted into the \\( \TP \\). When the
\\( TP \\) is not heavily congested, this parameter remains well below the `minTxnFee`,
meaning the base fee requirement still controls the admission threshold. Under normal
conditions (no congestion), this value is set to \\( 0 \\).

## \\( \delta_{\AD}\\)

A [consensus parameter](./infrastructure.md#node-configuration-values) that sets
a strict deadline for the `BlockAssembly` process to stop constructing a `payset`.
This ensures block assembly completes within the required time frame.

{{#include ./.include/styles.md:impl}}
> In the `go-algorand` reference implementation, \\( \delta_{\AD} = \mathrm{ProposalAssemblyTime} = 0.5 \\)
seconds.

## \\( \epsilon_{\AW} \\)

An additional time buffer that the `BlockAssembly` algorithm waits after the official
deadline before _“giving up”_. This grace period allows slightly delayed transactions
to be included if possible.

{{#include ./.include/styles.md:impl}}
> In the `go-algorand` reference implementation, \\( \epsilon_{\AW} = 150 \\) milliseconds.

## \\( \ExpiredHistory \\)

A multiplier that determines how many rounds of historical data on expired transactions
are retained. Specifically, the node keeps \\( (\ExpiredHistory \times \mathrm{maxTxnLife}) \\)
rounds of history. Maintaining this history helps dynamically adjust transaction
prioritization based on fee structures, as it provides insight into network congestion
(e.g., if many transactions are expiring without being included in a block).

{{#include ./.include/styles.md:impl}}
> In the `go-algorand` reference implementation, `expiredHistory` is set to \\( 10 \\),
> therefore, the node keeps \\( 10 \times 1000 = 10{,}000 \\) rounds of history.

## \\( \delta_{\NB}\\)

A time constant that defines how long the system should wait when processing a new
block that appears to be committed to the Ledger. This timeout is used within the
`Ingestion` function to ensure timely handling of new blocks.

{{#include ./.include/styles.md:impl}}
> In the `go-algorand` reference implementation, this limit is set to \\( 1 \\)
> second.

# Constants

The following two time constants are used to estimate how long it would take to
properly complete a block after the system has _“given up”_ on assembling the `payset`.

These estimates work together with \\( \delta_{\AD} \\) and \\( \epsilon_{\AW} \\)
to ensure that block finalization occurs within the required timeframe for proposal
generation.

- `generateBlockBaseDuration`, currently set to \\( 2 \\) milliseconds.

- `generateBlockTransactionDuration`, currently set to \\( 2155 \\) nanoseconds.