$$
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
\newcommand \Offset {\mathrm{Offset}}
\newcommand \Batch {\mathrm{Batch}}
$$

# One-Time Signature

\\( \OTSSBatchID \\) identifies an intermediate level ephemeral sub-key of a batch
and is signed by the _voting key_’s _root key_. It has the following fields:
 
- _Sub-Key Public key_ (\\( \SubKeyPK \\)), the public key of this sub-key.

- _Batch_ (\\( \Batch \\)), batch number of this sub-key.

The \\( \OTSSOffsetID \\) identifies a leaf-level ephemeral sub-key and is signed
with a batch sub-key. It has the following fields:

- _Sub-Key Public key_ (\\( \SubKeyPK \\)), the public key of this sub-key.

- _Batch_ (\\( \Batch \\)), batch number of this sub-key.

- _Offset_ (\\( \Offset \\)), offset of this sub-key in current batch.

Finally, \\( \OneTimeSignature \\) is a cryptographic signature used in voting
messages between Algorand players. It contains the following fields:

- _Signature_ (\\( \Sig \\)), a signature of message under \\( \PK \\)

- _Public Key_ (\\( \PK \\)), the public key of the message signer, is part of a
leaf-level ephemeral sub-key. 

- _Public Key 2_ (\\( \PKTwo \\)), the public key of the current batch. 

- _Public Key 1 Signature_ (\\( \PKOneSig \\)), a signature of \\( \OTSSOffsetID \\)
under \\( \PKTwo \\).
 
- _Public Key 2 Signature_ (\\( \PKTwoSig \\)), a signature of \\( \OTSSBatchID \\)
under the _voting keys_.

> The _Old Style Signature_ (\\( \PKSigOld \\)) is **deprecated**, still included
> in the message only for compatibility reasons.

{{#include ../.include/styles.md:impl}}
> One-Time Signature [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/crypto/onetimesig.go#L36).