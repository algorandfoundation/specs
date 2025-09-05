$$
\newcommand \ABFT {\mathrm{ABFT}}
\newcommand \Credentials {\mathrm{Credentials}}
\newcommand \sk {\mathrm{sk}}
\newcommand \VRF {\mathrm{VRF}}
$$

# General Concepts

The Algorand Agreement Protocol, or _Algorand Byzantine Fault Tolerance_ (\\( \ABFT \\)),
is a consensus mechanism ensuring secure, decentralized agreement on transactions'
ordering and validity in the Algorand blockchain. It tolerates malicious actors as
long as less than one-third of the participants are compromised.

The protocol relies on a _cryptographic sortition_ to randomly and verifiably self-select
a small, representative group of participants to propose and validate blocks. This
randomness ensures security, scalability, and resistance to attacks.

By achieving instant finality, \\( \ABFT \\) enables Algorand to process transactions
efficiently, making it suitable for large-scale, real-time applications.

In each round, a _block_ must be confirmed. In the context of this section, a block
is treated as an opaque data packet with two mandatory fields:

- A _block hash_,
- A _randomness seed_.

For details on the remaining fields and the structure of a block, please refer to
the Ledger's [normative specification](../ledger/ledger.md) and [non-normative overview](../ledger/ledger-nn.md).

The Algorand Agreement Protocol is executed between _nodes_.

Functionally, an Algorand node "plays" on behalf of every actively participating
account whose [participation keys](../keys/keys-participation.md) are registered
for voting.

Each of these accounts can be viewed as an independent _player_ in the protocol,
identified by its unique address \\( I \\) and associated balance.

All the accounts registered on the node share a unified view of the _transaction
pool_ and blockchain state, which is maintained by the node through which they participate
in the protocol.

Consensus is reached progressively. A _round_ is the primary unit of time in the
consensus protocol. Each round aims to agree on a single block to append to the blockchain.

The protocol begins a new round once the previous one has finalized a block.

## Credentials

We define a structure \\( \Credentials \\) for ease of use and readability.

This structure will contain all the necessary fields for identifying a voting player,
which includes:

- Address (\\( I \\)): A unique identifier for the participating account.

- Secret key (\\( \sk_r \\)): A private key associated with the account, used for
cryptographic operations such as signing messages[^1].

- \\( \VRF \\) proof (\\( y \\)): A cryptographic proof generated using the
Verifiable Random Function (\\( \VRF \\))[^2]. <!-- TODO: link to VRF -->

The sets of observed votes \\( V \\) and proposals \\( P \\), observed in a given
round, are utilized here with the same definition as in the [normative specification](./abft.md).

Analogous to these, we define a set of observed bundles \\( B \\) for a given round,
that is built taking subsets of votes in \\( V \\) according to the rules for a
valid bundle specified in the [normative specification](./abft-messages-bundles.md).

---

[^1]: The secret key \\( \sk \\) is round-dependent because it makes use of a
[two-level ephemeral key scheme](../keys/keys-ephemeral.md#algorands-two-level-ephemeral-signature-scheme-for-authentication)
under the hood. In the context of this document, this procedure is replaced by an
opaque structure that produces the key needed for the round and abstracts away both
a signature and verification procedure.

[^2]: Since the sortition hash \\( \VRF_{out} \\) can be derived from a proof
\\( y \\), we assume that \\( \VRF_{out} \\) is implicitly available whenever
\\( y \\) is present.
