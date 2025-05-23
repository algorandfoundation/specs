$$
\newcommand \TP {\mathrm{TxPool}}
\newcommand \Tx {\mathrm{Tx}}
\newcommand \LastValid {\mathrm{LastValid}}
\newcommand \BlockEval {\mathrm{BlockEvaluator}}
$$

# Transaction Pool

The _Transaction Pool_ \\( \TP \\) is a Ledger component that maintains a queue of
transactions received by the node.

This section presents an implementor-oriented definition of \\( \TP \\) and is based
on the [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/pools/transactionPool.go#L52)
to clarify how it is constructed and operated by a node.

> For a succinct formal definition of the _Transaction Pool_, refer to the Ledger
> [normative specification](./ledger.md#transaction-pool).

{{#include ./.include/styles.md:impl}}
> The \\( \TP \\) implementation makes use of two distinct queues to aid the processes
> of pruning already observed transactions and block commitment:
>
> - The _remembered_ queue \\( \TP_{rq} \\),
>
> - The _pending_ queue \\( \TP_{pq} \\).
>
> The _pending queue_ \\( \TP_{pq} \\) is the structure used to supply transactions
> to the active _pending_ \\( \BlockEval \\), which evaluates transactions for the
> next block (see [reference implementation](https://github.com/algorand/go-algorand/blob/34deef26be34aebbdd7221dd2c55181e6f584bd2/data/pools/transactionPool.go#L557)).
>
> Whenever a new block is confirmed and committed to the Ledger, the node triggers
> `OnNewBlock`.
>
> This function may rebuild the pending \\( \BlockEval \\) (except for a future round’s
> pending \\( \BlockEval \\)). As part of this process, the _pending queue_ \\( \TP_{pq} \\)
> is synchronized with the _remembered queue_ \\( \TP_{rq} \\) by replacing its contents
> entirely.
>
> In contrast, when the `Remember` function is called, the verified transaction group
> is first appended to the _remembered queue_ \\( \TP_{rq} \\). Then the entire
> \\( \TP_{rq} \\) is appended to \\( \TP_{pq} \\) rather than replacing it. This
> causes the two queues to diverge temporarily until the next `OnNewBlock` call
> resyncs them.
>
> Example of `Remember` function used by the `txnHandler` to enqueue a verified
> transaction group in the [reference implementation](https://github.com/algorand/go-algorand/blob/34deef26be34aebbdd7221dd2c55181e6f584bd2/data/txHandler.go#L542).
>
> For more detail, see the `rememberCommit(bool flush)` function, which controls
> how \\( \TP_{pq} \\) is updated from \\( \TP_{rq} \\).
>
> If `flush=true`, \\( \TP_{pq} \\) is completely overwritten; if `flush=false`,
> \\( \TP_{rq} \\) is appended.
>
> In summary:
>
> - `OnNewBlock` → calls `rememberCommit(true)` → replaces \\( \TP_{pq} \\) with
> \\( \TP_{rq} \\).
>
> - `Remember` → appends to \\( \TP_{rq} \\), then calls `rememberCommit(false)`
> → appends \\( \TP_{rq} \\) to \\( \TP_{pq} \\).
>
> Temporary queue divergence is expected and resolved at the next block confirmation.
>
> Given a properly signed and _well-formed_ transaction group \\( gtx \in \TP_{pq} \\),
> we say that \\( gtx \\) is _remembered_ when it is pushed into \\( \TP_{rq} \\)
> if:
>
> - Its _aggregated fee_ is sufficiently high,
>
> - Its state changes are consistent with the prior transactions in \\( TP_{rq} \\).
>
> Note that a single transaction can be viewed as a group \\( gtx \\) containing
> only one transaction.
>
> \\( \TP_{rq} \\) is structured as a two-dimensional array. Each element in this
> array holds a list of _well-formed_, _signed_ transactions.
>
> To improve efficiency, the node also uses a key-value mapping where the keys are
> [transaction IDs](./ledger.md#transaction) and the values are the corresponding signed transactions.
> This map duplicates the data in the queue, which adds a small computational cost
> when updating the queue (for insertions and deletions), but it enables fast, constant-time
> \\( \mathcal{O}(1) \\) lookup of any enqueued transaction by its ID.
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
are to be remembered (enqueued to \\( \TP \\)). Before enqueuing, it verifies that
each transaction group is internally valid and consistent in the context of transactions
already present in \\( \TP \\). Once transactions pass these checks, they are
forwarded to any active _Block Evaluator_, so they can be considered for inclusion
in blocks currently being assembled.

## BlockAssembly

This process builds a new block’s [`payset`](./ledger.md#blocks) (the body with block’s
transactions) by selecting valid transaction groups \\( gtx \\) dequeued from the
\\( \TP \\), all within a deadline. A (pending) _Block Evaluator_ is responsible
for processing the transactions, while the `BlockAssembly` function coordinates
with it. The assembly process halts as soon as the time constraints are reached.