---

numbersections: true
title: "Algorand Cryptographic Primitive Specification"
date: \today
abstract: >
  Algorand relies on a set of cryptographic primitives to guarantee
  the integrity and finality of data.  This document describes these
  primitives.
---

# Algorand Cryptographic Primitive Specification

## Representation

As a preliminary for guaranteeing cryptographic data integrity,
Algorand represents all inputs to cryptographic functions (i.e., a
cryptographic hash, signature, or verifiable random function) via a
canonical and domain-separated representation.


### Canonical Msgpack

Algorand uses a version of [msgpack][msgpack] to produce canonical
encodings of data.  Algorand's msgpack encodings are valid msgpack
encodings, but the encoding function is deterministic to ensure a
canonical representation that can be reproduced to verify signatures.
A canonical msgpack encoding in Algorand must follow these rules:

 1. Maps must contain keys in lexicographic order;
 2. Maps must omit key-value pairs where the value is a zero-value,
    unless otherwise specified;
 3. Positive integer values must be encoded as "unsigned" in msgpack,
    regardless of whether the value space is semantically signed or
    unsigned;
 4. Integer values must be represented in the shortest possible
    encoding;
 5. Binary arrays must be represented using the "bin" format family
    (that is, use the most recent version of msgpack rather than the
    older msgpack version that had no "bin" family).


### Domain Separation

