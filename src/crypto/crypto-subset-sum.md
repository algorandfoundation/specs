# SUBSET-SUM

Algorand uses [SUBSET-SUM algorithm](https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/sumhash-spec.pdf),
which is a _quantum-resilient_ hash function.

This algorithm is used:

- To create Merkle Trees for State Proofs,

- To commit on ephemeral public keys in the Merkle Keystore structure used in the
two-level [Ephemeral Signature Scheme](../keys/keys-ephemeral.md).

> For further details on the Ephemeral Signature Scheme, refer to Algorand Keys
> [normative specification](../keys/keys-ephemeral.md).
