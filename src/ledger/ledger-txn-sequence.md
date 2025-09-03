$$
\newcommand \Tx {\mathrm{Tx}}
\newcommand \TxID {\Tx\mathrm{ID}}
\newcommand \TxSeq {\Tx\mathrm{Seq}}
\newcommand \TxCommit {\Tx\mathrm{Commit}}
\newcommand \TxTail {\Tx\mathrm{Tail}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \SHA256 {\mathrm{SHA256}}
\newcommand \SHA512 {\mathrm{SHA512}}
\newcommand \Sig {\mathrm{Sig}}
\newcommand \STIB {\mathrm{STIB}}
\newcommand \Genesis {\mathrm{Genesis}}
\newcommand \GenesisID {\Genesis{\mathrm{ID}}}
\newcommand \GenesisHash {\Genesis\Hash}
\newcommand \ApplyData {\mathrm{ApplyData}}
\newcommand {\abs}[1] {\lvert #1 \rvert}
\newcommand \MaxTxnBytesPerBlock {B_{\max}}
\newcommand \MaxTxTail {\mathrm{TxTail}_{\max}}
$$

# Transaction Sequences, Sets, and Tails

## Transaction Sequence

Each block contains a _transaction sequence_, an ordered sequence of transactions
in that block.

The transaction sequence of block \\( r \\) is denoted \\( \TxSeq_r \\).

Each valid block contains a _transaction commitment_ \\( \TxCommit_r \\) which is
a [Merkle Tree Commitment](../crypto/crypto-merkle-tree.md) to this sequence.

The leaves in the Merkle Tree are hashed as:

$$
\Hash(\texttt{TL}, \TxID, \Hash(\STIB))
$$

Where:

- \\( \Hash \\) is the cryptographic [SHA-512-256](../crypto/crypto-sha512-256.md)
hash function;

- The \\( \TxID \\) is the 32-byte transaction identifier;

- The \\( \Hash(\STIB) \\) is a 32-byte hash of the _signed transaction_ and [ApplyData]()
for the transaction, hashed with the [domain-separation prefix](../crypto/crypto-domain-separators.md)
`STIB` (_signed transaction in block_).

_Signed transactions in a block_ \\( \STIB \\) are encoded in a slightly different
way than _standalone transactions_ \\( \Tx \\), for efficiency:

If a standalone transaction \\( \Tx \\) contains a \\( \GenesisID \\) value, then:

- The transaction’s \\( \GenesisID \\) **MUST** match the block’s \\( \GenesisID \\);

- The transaction’s \\( \GenesisID \\) value **MUST** be omitted from the \\( \STIB \\)
transaction’s msgpack encoding in the block;

- The \\( \STIB \\) transaction’s msgpack encoding in the block **MUST** indicate
the \\( \GenesisID \\) value was omitted by including a key `hgi` with the boolean
value `True`.

Since transactions **MUST** include a \\( \GenesisHash \\) value, the \\( \GenesisHash \\)
value of each transaction in a block **MUST** match the block’s \\( \GenesisHash \\),
and the \\( \GenesisHash \\) value is omitted from the \\( \STIB \\) transaction
as encoded in a block.

- Signed transactions in a block are also augmented with the \\( \ApplyData \\)
that reflect how that transaction was applied to the [Account State](./ledger-account-state.md).

The _transaction commitment_ (\\( \TxCommit \\)) for a block covers the transaction encodings
with the changes described above.

Individual _transaction signatures_ cover the original encoding of transactions as
standalone transactions (\\( \Tx \\)).

In addition to the _transaction commitment_, each block contains _[SHA-256](../crypto/crypto-sha256.md)
and [SHA-512](../crypto/crypto-sha512.md) transaction commitments_. They allow a
verifier not supporting [SHA-512/256](../crypto/crypto-sha512-256.md) function to
verify proof of membership for transactions.

To construct these commitments, we use a [Vector Commitment](../crypto/crypto-vector-commitment.md).

The leaves in the Vector Commitment tree are hashed respectively as:

$$
\SHA256(\texttt{TL}, \SHA256(\TxID), \SHA256(\STIB))
$$

and

$$
\SHA512(\texttt{TL}, \SHA512(\TxID), \SHA512(\STIB))
$$

Where:

- \\( \SHA256 \\) is the cryptographic [SHA-256](../crypto/crypto-sha256.md) hash
function;

- \\( \SHA256(\TxID) = \SHA256(\texttt{TX} || \Tx) \\)

- \\( \SHA256(\STIB) = \SHA256(\texttt{STIB} || \Sig(\Tx) || \ApplyData) \\)

- \\( \SHA512 \\) is the cryptographic [SHA-512](../crypto/crypto-sha512.md) hash
function;

- \\( \SHA512(\TxID) = \SHA512(\texttt{TX} || \Tx) \\)

- \\( \SHA512(\STIB) = \SHA512(\texttt{STIB} || \Sig(\Tx) || \ApplyData) \\)

These Vector Commitments use [SHA-256](../crypto/crypto-sha256.md) and [SHA-512](../crypto/crypto-sha512.md)
for internal nodes as well.

A _valid transaction sequence_ \\( \TxSeq \\) contains no duplicates: each transaction
in the transaction sequence **MUST** appear exactly once.

We can call the set of these transactions the _transaction set_ (for convenience,
we may also write \\( \TxSeq_r \\) to refer unambiguously to the set in this block).

For a block to be valid, its transaction sequence \\( \TxSeq_r \\) **MUST** be valid
(i.e., no duplicate transactions may appear there).

All transactions have a _size_ in bytes. The size of the transaction \\( \Tx \\)
is denoted \\( \abs{\Tx} \\).

For a block to be _valid_, the sum of the sizes of each transaction in a transaction
sequence **MUST NOT** exceed \\( \MaxTxnBytesPerBlock \\); in other words:

$$
\sum_{\Tx \in \TxSeq_r} \abs{\Tx} \leq \MaxTxnBytesPerBlock
$$

## Transaction Tails

The _transaction tail_ \\( \TxTail \\) for a given round \\( r \\) is a set produced
from the union of the transaction identifiers \\( \TxID \\) of each transaction in
the last \\( \MaxTxTail \\) transaction sets and is used to detect _duplicate_ transactions.

In other words,

$$
\TxTail_r = \bigcup_{r-\MaxTxTail \leq s \leq r-1} \{\Hash(\Tx) | \Tx \in \TxSeq_s\}.
$$

As a result, the _transaction tail_ for round \\( r+1 \\) is computed as follows:

$$
\TxTail_{r+1} = \TxTail_r \setminus \{\Hash(\Tx) | \Tx \in \TxSeq_{r-T_{\max}}\} \cup \{\Hash(\Tx) | \Tx \in \TxSeq_r\}.
$$

The transaction tail is part of the Ledger state but is _distinct_ from the account
state and is _not committed_ to in the block.