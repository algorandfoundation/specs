---
numbersections: true
title: "Algorand Key Specification"
date: \today
abstract: >
    This document specifies the list of keys and their capabilities in Algorand.
---

Overview
========

An algorand node uses two kind of cryptographic keys:

 - _participation keys_, a set of keys used for authentication, i.e. identify an 
    account. Algorand uses a two\-level ephemeral signature scheme that 
    ensures [forward security](https://en.wikipedia.org/wiki/Forward_secrecy), 
    which will be detailed in next section. 

 - _selection credential_, key used for proving membership of selection. 

A vote is valid only if both the participation keys and the selection
credential are valid.

Participation Keys 
==================

\newcommand \KeyDilution {\mathrm{KeyDilution}}
\newcommand \Batch {\mathrm{Batch}}
\newcommand \Offset {\mathrm{Offset}}

Algorand's Two\-level Ephemeral Signature Scheme for Authentication
------------------------------------------------------------------

An ephemeral subkey is a key pair that produces one\-time signature 
for messages. It must be deleted after use to ensure forward security.
Algorand's ephemeral subkeys 
uses [Ed25519 public\-key signature system](https://ed25519.cr.yp.to/).

Algorand uses a two\-level ephemeral signature scheme.
Instead of signing voting messages directly, an algorand account uses her
master key to sign an intermediate ephemeral sub-key. 
This intemediate ephemeral sub-key signs a batch of leaf level ephemeral 
sub-keys. Hence, each intermediate ephemeral sub-key is associate with a
batch number ($\Batch$), and each leaf ephemeral sub-key is associate with a
batch number (of its parent key) and an offset ($\Offset$, denotes its offset
in current batch). A voting message is signed hierarchically: 
the master key $\rightarrow$ batch sub\-key $\rightarrow$ leaf sub-key
$\rightarrow$ voting message (more details in next sub-section: One\-time 
Signature).

After usage, an Algorand node deletes the outdated ephemeral subkeys. 
Algorand allows users to set the number of rounds that a ephemeral sub-key
can be used repeatedly, $\KeyDilution$. For example, the default $\KeyDilution$ 
value of the current consensus protocol (V17) is $10,000$. 
An algorand account can change her $\KeyDilution$ via 
key registration transactions (see 
[the ledger specification](https://github.com/algorandfoundation/specs/blob/master/dev/ledger.md)).

One\-time Signature
-------------------

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
a batch. $\OTSSBatchID$ is signed by the master key. It has the following
fields:
 
 - _SubKey Public key_ $\SubKeyPK$, the public key of this sub-key.

 - _Batch_ $\Batch$, batch number of this sub-key.

$\OTSSOffsetID$ identifies an leaf level ephemeral sub-key. $\OTSSOffsetID$
is signed with a batch sub-key. It has the following fields:

 - _SubKey Public key_ $\SubKeyPK$, the public key of this sub-key.

 - _Batch_ $\Batch$, batch number of this sub-key.

 - _Offset_ $\Offset$, offset of this sub-key in current batch.

Finally, $\OneTimeSignature$ is a cryptographic signature used in voting
messages between algorand users. It contains the following fields:

 - _Signature_ $\Sig$, a signature of message under $\PK$

 - _Public Key_ $\PK$, the public key of the message signer, 
   $\PK$ is part of a leaf level ephemeral subkey. 

 - _Old Style Signature_ $\PKSigOld$, **deprecated** field. 
  It is still in the message only for compability reason.

 - _Public Key 2_  $\PKTwo$, the public key of the current batch. 

 - _Public Key 1 Signature_ $\PKOneSig$, a signature of $\OTSSOffsetID$
   under $\PKTwo$.
 
 - _Public Key 2 Signature_ $\PKTwoSig$, a signature of $\OTSSBatchID$ under
   the master key.

Selection Credential
====================
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

To check the validity of a voting message, its selection credential
needs to be verfied. Algorand uses Verifiable Random Function (VRF) to 
generate selection credentials (more details in 
[crypto specification](https://github.com/algorandfoundation/specs/blob/master/dev/crypto.md)).

More specifically, an unverified vote ($\unauthenticatedVote$) has the
following fields:

 - _Row Vote_ $\mathrm{R}$, an inner struct contains $\Sender$, $\Round$, $\Period$, 
   $\Step$, and $\Proposal$.

 - _Unverified Credential_ $\Cred$, unverified selection credential. $\Cred$ contains 
   a single field $\mathrm{Proof}$, which is a VRF proof.

 - _Signature_ $\Sig$, one-time signature of the vote.

Once receiving an unverified vote ($\unauthenticatedVote$) from the network, 
an Algorand node verifies its selection credential by checking the validity
of the VRF Proof (in $\Cred$), the committee membership parameters that
it is conditioned on, and the voter's voting stake. 
If verified, the result of this verification is 
wrapped in a $\Credential$ struct, containing the following fields:

 - _Unverifed Credential_ $\UnauthenticatedCredential$, the unverified 
  credential from input.

 - _Weight_ $\Weight$, the weight of the vote.

 - _VRF Output_ $\VrfOut$, the cached output of VRF verification.

 - _Domain Separation Enabled_ $\DomainSeparationEnabled$, Domain separation
   flag, now must be true by the protocol.

 - _Hashable_ $\Hashable$, the original credential

And this verified credential is wrapped in a $\Vote$ struct with _Row Vote_ 
($\mathrm{R}$), _Verifid Credential_ ($\Credential$), and _Signature_ ($\Sig$).