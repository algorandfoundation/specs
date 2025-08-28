$$
\newcommand \Rfv {\mathrm{FirstValidRound}}
\newcommand \Rlv {\mathrm{LastValidRound}}
\newcommand \KLT {\mathrm{KeyLifeTime}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \SchemeID {\mathrm{SchemeID}}
\newcommand \Sig {\mathrm{Signature}}
\newcommand \Verify {\mathrm{VerifyingKey}}
\newcommand \VectorIdx {\mathrm{VectorIndex}}
\newcommand \Proof {\mathrm{Proof}}
\newcommand \Digest {\mathrm{Digest}}
\newcommand \ZDigest {\mathrm{Zero}\Digest}
\newcommand \SigBits {\Sig\mathrm{BitString}}
\newcommand \pk {\mathrm{pk}}
\newcommand \Leaf {\mathrm{Leaf}}
\newcommand \Round {\mathrm{Round}}
$$

# Algorand State Proof Keys

## Algorand's Committable Ephemeral Keys Scheme - Merkle Signature Scheme

Algorand achieves [forward security](https://en.wikipedia.org/wiki/Forward_secrecy)
using a _Merkle Signature Scheme_. This scheme consists of using a different _ephemeral
key_ for each round in which it will be used. The scheme uses _vector commitment_
to generate commitment to those keys. 

The private key **MUST** be deleted after the round passes to achieve complete forward
secrecy.

> This is analogous to the scheme discussed in the [voting keys section](./keys-participation.md).

The Merkle scheme uses [FALCON](https://falcon-sign.info/) scheme as the underlying
digital signature algorithm.

> For further details on FALCON scheme, refer to the Cryptography primitives [specification](../crypto/crypto.md#falcon).

The tree’s depth is bound to \\( 16 \\) to bound verification paths on the tree.
Hence, the maximum number of keys which can be created is at most \\( 2^{16} \\).

{{#include ../_include/styles.md:impl}}
> Merkle signature scheme [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/crypto/merklesignature/merkleSignatureScheme.go).

### Public Commitment

The scheme generates multiple keys for the entire participation period. Given
\\( \Rfv \\), \\( \Rlv \\) and a \\( \KLT \\), a key is generated for each round
\\( r \\) that holds:

$$
\Rfv \leq r \leq \Rlv \land r \mod \KLT = 0
$$

Currently, \\( \KLT = 256 \\) rounds.

After generating the public keys, the scheme creates a vector commitment using the
keys as leaves.

Leaf hashing is done in the following manner:

$$
leaf_{i} = \Hash(\texttt{"KP"} || \SchemeID || r || P_{k_{i}}), \text{ for each corresponding round.}
$$

Where:

- \\( \SchemeID \\) is a 16-bit, little-endian constant integer with value of \\( 0 \\).

- \\( r \\) is a 64-bit, little-endian integer representing the start round for which
the key \\( P_{k_{i}} \\) is valid. The key would be valid for all rounds in
\\( [r, \ldots, r + \KLT - 1] \\).

- \\( P_{k_{i}} \\) is a 14,344-bit string representing the FALCON ephemeral public key.

- \\( \Hash \\) is the SUBSET-SUM hash function as defined in the [Cryptographic Primitives Specification](../crypto/crypto-overview.md).

### Signatures

A _signature_ in the scheme consists of the following elements: 

- \\( \Sig \\) is a signature generated with the FALCON scheme.

- \\( \Verify \\) is a FALCON ephemeral public key.

- \\( \VectorIdx \\) is an index of the ephemeral public key leaf in the vector
commitment.

- \\( \Proof \\) is an array of size \\( n \\) (\\( n \leq 16 \\) since the number
of keys is bounded) which contains hash results (\\( \Digest_{0}, \ldots, \Digest_n \\)).
\\( \Proof \\) is used as a Merkle verification path on the ephemeral public key. 

When the _committer_ gives a \\( n \\)-depth authentication path for index \\( \VectorIdx \\),
the _verifier_ must write \\( \VectorIdx \\) as \\( n \\)-bit number and read it
from MSB to LSB to determine the leaf-to-root path.

When signature is to be hashed, it must be serialized into a binary string according
to the following format:

$$
\SigBits = (\SchemeID || \Sig || \Verify || \VectorIdx || \Proof)
$$

Where:

- \\( \SchemeID \\) is a 16-bit, little-endian constant integer with value of \\( 0 \\).

- \\( \Sig \\) is a 12,304-bit string representing a FALCON signature in a CT format.

- \\( \Verify \\) is a 14,344-bit string.

- \\( \VectorIdx \\) is a 64-bit, little-endian integer.

- \\( \Proof \\) is constructed in the following way:

  - if \\( n = 16 \\):\
    \\( \Proof = (n || \Digest_{0} || \ldots || \Digest_{15}) \\)

  - else:\
    \\( \Proof = (n || \ZDigest_{0} || \ldots || \ZDigest_{d-1} || \Digest_{0} || \ldots || \Digest_{n-1}) \\)

Where:

- \\( n \\) is a 8-bit string.

- \\( \Digest_{i} \\) is a 512-bit string representing sumhash result.

- \\( \ZDigest \\) is a constant 512-bit string with value \\( 0 \\).

- \\( d = 16 - n \\)

### Verifying Signatures

A signature \\( s \\) for a message \\( m \\) at round \\( r \\) is valid under
the public commitment \\( \pk \\) and \\( \KLT \\) if:

- The FALCON signature \\( s.\Sig \\) is valid for the message \\( m \\) under the
public key \\( s.\Verify \\)

- The proof \\( s.\Proof \\) is a valid vector commitment proof for the entry \\( \Leaf \\)
at index \\( s.\VectorIdx \\) with respect to the vector commitment root \\( \pk \\)
where:

  - \\( \Leaf := \texttt{"KP"} || \SchemeID || \Round || s.\Verify \\),

  - \\( \Round :=  r - (r \mod \KLT) \\).