Before an object is input to some cryptographic function, it is
prepended with a multi-character domain-separating prefix.  The list
below specifies each prefix (in quotation marks):

 - For cryptographic primitives:
    - "OT1" and "OT2": The first and second layers of keys used for
      [ephemeral signatures](#ephemeral-key-signature).
    - "MA": An internal node in a [Merkle tree](#merkle-tree).
    - "KP": Is a public key used by the Merkle Keystore [merkle keystore](merklekeystore)
 - In the [Algorand Ledger][ledger-spec]:
    - "BH": A _Block Header_.
    - "BR": A _Balance Record_.
    - "GE": A _Genesis_ configuration.
    - "STIB": A _SignedTxnInBlock_ that appears as part of the leaf in the Merkle tree of transactions.
    - "TL": A leaf in the Merkle tree of transactions.
    - "TX": A _Transaction_.
 - In the [Algorand Byzantine Fault Tolerance protocol][abft-spec]:
    - "AS": An _Agreement Selector_, which is also a [VRF][Verifiable
      Random Function] input.
    - "CR": A _Credential_.
    - "SD": A _Seed_.
    - "PL": A _Payload_.
    - "PS": A _Proposer Seed_.
    - "VO": A _Vote_.
 - In other places:
    - "MX": An arbitrary message used to prove ownership of a
      cryptographic secret.
    - "NPR": A message which proves a peer's stake in an Algorand
      networking implementation.
    - "TE": An arbitrary message reserved for testing purposes.
    - "Program": A TEAL bytecode program.
    - "ProgData": Data which is signed within TEAL bytecode programs.
    - In Algorand auctions:
       - "aB": A _Bid_.
       - "aD": A _Deposit_.
       - "aO": An _Outcome_.
       - "aP": Auction parameters.
       - "aS": A _Settlement_.


## Hash Functions

### SHA512-256
Algorand uses the [SHA-512/256 algorithm][sha] as its primary
cryptographic hash function.

Algorand uses this hash function to (1) commit to data for signing and
for the Byzantine Fault Tolerance protocol, and (2) rerandomize its
random seed.

### SUBSET-SUM
Algorand uses [SUBSET-SUM algorithm][sumhash] which is a quantum-resilient hash function.
This function is used by the [Merkle Keystore](merklekeystore) to commit on
ephemeral public keys. It is also used to create Merkle trees for the StateProofs. 

## Digital Signature

### ED25519

Algorand uses the [ed25519][ed25519] digital signature scheme to sign
data.


### FALCON

Algorand uses a deterministic version of [falcon scheme][falcon]. Falcon is quantum resilient and a SNARK friendly digital signature scheme used to sign in StateProofs. 

The library defines the following sizes:
- Publickey = 1793 bytes
- Privatekey = 2305 bytes
- Signature = 1241 bytes

For key generation, Algorand uses a shake256 function which is initialized with random seed of 48 bytes.


### Ephemeral-key Signature



## Verifiable Random Function


### Cryptographic Sortition


## Merkle tree

Algorand uses a Merkle tree to commit to an array of elements and
to generate and verify proofs of elements against such a commitment.
The Merkle tree algorithm is defined for a dense array of N elements
numbered 0 through N-1.  We now describe how to commit to an array (to
produce a commitment in the form of a root hash), what a proof looks like,
and how to verifying a proof for one or more elements.

Since there is at most one valid proof that can be efficiently computed
for a given position, element, and root commitment, we do not formally
define an algorithm for generating a proof.  Any algorithm that
generates a valid proof (i.e., which passes verification) is correct.
A reasonable strategy for generating a proof is to follow the logic
of the proof verifier and fill in the expected left- and right-sibling
values in the proof based on the internal nodes of the Merkle tree built
up during commitment.

The Merkle tree can be created using one of the supported [hash functions](#hash-functions)

### Commitment

To commit to an array of N elements, each element is first hashed
to produce a 32-byte hash value, together with the appropriate
[domain-separation prefix](#domain-separation); this produces a list
of N hashes.  If N=0, then the commitment is all-zero (i.e., 32 zero
bytes).  Otherwise, the list of N 32-byte values is repeatedly reduced
to a shorter list, as described below, until exactly one 32-byte value
remains; at that point, this resulting 32-byte value is the commitment.

The reduction procedure takes pairs of even-and-odd-indexed values in
the list (for instance, the values at positions 0 and 1; the values at
positions 2 and 3; and so on) and hashes each pair to produce a single
value in the reduced list (respectively, at position 0; at position
1; and so on).  To hash two values into a single value, the reduction
procedure concatenates the domain-separation prefix "MA" together with
the two values (in the order they appear in the list), and then applies
the hash function.  When a list has an odd number of values, the last
value is paired together with an all-zero value (i.e., 32 zero bytes).

The pseudocode for the commitment algorithm is as follows:

```python
def commit(elems):
  hashes = [H(elem) for elem in elems]
  return reduce(hashes)

def reduce(hashes):
  if len(hashes) == 0:
    return [0 for _ in range(32)]
  if len(hashes) == 1:
    return hashes[0]
  nexthashes = []
  while len(hashes) > 0:
    left = hashes[0]
    right = hashes[1] if len(hashes) > 1 else [0 for _ in range(32)]
    hashes = hashes[2:]
    nexthashes.append(H("MA" + left + right))
  return reduce(nexthashes)
```

### Proofs

Logically, to verify that an element appears at some position P in the
array, the verifier runs a variant of the commit procedure to compute
a candidate root hash, and then checks if the resulting root hash is
equal to the expected commitment value.  The key difference is that the
verifier does not have access to the entire list of committed elements;
the verifier just has some subset of elements (one or more), along with the
positions at which these elements appear.  Thus, the verifier needs to
know the siblings (the `left` and `right` values used in the `reduce()`
function above) to compute its candidate root hash.  The list of these
siblings constitutes the proof; thus, a proof is a list of zero or more
32-byte hash values.  Algorand defines a deterministic order in which
the verification procedure expects to find siblings in this proof, so no
additional information is required as part of the proof (in particular,
no information about which part of the Merkle tree each proof element
corresponds to).

### Verifying a proof

The following pseudocode defines the logic for verifying a proof (a
list of 32-byte hashes) for one or more elements, specified as a list
of position-element pairs, sorted by position in the array, against a
root commitment.  The function `verify` returns `True` if `proof` is a
valid proof for all elements in `elems` being present at their positions
in the array committed to by `root`.  (The pseudocode might raise an
exception due to accessing the proof past the end; this is equivalent
to returning `False`.)  The function implements a variant of `reduce()`
for a sparse array, rather than a fully-populated one.

```python
def verify(elems, proof, root):
  if len(elems) == 0:
    return len(proof) == 0
  if len(elems) == 1 and len(proof) == 0:
    return elems[0].pos == 0 && elems[0].hash == root

  i = 0
  nextelems = []
  while i < len(elems):
    pos = elems[i].pos
    poshash = elems[i].hash
    sibling = pos ^ 1
    if i+1 < len(elems) and elems[i+1].pos == sibling:
      sibhash = elems[i+1].hash
      i += 2
    else:
      sibhash = proof[0]
      proof = proof[1:]
      i += 1
    if pos&1 == 0:
      h = H("MA" + poshash + sibhash)
    else:
      h = H("MA" + sibhash + poshash)
    nextelems.append({"pos": pos/2, "hash": h})

  return verify(nextelems, proof, root)
```



[ledger-spec]: https://github.com/algorand/spec/ledger.md
[abft-spec]: https://github.com/algorand/spec/abft.md

[sha]: https://doi.org/10.6028/NIST.FIPS.180-4
[sumhash]: https://github.com/algorand/go-sumhash/blob/master/spec/sumhash-spec.pdf
[ed25519]: https://tools.ietf.org/html/rfc8032
[msgpack]: https://github.com/msgpack/msgpack/blob/master/spec.md
[merklekeystore]: https://github.com/algorand/spec/partkey.md
[falcon]: 