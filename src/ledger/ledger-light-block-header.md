$$
\newcommand \StateProof {\mathrm{SP}}
\newcommand \StateProofInterval {\delta_\StateProof}
$$

# Light Block Header

A light block header is a structure containing a subset of fields from Algorand's
_block header_ and the commitment of said block header.

Light block header contains the following components:

- The block's _seed_, under msgpack key `0`.

- The block's _hash_, under msgpack key `1`.

- The block's _genesis hash_, under msgpack key `gh`.

- The block's _round_, under msgpack key `r`.

- The block's [SHA-256](../crypto/crypto-sha256.md) transaction commitment, under msgpack
key `tc`.

## Commitment

The light block header _commitment_ for rounds
\\( (X \cdot \StateProofInterval, \ldots, (X+1) \cdot \StateProofInterval] \\)
for some number \\( X \\), defined as the root of a [vector commitment](../crypto/crypto-vector-commitment.md)
whose leaves are light block headers for rounds
\\( X \cdot \StateProofInterval, \ldots, (X+1) \cdot \StateProofInterval \\)
respectively.

The hash function [SHA-256](../crypto/crypto-sha256.md) is used to create this vector commitment.
