---
numbersections: true
title: "Algorand Cryptographic Primitive Specification"
date: \today
abstract: >
  Algorand relies on a set of cryptographic primitives to guarantee
  the integrity and finality of data.  This document describes these
  primitives.
---


Representation
==============

As a preliminary for guaranteeing cryptographic data integrity,
Algorand represents all inputs to cryptographic functions (i.e., a
cryptographic hash, signature, or verifiable random function) via a
canonical and domain-separated representation.


Canonical Msgpack
-----------------

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


Domain Separation
-----------------

Before an object is input to some cryptographic function, it is
prepended with a multi-character domain-separating prefix.  The list
below specifies each prefix (in quotation marks):

 - For cryptographic primitives:
    - "OT1" and "OT2": The first and second layers of keys used for
      [ephemeral signatures](Ephemeral-key Signatures).
 - In the [Algorand Ledger][ledger-spec]:
    - "BH": A _Block Header_.
    - "BR": A _Balance Record_.
    - "GE": A _Genesis_ configuration.
    - "PF": A _Payset_ encoded as a flat list.
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


Hash Function
=============

Algorand uses the [SHA-512/256 algorithm][sha] as its primary
cryptographic hash function.

Algorand uses this hash function to (1) commit to data for signing and
for the Byzantine Fault Tolerance protocol, and (2) rerandomize its
random seed.


Digital Signature
=================

Algorand uses the [ed25519][ed25519] digital signature scheme to sign
data.


Ephemeral-key Signature
-----------------------



Verifiable Random Function
==========================


Cryptographic Sortition
-----------------------


[ledger-spec]: https://github.com/algorand/spec/ledger.md
[abft-spec]: https://github.com/algorand/spec/abft.md

[sha]: TODO-sha
[ed25519]: TODO-ed25519
[msgpack]: TODO-msgpack
