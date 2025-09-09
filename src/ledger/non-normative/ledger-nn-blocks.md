# Blocks

Blocks are data structures that store accounts’ state transitions in the blockchain,
global state fields, and information related to the agreement protocol.

A _block_ defines a _state transition_ of the Ledger.

Algorand block size is \\( 5 \\) MB.

Each block consists of a _header_ and a _body_.

- The _header_ contains metadata such as details about the block itself, the current
_round_, various hashes, rewards, etc.,

- The _body_ holds transaction data and account updates.

> For further details on the _block header_, refer to the Ledger [normative specification](../ledger-block.md).

{{#include ../../_include/styles.md:impl}}
> Block header [reference implementation](https://github.com/algorand/go-algorand/blob/13e66ff9ba5073637f69f9dd4e5572f19b77e38c/data/bookkeeping/block.go#L38).

The Ledger package in the `go-algorand` reference implementation includes functions
to effectively manage and interact with blocks.

Blocks are assembled in two steps: first by the `MakeBlock` function and then by
the `WithSeed`.

{{#include ../../_include/styles.md:impl}}
> `MakeBlock` [reference implementation](https://github.com/algorand/go-algorand/blob/13e66ff9ba5073637f69f9dd4e5572f19b77e38c/data/bookkeeping/block.go#L471).
>
> `WithSeed` [reference implementation](https://github.com/algorand/go-algorand/blob/13e66ff9ba5073637f69f9dd4e5572f19b77e38c/data/bookkeeping/block.go#L278).

The following sections provide a brief explanation and examples for each field in
the block structure.

> For a formal specification of these fields, refer to the Ledger [normative specification](../ledger.md).
