---
numbersections: true
title: "Algorand Key Specification"
date: \today
abstract: >
    This document specifies the list of keys and their capabilities in Algorand.
---

# Algorand Key Specification

## Overview

An algorand node interacts with three types of cryptographic keys:

 - _root keys_, a key pair (public and private) used to control the access to a particular account.
   These key pairs are also known as spending keys.

 - _voting keys_, a set of keys used for authentication, i.e. identify an 
    account. Algorand uses a hierarchical (two\-level) signature scheme that 
    ensures [forward security](https://en.wikipedia.org/wiki/Forward_secrecy), 
    which will be detailed in next section. 

 - _VRF selection keys_, keys used for proving membership of selection. 

An agreement vote message is valid only when it contains a proper VRF proof and
is signed with the correct voting key.

## Root Keys

Root keys are used to identify ownership of an account. An algorand node only interacts with
the public key of a root key. The public key of a root key is also used as the account
address. Root keys are used to sign transaction messages as well as delegating the
voting authentication using _voting keys_, unless that specific account was rekeyed. A rekeyed
account would use the rekeyed key in lieu of the root key.

## Voting Keys 

\newcommand \KeyDilution {\mathrm{KeyDilution}}
\newcommand \Batch {\mathrm{Batch}}
\newcommand \Offset {\mathrm{Offset}}

### Algorand's Two\-level Ephemeral Signature Scheme for Authentication

An ephemeral subkey is a key pair that produces one\-time signature 
for messages. It must be deleted after use to ensure forward security.
Algorand's ephemeral subkeys 
uses [Ed25519 public\-key signature system](https://ed25519.cr.yp.to/).

Algorand uses a two\-level ephemeral signature scheme.
Instead of signing voting messages directly, Algorand accounts use their
_voting keys_ to sign an intermediate ephemeral sub-key. 
This intermediate ephemeral sub-key signs a batch of leaf-level ephemeral 
sub-keys. Hence, each intermediate ephemeral sub-key is associated with a
batch number ($\Batch$), and each leaf ephemeral sub-key is associate with a
batch number (of its parent key) and an offset ($\Offset$, denotes its offset
within a batch). A voting message is signed hierarchically: 
the voting keys root key $\rightarrow$ batch sub\-key $\rightarrow$ leaf sub-key
$\rightarrow$ agreement voting message (more details in next sub-section: One\-time 
Signature).

Each leaf-level ephemeral sub-key is used for voting on a single agreement round,
and will be deleted afterward. Once a batch of leaf-level ephemeral sub-keys run out,
a new batch is generated. Algorand allows users to set the number of leaf-level ephemeral
sub-key per batch, $\KeyDilution$. For example, the default $\KeyDilution$ 
value of of the genesis consensus protocol (V17) was $10,000$. 
An Algorand account can change its $\KeyDilution$ via 
key registration transactions (see 
[the ledger specification](./ledger.md)).


### One\-time Signature

\newcommand \SubKeyPK {\mathrm{SubKeyPK}}
\newcommand \OTSSOffsetID {\mathrm{OneTimeSignatureSubkeyOffsetID}}
\newcommand \OTSSBatchID {\mathrm{OneTimeSignatureSubkeyBatchID}}
\newcommand \OneTimeSignature {\mathrm{OneTimeSignature}}
\newcommand \Sig {\mathrm{Sig}}
\newcommand \PK {\mathrm{PK}}
\newcommand \PKSigOld {\mathrm{PKSigOld}}
\newcommand \PKTwo {\mathrm{PK2}}
\newcommand \PKOneSig {\mathrm{PK1Sig}}
\newcommand \PKTwoSig {\mathrm{PK2Sig}}


$\OTSSBatchID$ identifies an intermediate level ephemeral sub-key of 
a batch. $\OTSSBatchID$ is signed by the voting keys root key. It has the following
fields:
 
 - _SubKey Public key_ $\SubKeyPK$, the public key of this sub-key.

 - _Batch_ $\Batch$, batch number of this sub-key.

$\OTSSOffsetID$ identifies an leaf-level ephemeral sub-key. $\OTSSOffsetID$
is signed with a batch sub-key. It has the following fields:

 - _SubKey Public key_ $\SubKeyPK$, the public key of this sub-key.

 - _Batch_ $\Batch$, batch number of this sub-key.

 - _Offset_ $\Offset$, offset of this sub-key in current batch.

Finally, $\OneTimeSignature$ is a cryptographic signature used in voting
messages between Algorand users. It contains the following fields:

 - _Signature_ $\Sig$, a signature of message under $\PK$

 - _Public Key_ $\PK$, the public key of the message signer, 
   $\PK$ is part of a leaf-level ephemeral subkey. 

 - _Old Style Signature_ $\PKSigOld$, **deprecated** field. 
  It is still in the message only for compability reason.

 - _Public Key 2_  $\PKTwo$, the public key of the current batch. 

 - _Public Key 1 Signature_ $\PKOneSig$, a signature of $\OTSSOffsetID$
   under $\PKTwo$.
 
 - _Public Key 2 Signature_ $\PKTwoSig$, a signature of $\OTSSBatchID$ under
   the _voting keys_.

## VRF Selection Keys

\newcommand \unauthenticatedVote {\mathrm{unauthenticatedVote}}
\newcommand \UnauthenticatedCredential {\mathrm{UnauthenticatedCredential}}
\newcommand \Sender {\mathrm{Sender}}
\newcommand \Round {\mathrm{Round}}
\newcommand \Period {\mathrm{Period}}
\newcommand \Step {\mathrm{Step}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \VrfOut {\mathrm{VrfOut}}
\newcommand \Credential {\mathrm{Credential}}
\newcommand \Cred {\mathrm{Cred}}
\newcommand \Weight {\mathrm{Weight}}
\newcommand \DomainSeparationEnabled {\mathrm{DomainSeparationEnabled}}
\newcommand \Hashable {\mathrm{Hashable}}
\newcommand \Vote {\mathrm{Vote}}

To check the validity of a voting message, its VRF selection key
needs to be verified. Algorand uses Verifiable Random Function (VRF) to 
generate selection keys (more details in 
[crypto specification](./crypto.md)).

More specifically, an unverified vote ($\unauthenticatedVote$) has the
following fields:

 - _Raw Vote_ $\mathrm{R}$, an inner struct contains $\Sender$, $\Round$, $\Period$, 
   $\Step$, and $\Proposal$.

 - _Unverified Credential_ $\Cred$. $\Cred$ contains
   a single field $\mathrm{Proof}$, which is a VRF proof.

 - _Signature_ $\Sig$, one-time signature of the vote.

Once receiving an unverified vote ($\unauthenticatedVote$) from the network, 
an Algorand node verifies its VRF selection key by checking the validity
of the VRF Proof (in $\Cred$), the committee membership parameters that
it is conditioned on, and the voter's voting stake. 
If verified, the result of this verification is 
wrapped in a $\Credential$ struct, containing the following fields:

 - _Unverifed Credential_ $\UnauthenticatedCredential$, the unverified 
  selection key from the VRF proof.

 - _Weight_ $\Weight$, the weight of the vote.

 - _VRF Output_ $\VrfOut$, the cached output of VRF verification.

 - _Domain Separation Enabled_ $\DomainSeparationEnabled$, Domain separation
   flag, now must be true by the protocol.

 - _Hashable_ $\Hashable$, the original credential

And this verified credential is wrapped in a $\Vote$ struct with _Raw Vote_ 
($\mathrm{R}$), _Verified Credential_ ($\Credential$), and _Signature_ ($\Sig$).


## Algorand State Proof Keys 
### Algorand's Committable Ephemeral Keys Scheme - Merkle Signature Scheme

Algorand achieves [forward security](https://en.wikipedia.org/wiki/Forward_secrecy) using Merkle Signature Scheme. This scheme consists of using a different ephemeral key for each round in which it will be used. The scheme uses vector commitment to generate commitment to those keys. 
The private key must be deleted after the round passes in order the completely achieves forward secrecy.

The Merkle scheme uses Falcon scheme as the underlying digital signature algorithm.

In order to bound verification paths on the tree, the tree's depth is bound to 16. Hence, the maximum number of keys which can be created is at most 2$^{16}$.

#### Public Commitment

The scheme generates multiple keys for the entire participation period. Given _FirstValidRound_, _LastValidRound_ and an _keyLifeTime_, a key is generated for each _Round_ that holds:

 _FirstValidRound_ $\leq$ _Round_ $\leq$ _LastValidRound_ and _Round_ % _keyLifeTime_ = 0

Currently, _keyLifeTime_ is set to 256.

After generating the public keys, the scheme creates a vector commitment using the keys as leaves.
Leaf hashing is done in the following manner:

_leaf_$_{i}$ = hash("KP" || _schemeId_ || _Round_ || _P_$_{k_{i}}$) for each corresponding round.

where:

- _schemeId_ is a 16-bit, little-endian constant integer with value of 0

- _Round_ is a 64-bit, little-endian integer representing the start round for which the key _P_$_{k_{i}}$ is valid.
  The key would be valid for all rounds in [_Round_,...,_Round_ + _keyLifeTime_ - 1]

- _P_$_{k_{i}}$ is a 14,344-bit string representing the Falcon ephemeral public key.

- hash: is the SUBSET-SUM hash function as defined in the [Algorand Cryptographic Primitives Specification](Crypto.md)


#### Signatures

A Signature in the scheme consist of the following elements: 

- _Signature_ is a signature generated by Falcon scheme. 

- _VerifyingKey_ is a Falcon ephemeral public key. 

- _VectorIndex_ is an index of the ephemeral public key leaf in the vector commitment.

- _Proof_ is an array of size _n_ (_n_ $\leq$ 16  Since the number of keys is bounded) which contains hash results (_digest_$_{0}$,...,_digest_$_{n}$). Proof is used as a Merkle verification path on the ephemeral public key. 
When the committer gives a depth-_n_ authentication path for index _VectorIndex_, the verifier must write _VectorIndex_ as _n_-bit number and read it from MSB to LSB to determine the leaf-to-root path. 


When signature is to be hashed, it must be serialized into a binary string according to the following format:

_SignatureBitString_ = (_schemeId_ || _Signature_ || _VerifyingKey_ || _VectorIndex_ || _Proof_)

where:

- _schemeId_ is a 16-bit, little-endian constant integer with value of 0

- _Signature_ is a 12,304-bit string representing a Falcon signature in a CT format.

- _VerifyingKey_ is a 14,344-bit string

- _VectorIndex_ is a 64-bit, little-endian integer

- _Proof_ is constructed in the following way:


if _n_ = 16:

- _Proof_ = (_n_ || _digest_$_{0}$ || ... || _digest_$_{15}$)

else:

- _Proof_ = (_n_ || _zeroDigest_$_{0}$ || ... || _zeroDigest_$_{d-1}$ || _digest_$_{0}$ || ... || _digest_$_{n-1}$)

where:

- _n_ is a 8-bit string.

- _digest_$_{i}$ is a 512-bit string representing sumhash result.

- _zeroDigest_ is a constant 512-bit string with the value 0.

- _d_ = 16 - _n_


#### Verifying Signatures

A signature _s_ for a message _m_ at round _r_ is valid under the public commitment _pk_ and _keyLifeTime_ if:

  - The falcon signature _s.Signature_ is valid for the message _m_ under the public key _s.VerifyingKey_

  - The proof _s.Proof_ is a valid vector commitment proof for the entry _leaf_ at index _s.VectorIndex_ with respect to 
  the vector commitment root _pk_ where:
  
    - _leaf_ := "KP" || _schemeId_ || _Round_ || _s.VerifyingKey_
    
    - _Round_ :=  _r_ - ( _r_ % _keyLifeTime_)