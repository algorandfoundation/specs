$$
\newcommand \TP {\mathrm{TxPool}}
\newcommand \Tx {\mathrm{Tx}}
\newcommand \LastValid {\mathrm{LastValid}}
$$

# Transaction Pool

The _Transaction Pool_ \\( \TP \\) is a Ledger component that maintains a queue of
transactions received by the node.

This section presents an implementor-oriented definition of \\( \TP \\) and is based
on the [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/pools/transactionPool.go#L52)
to clarify how it is constructed and operated by a node.

> For a succinct formal definition of the _Transaction Pool_, refer to the Ledger
> [normative specification](./ledger.md#transaction-pool).

The \\( \TP \\) implementation makes use of two distinct queues to aid the processes
of pruning already observed transactions and block commitment:

- The _remembered_ queue \\( \TP_{rq} \\),

- The _pending_ queue \\( \TP_{pq} \\).
> The \\( \TP_{pq} \\) is the queue used to feed an active `pendingBlockEvaluator`. Whenever a new block is confirmed and added into the Ledger, the `OnNewBlock(.)` notification function may rebuild the `pendingBlockEvaluator` (with the exception of a `pendingBlockEvaluator` for a round in the future being present, see [here](https://github.com/algorand/go-algorand/blob/34deef26be34aebbdd7221dd2c55181e6f584bd2/data/pools/transactionPool.go#L557))  and as a side effect of this, the \\( \TP_{pq} \\) gets overwritten with the \\( \TP_{rq} \\), making them in-sync at that point.
> Calls to the Remember(.) function, on the other hand, (see for example the txnHandler on the [reference implementation](https://github.com/algorand/go-algorand/blob/34deef26be34aebbdd7221dd2c55181e6f584bd2/data/txHandler.go#L542)) enqueue the passed verified transaction group to the \\( \TP_{rq} \\) but _also_ append it into the \\( \TP_{pq} \\), so in this instance they might become temporarily out of sync until another call to OnNewBlock(.).
> See also the rememberCommit(bool flush) function in the [reference implementation](https://github.com/algorand/go-algorand/blob/34deef26be34aebbdd7221dd2c55181e6f584bd2/data/pools/transactionPool.go#L259), which manages the \\( \TP_{pq} \\) according to the contents of the  \\( \TP_{rq} \\) and the _flush_ boolean flag.
Given a properly signed and well-formed transaction group \\( gtx \in TP_{pq} \\),
we say that \\( gtx \\) is _remembered_ when it is pushed into \\( \TP_{rq} \\) if:

- Its _aggregated fee_ is sufficiently high,

- Its state changes are consistent with the prior transactions in \\( TP_{rq} \\).

> A single transaction can be viewed as a group \\( gtx \\) containing only one
> transaction.

{{#include ./.include/styles.md:impl}}
> In the reference implementation, \\( TP_{rq} \\) is structured as a two-dimensional
> array. Each element in this array holds a list of well-formed, signed transactions.
> To improve efficiency, the node also uses a key-value mapping where the keys are
> [transaction IDs](./ledger.md#transaction) and the values are the corresponding
> signed transactions. This map duplicates the data in the queue, which adds a small
> computational cost when updating the queue (for insertions and deletions), but
> it enables fast, constant-time \\( \mathcal{O}(1) \\) lookup of any enqueued transaction
> by its ID.
> 
> Additionally, \\( TP_{pq} \\) serves as another layer of optimization. It stores
> transaction groups that are prepared in advance for the next _block assembly_
> process. In a multithreaded system with strict timing constraints, this setup
> allows \\( TP_{rq} \\) to be pruned as soon as a new block is committed, even
> while the next block is being assembled concurrently.

## Transaction Pool Functions

The following is a list of _abstracted minimal functionalities_ that the \\( \TP \\)
should provide.

## Prioritization

An algorithm that decides which transactions should be retained and which ones should
be dropped, especially important when the \\( \TP \\) becomes congested (i.e., when
transactions are arriving faster than they can be processed, de-enqueued in a block,
or observed in a committed block and pruned). A simple approach could be a _“first-come,
first-served”_ policy. However, the `go-algorand` reference implementation uses a
more selective method: a threshold-based _fee prioritization_ algorithm, which prioritizes
transactions paying higher fees.

## Update

This process is triggered when a new block is observed as committed. At this point,
transactions are pruned if they meet either of the following conditions:

- They have already been included in a committed block (as determined by the `OnNewBlock`
function), or
- Their `LastValid` [field]((./ledger.md#transactions)) has expired. Specifically,
if the current round \\( r > \Tx_{\LastValid}\\).

In addition to pruning outdated or committed transactions, this step also updates 
the internal variables used for the _prioritization_.

## Ingestion

This component handles the ingestion of new transaction groups (\\( gtx \\)) that
are to be remembered (enqueued to \\( TP_{rq} \\)). Before enqueuing, it verifies
that each transaction group is internally valid and consistent in the context of
transactions already present in \\( TP_{rq} \\). Once transactions pass these checks,
they are forwarded to any active _Block Evaluator_, so they can be considered for
inclusion in blocks currently being assembled.

## BlockAssembly

This process builds a new block’s [`payset`](./ledger.md#blocks) (the body with block’s
transactions) by selecting valid transaction groups \\( gtx \\) dequeued from the
\\( TP \\), all within a deadline. A (pending) _Block Evaluator_ is responsible
for processing the transactions, while the `BlockAssembly` function coordinates
with it. The assembly process halts as soon as the time constraints are reached.