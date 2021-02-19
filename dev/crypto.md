---
numbersections: true
title: "Algorand Cryptographic Primitive Specification"
date: \today
abstract: >
  Algorand relies on a set of cryptographic primitives to guarantee
  the integrity and finality of data.  This document describes these
  primitives.
---


# Representation

As a preliminary for guaranteeing cryptographic data integrity,
Algorand represents all inputs to cryptographic functions (i.e., a
cryptographic hash, signature, or verifiable random function) via a
canonical and domain-separated representation.


## Canonical Msgpack

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


## Domain Separation

Before an object is input to some cryptographic function, it is
prepended with a multi-character domain-separating prefix.  The list
below specifies each prefix (in quotation marks):

 - For cryptographic primitives:
    - "OT1" and "OT2": The first and second layers of keys used for
      [ephemeral signatures](#ephemeral-key-signature).
    - "MA": An internal node in a [Merkle tree](#merkle-tree).
    - "ccc": A coin used as part of the compact certificate construction.
    - "ccs": A signature from a specific participant that is used to form a compact certificate.
    - "ccp": A voting participant's information used for compact certificates.
 - In the [Algorand Ledger][ledger-spec]:
    - "BH": A _Block Header_.
    - "BR": A _Balance Record_.
    - "GE": A _Genesis_ configuration.
    - "STIB": A _SignedTxnInBlock_ that appears as part of the leaf in the Merkle tree of transactions.
    - "TL": A leaf in the Merkle tree of transactions.
    - "TX": A _Transaction_.
    - "SpecialAddr": A prefix used to generate designated addresses for specific functions, such as sending compact certificate transactions.
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


# Hash Function

Algorand uses the [SHA-512/256 algorithm][sha] as its primary
cryptographic hash function.

Algorand uses this hash function to (1) commit to data for signing and
for the Byzantine Fault Tolerance protocol, and (2) rerandomize its
random seed.


# Digital Signature

Algorand uses the [ed25519][ed25519] digital signature scheme to sign
data.


## Ephemeral-key Signature



# Verifiable Random Function


## Cryptographic Sortition


# Merkle tree

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

## Commitment

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

```
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

## Proofs

Logically, to verify that an element appears at some position P in the
array, the verifier runs a variant of the commit procedure to compute
a candidate root hash, and then checks if the resulting root hash is
equal to the expected commitment value.  The key difference is that the
verifier does not have access to the entire list of committed elements;
the verifier just has some subset of elemens (one or more), along with the
positions at which these elements appear.  Thus, the verifier needs to
know the siblings (the `left` and `right` values used in the `reduce()`
function above) to compute its candidate root hash.  The list of these
siblings constitutes the proof; thus, a proof is a list of zero or more
32-byte hash values.  Algorand defines a deterministic order in which
the verification procedure expects to find siblings in this proof, so no
additional information is required as part of the proof (in particular,
no information about which part of the Merkle tree each proof element
corresponds to).

## Verifying a proof

The following pseudocode defines the logic for verifying a proof (a
list of 32-byte hashes) for one or more elements, specified as a list
of position-element pairs, sorted by position in the array, against a
root commitment.  The function `verify` returns `True` if `proof` is a
valid proof for all elements in `elems` being present at their positions
in the array committed to by `root`.  (The pseudocode might raise an
exception due to accessing the proof past the end; this is equivalent
to returning `False`.)  The function implements a variant of `reduce()`
for a sparse array, rather than a fully-populated one.

```
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
      i++
    else:
      sibhash = proof[0]
      proof = proof[1:]
    if pos&1 == 0:
      h = H("MA" + poshash + sibhash)
    else:
      h = H("MA" + sibhash + poshash)
    nextelems.append({"pos": pos/2, "hash": h})

  return verify(nextelems, proof, root)
```


# Compact certificates

Compact certificates allow external parties to efficiently validate
Algorand blocks.  The [technical report][compactcert] provides the
overall approach of compact certificates; this section describes the
specific details of how compact certificates are realized in Algorand.

As a brief summary of the technical report, compact certificates operate
in three steps:

- The first step is to commit to a set of participants that are eligible
  to produce signatures, along with a weight for each participant.
  In Algorand's case, these end up being the online accounts, and the
  weights are the account balances.

- The second step is for each participant to sign the same message, and
  broadcast this signature to others.  In Algorand's case, this ends up
  being a signature on the block header.

- The third step is for participants to collect these signatures from a
  large fraction of participants (by weight) and generate a compact
  certificate.  Given a sufficient number of signatures, a participant
  can form a compact certificate, which effectively consists of a
  small number of signatures, pseudo-randomly chosen out of all of
  the signatures.

The resulting compact certificate proves that at least some `provenWeight`
of participants have signed the message.  The actual weight of
all participants that have signed the message must be greater than
`provenWeight`.

## Participant commitment

The participants are represented using a `msgpack` encoding with three
fields: the participant's [voting key](#ephemeral-key-signature) (under
msgpack key `p`), the participant's weight (under msgpack key `w`),
and the participant's key dilution for their ephemeral voting key (under
msgpack key `d`).  The compact certificate scheme requires a Merkle tree
commitment to a dense array of participants, in some well-defined order.
To commit to participants, the three fields are encoded using canonical
msgpack with domain-separation prefix `ccp`.

## Signature format

The signature from each participant is represented using a `msgpack`
encoding with two fields: the one-time signature of the message (in
Algorand's case, the block header), under the msgpack key `s`, and the
`L` value as described in the technical report, under the msgpack key
`l`.  The compact certificate requires committing to a dense array of
signatures using a Merkle tree; for this purpose, these signatures are
encoded using canonical msgpack with domain-separation prefix `ccs`.

## Choice of revealed signatures

As described in the [technical report][compactcert] section IV.A, a
compact certificate contains a pseudorandomly chosen set of signatures.
The choice is made using a coin.  In Algorand's implementation, the
coin is chosen using a hash of the following canonical msgpack encoding,
with domain-separation prefix `ccc`:

- The J index of the coin, from the technical report, under msgpack
  key `j`.

- The total weight of all signers whose signatures are being used to
  construct the compact certificate, under msgpack key `sigweight`.

- The `provenWeight` being proven with the compact certificate, under
  msgpack key `provenweight`.

- The root of the Merkle tree commitment to the array of participants,
  under msgpack key `partcom`.

- The root of the Merkle tree commitment to the array of signatures,
  under msgpack key `sigcom`.

- The hash of the message being signed, under msgpack key `msghash`.

The hash of the above message is then interpreted as a big-endian integer,
and the coin is computed as that integer modulo the total weight of
all signatures.

## Compact certificate format

A compact certificate consists of five fields:

- The Merkle root commitment to the array of signatures, under msgpack
  key `c`.

- The total weight of all signers whose signatures appear in the array
  of signatures, under msgpack key `w`.

- The set of revealed signatures, chosen as described in section IV.A
  of the [technical report][compactcert], under msgpack key `r`.  This set is stored as a
  msgpack map.  The key of the map is the position in the array of the
  participant whose signature is being revealed.  The value in the map
  is a msgpack struct with the following fields:

  -- The participant information, encoded as described [above](#participant-commitment),
    under msgpack key `p`.

  -- The signature information, encoded as described [above](#signature-format),
    under msgpack key `s`.

- The Merkle proof for the signatures revealed above, under msgpack
  key `S`.  The Merkle proof is an array of 32-byte hash digests.

- The Merkle proof for the participants revealed above, under msgpack
  key `P`.

Note that, although the compact certificate contains a commitment to
the signatures, it does not contain a commitment to the participants.
The set of participants must already be known in order to verify a
compact certificate.  In practice, a commitment to the participants is
stored in the block header of an earlier block.

## Compact certificate validity

A compact certificate is valid for the message hash specified in the
certificate, with respect to a commitment to the array of participants,
if:

- All of the participant and signature information that appears in
  the reveals is validated by the Merkle proofs for the participants
  (against the commitment to participants, supplied outside of the
  certificate) and signatures (against the commitment in the compact
  certificate itself), respectively.

- All of the signatures are valid signatures for the message hash
  specified in the compact certificate.

- The signed weight claimed by the compact certificate is at least
  the proven weight that the certificate is trying to establish.

- The reveals included as part of the compact certificate include
  all of the coins generated based on the certificate parameters.


[ledger-spec]: https://github.com/algorand/spec/ledger.md
[abft-spec]: https://github.com/algorand/spec/abft.md

[sha]: TODO-sha
[ed25519]: TODO-ed25519
[msgpack]: https://github.com/msgpack/msgpack/blob/master/spec.md
[compactcert]: https://eprint.iacr.org/2020/1568
