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
    - "MB": A bottom leaf in a vector commitment [vector commitment](#vector-commitment).
    - "KP": Is a public key used by the Merkle siganture scheme [Merkle Siganture Scheme](merklesignaturescheme)
    - "spc": A coin used as part of the state proofs construction.
    - "spp": Participant's information (state proof pk and weight) used for state proofs.
    - "sps": A signature from a specific participant that is used for state proofs.
 - In the [Algorand Ledger][ledger-spec]:
    - "BH": A _Block Header_.
    - "BR": A _Balance Record_.
    - "GE": A _Genesis_ configuration.
    - "spm": A state proof message.
    - "STIB": A _SignedTxnInBlock_ that appears as part of the leaf in the Merkle tree of transactions.
    - "TL": A leaf in the Merkle tree of transactions.
    - "TX": A _Transaction_.
    - "SpecialAddr": A prefix used to generate designated addresses for specific functions, such as sending state proof transactions.
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

### SHA512/256
Algorand uses the [SHA-512/256 algorithm][sha] as its primary
cryptographic hash function.

Algorand uses this hash function to (1) commit to data for signing and
for the Byzantine Fault Tolerance protocol, and (2) rerandomize its
random seed.

### SHA256
Algorand uses [SHA-256 algorithm][sha256] to allow verification of Algorand's state and transactions
on environments where SHA512_256 is not supported.


### SUBSET-SUM
Algorand uses [SUBSET-SUM algorithm][sumhash] which is a quantum-resilient hash function.
This function is used by the [Merkle Keystore](merklekeystore) to commit on
ephemeral public keys. It is also used to create Merkle trees for the StateProofs. 

## Digital Signature

### ED25519

Algorand uses the [ed25519][ed25519] digital signature scheme to sign
data.

Algorand changes the ed25519 verification algorithm in the following way  (using notation from [ed25519][ed25519]):
- Reject if R or A (PK) are equal to one of the following (non-canonical encoding - this check is actually required by [ed25519][ed25519] but not all libraries implement it)
  - `0100000000000000000000000000000000000000000000000000000000000080`
  - `ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
  - `EEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F`
  - `EEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
  - `EDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
  - `EDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F`
  - a point which holds `(x,y) where: 2**255 -19 <= y <= 2**255.` Where we remind that y is defined as the encoding of the point with the right-most bit cleared

- Reject if A (PK) is equal to one of the following: (small order points)
  - `0100000000000000000000000000000000000000000000000000000000000000`
  - `ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F`
  - `0000000000000000000000000000000000000000000000000000000000000080`
  - `0000000000000000000000000000000000000000000000000000000000000000`
  - `C7176A703D4DD84FBA3C0B760D10670F2A2053FA2C39CCC64EC7FD7792AC037A`
  - `C7176A703D4DD84FBA3C0B760D10670F2A2053FA2C39CCC64EC7FD7792AC03FA`
  - `26E8958FC2B227B045C3F489F2EF98F0D5DFAC05D3C63339B13802886D53FC05`
  - `26E8958FC2B227B045C3F489F2EF98F0D5DFAC05D3C63339B13802886D53FC85`


- Reject non-canonical S (this check is actually required by [ed25519][ed25519] but not all libraries implement it)<br>
```
 0 <= s < L 
 (where 
  L = 2^252+27742317777372353535851937790883648493)
```
- Use the cofactor equation (this is the default verification equation in [ed25519][ed25519]):<br>
```
  [8][S]B = [8]R + [8][K]A'
```


### FALCON

Algorand uses a [deterministic][deterministic-falcon] version of [falcon scheme][falcon]. Falcon is quantum resilient and a SNARK friendly digital signature scheme used to sign in StateProofs. Falcon signatures contains 
salt version. Algorand only accepts signatures with salt version = 0.

The library defines the following sizes:
 - Publickey = 1793 bytes
 - Privatekey = 2305 bytes 
 - Signatures
    - CT-format = 1538 bytes
    - Compressed format = variable length up to a maximum size of 1423 bytes .

For key generation, Algorand uses random seed of 48 bytes.


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

## Vector commitment

Algorand uses [Vector Commitments][vector-commitment], which allows for concisely committing to an ordered (indexed) vector of data entries, based on Merkle trees.

# State Proofs

State proofs (aka Compact Certificates) allow external parties to efficiently validate
Algorand blocks.  The [technical report][compactcert] provides the
overall approach of state proofs; this section describes the
specific details of how state proofs are realized in Algorand.

As a brief summary of the technical report, state proofs operate
in three steps:

- The first step is to commit to a set of participants that are eligible
  to produce signatures, along with a weight for each participant.
  In Algorand's case, these end up being the online accounts, and the
  weights are the account balances.

- The second step is for each participant to sign the same message, and
  broadcast this signature to others.  In Algorand's case, the message would contain
  a commitment on blocks in a specific period.

- The third step is for relays to collect these signatures from a
  large fraction of participants (by weight) and generate a state 
  proof.  Given a sufficient number of signatures, a relay
  can form a state proof, which effectively consists of a
  small number of signatures, pseudo-randomly chosen out of all of
  the signatures.

The resulting state proof proves that at least some `provenWeight`
of participants have signed the message.  The actual weight of
all participants that have signed the message must be greater than
`provenWeight`.

## Participant commitment

The state proof scheme requires a commitment to a dense array of participants, 
in some well-defined order. In order to grantee this property, Algorand uses Vector Commitment.
Leaf hashing is done in the following manner:

_leaf_ = hash("spp" || _Weight_ || _KeyLifeTime_ || _StateProofPK_) for each online participant.

where:

- _Weight_ is a 64-bit, little-endian integer representing the participant's balance in MicroAlgos

- _KeyLifeTime_ is a 64-bit, little-endian constant integer with value of 256

- _StateProofPK_ is a 512-bit string representing the participant's merkle signature scheme commitment.


## Signature format 

Similarly to the participant commitment, the state proof scheme requires a commitment
to a signature array. Leaf hashing is done in the following manner:


_leaf_ = hash("sps" || _L_ || _serializedMerkleSignature_) for each online participant.

where:

-  _L_ is a 64-bit, little-endian integer representing the participant's `L` value as described in the [technical report][compactcert].

- _serializedMerkleSignature_ representing a merkleSignature of the participant  [merkle signature binary representation](https://github.com/algorandfoundation/specs/blob/master/dev/partkey.md#signatures)


When a signature is missing in the signature array, i.e the prover didn't receive a signature for this slot. The slot would be 
decoded as an empty string. As a result the vector commitment leaf of this slot would be the hash  value of the constant domain separator "MB" (the bottom leaf)

## Choice of revealed signatures

As described in the [technical report][compactcert] section IV.A, a
state proof contains a pseudorandomly chosen set of signatures.
The choice is made using a coin.  In Algorand's implementation, the
coin derivation is made in the following manner:

_Hin_ = ("spc" || _version_ || _participantCommitment_ || _LnProvenWeight_ || _signatureCommitment_ || _signedWeight_ || _stateproofMessageHash_ )

where:

_version_ is an 8-bit constant with value of 0

_participantCommitment_ is a 512-bit string representing the vector commitment root on the participant array

_LnProvenWeight_ an 8-bit string representing the natural logarithm value $\ln(ProvenWeight)$ with 16 bits of precision, as described in
[SNARK-Friendly  Weight Threshold Verification][weight-threshold]

_signatureCommitment_ is a 512-bit string representing the vector commitment root on the signature array

_signedWeight_ is a 64-bit, little-endian integer representing the state proof signed weight

_stateproofMessageHash_ is a 256-bit string representing the message that would be verified by the state proof. (it would be the hash result of the state proof message)


For short, we refer below to the revealed signatures simply as 'reveals'

We compute:

_R_ = SHAKE256(_Hin_)

For every reveal,
- Extract a 64-bit string from _R_. 
- use rejection sampling and extract additional 64-bit string from _R_ if needed

This would grantee having a uniform random coin in [0,signedWeight).

## State proof format

A State proof consists of seven fields:

- The Vector commitment root to the array of signatures, under msgpack
  key `c`.

- The total weight of all signers whose signatures appear in the array
  of signatures, under msgpack key `w`.

- The Vector commitment proof for the signatures revealed above, under msgpack
  key `S`.

- The Vector commitment proof for the participants revealed above, under msgpack
  key `P`.

- The Falcon signature salt version, under msgpack key `v`, is the expected salt version of 
every signature in the state proof.

- The set of revealed signatures, chosen as described in section IV.A
  of the [technical report][compactcert], under msgpack key `r`.  This set is stored as a
  msgpack map.  The key of the map is the position in the array of the
  participant whose signature is being revealed.  The value in the map
  is a msgpack struct with the following fields:

  -- The participant information, encoded as described [above](#participant-commitment),
    under msgpack key `p`.

  -- The signature information, encoded as described [above](#signature-format),
    under msgpack key `s`.

- A sequence of positions, under msgpack key `pr`. The sequence defines the order of the
  participant whose signature is being revealed. i.e

  _PositionsToReveal_ = [IntToInd(coin$_{0}$),...,IntToInd(coin$_{numReveals-1}$)]

where IntToInd and numReveals are defined in the [technical report][compactcert], section IV.


Note that, although the state proof contains a commitment to
the signatures, it does not contain a commitment to the participants.
The set of participants must already be known in order to verify a
state proof.  In practice, a commitment to the participants is
stored in the block header of an earlier block, and in the state proof message that was
proven by the previous state proof.


## State proof validity

A state proof is valid for the message hash, 
with respect to a commitment to the array of participants,
if:

- The depth of the vector commitment for the signature and the participant information
  should be less than or equal to 20.

- All falcon signatures should have the same salt version and it should 
  by equal to the salt version specified in state proof

- The number of reveals in the state proof should be less than of equal to 640

- Using the trusted Proven Weight (supplied by the verifier), The state proof should pass
  the [SNARK-Friendly  Weight Threshold Verification][weight-threshold] check.

- All of the participant and signature information that appears in
  the reveals is validated by the Vector commitment proofs for the participants
  (against the commitment to participants, supplied by the verifier) 
  and signatures (against the commitment in the state proof itself), respectively.

- All of the signatures are valid signatures for the message hash.

- For every i $\in$ {0,...,numReveals-1} there is a reveal in map denote by _r_$_{i}$, where  _r_$_{i}$ $\gets$ T[_PositionsToReveal_[_i_]]
  and _r_$_{i}$.Sig.L <= _coin_$_{i}$ <  _r_$_{i}$.Sig.L + _r_$_{i}$.Part.Weight. 
  
  T is defined in the [technical report][compactcert], section IV.

## Setting security strength

We define two parameters for security strength:

- ${target_C}$: "classical" security strength. This is set to ${k+q}$, (${k+q}$ are defined in section IV.A of the [technical report][compactcert]). The goal is to have ${<= 1/2^{k}}$ probability of breaking the state proof by an attacker that makes up to ${2^{q}}$ hash evaluations/queries. We use ${target_C}$ = 192, which corresponds to, for example, ${k=128}$ and ${q=64}$, or ${k=96}$ and ${q=96}$.
- ${target_{PQ}}$: "post-quantum" security strength. This is set to ${k+2q}$, because at a cost of about ${2^q}$, a quantum attacker can search among up to ${2^{2q}}$ hash evaluations (this is a highly attacker-favorable estimate). We use ${target_{PQ} = 256}$, which corresponds to, for example, ${k=128}$ and ${q=64}$, or ${k=96}$ and ${q=80}$.


[ledger-spec]: https://github.com/algorand/spec/ledger.md
[abft-spec]: https://github.com/algorand/spec/abft.md

[sha]: https://doi.org/10.6028/NIST.FIPS.180-4
[sha256]: https://datatracker.ietf.org/doc/html/rfc4634
[sumhash]: https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/sumhash-spec.pdf
[ed25519]: https://tools.ietf.org/html/rfc8032
[msgpack]: https://github.com/msgpack/msgpack/blob/master/spec.md
[merklesignaturescheme]: https://github.com/algorandfoundation/specs/blob/master/dev/partkey.md
[falcon]: https://falcon-sign.info/falcon.pdf
[deterministic-falcon]: https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/falcon-deterministic.pdf
[vector-commitment]: https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/merkle-vc-full.pdf
[compactcert]: https://eprint.iacr.org/archive/2020/1568/20210330:194331
[weight-threshold]: https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/weight-thresh.pdf