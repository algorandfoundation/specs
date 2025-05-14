# Blocks

Blocks are data structures that store accounts' state transitions in the blockchain,
global state fields, and information related to the agreement protocol.

Each block consists of a _header_ and a _body_.

- The _header_ contains metadata such as details about the block itself, the current
_round_, various hashes, rewards, etc.,

- The _body_ holds transaction data and account updates.

> For further details on the _block header_, refer to the Ledger [normative specification](./ledger.md#blocks).

The Ledger package in the `go-algorand` reference implementation includes functions
to effectively manage and interact with blocks.

The following sections provide a brief explanation and examples for each field in
the block structure.

> For a formal specification of these fields, refer to the Ledger [normative specification](./ledger.md).