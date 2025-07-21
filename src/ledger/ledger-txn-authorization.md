$$
\newcommand \Hash {\mathrm{Hash}}
\newcommand \pk {\mathrm{pk}}
\newcommand \MSigPrefix {\texttt{MultisigAddr}}
$$

# Authorization and Signatures

Transactions are not valid unless they are somehow authorized by the _sender_ account
(for example, with a signature).

The authorization information is not considered part of the transaction and does
not affect the _transaction ID_ (`TXID`).

Rather, when serializing a transaction for submitting to a node or including in
a block, the transaction and its authorization appear together in a structure called
a `SignedTxn`.

The `SignedTxn` struct contains:

- The transaction (in msgpack field `txn`);

- An **OPTIONAL** _authorizer address_ (field `sgnr`);

- Exactly one of a _signature_ (field `sig`), _multisignature_ (field `msig`), or
_logic signature_ (field `lsig`).

The _authorizer address_, a 32-byte address, determines against what to verify the
`sig` / `msig` / `lsig`, as described below.

If the `sgnr` field is omitted (or zero), then the _authorizer address_ defaults
to the transaction _sender_ address.

At the time the transaction is applied to the Ledger, the authorizer address **MUST**
match the transaction _sender_ account's spending key (or the _sender_ address, if
the account's spending key is zero). If it does not match, then the transaction was
improperly authorized and is invalid.

## Signatures

- A valid _signature_ (`sig`) is a (64-byte) valid [Ed25519 signature](../crypto/crypto-ed25519.md)
of the transaction (encoded in canonical msgpack and with [domain separation prefix](../crypto/crypto-domain-separators.md)
`TX`) where the public key is the _authorizer address_ (interpreted as an Ed25519
public key).

- A valid _multisignature_ (`msig`) is an object containing the following fields and
which hashes to the _authorizer address_ as described in the [Multisignature](#multisignature)
section:

  - The `subsig` array of subsignatures, each consisting of a signer address and a
  64-byte signature of the transaction. Note that transaction signed by a multisignature
  account **MUST** contain all signer's addresses in the `subsig` array even if the
  transaction has not been signed by that address.

  - The threshold `thr` that is a minimum number of **REQUIRED** signatures.

  - The multisignature version `v` (current value is \\( 1 \\)).

- A valid _logic signature_ (`lsig`) is an object containing the following fields:

  - The logic `l` which is versioned bytecode (see [AVM specifications]()).

  - An **OPTIONAL** single signature `sig` of 64-bytes valid from the authorizer
  address of the transaction which has signed the bytes in `l`.

  - An **OPTIONAL** multisignature `msig` from the authorizer address of the transaction
  over the bytes in `l`.

  - An **OPTIONAL** array of byte strings `arg` which are arguments supplied to the
  program in `l` (`arg` bytes are not covered by `sig` or `msig`).

The logic signature is valid if exactly one of `sig` or `msig` is a valid signature
of the program by the authorizer address of the transaction, or if neither `sig`
nor `msig` is set and the hash of the program is equal to the authorizer address.

Also the program **MUST** execute and finish with a single non-zero value on the
AVM stack (see [AVM specifications]() for details on program execution semantics).

## Multisignature

Multisignature term describes a special multisignature address, signing and validation
procedures.

In contrast with a single signature address that may be understood as a public key,
multisignature address is a hash of a constant string identifier for:

- The \\( \MSigPrefix \\) prefix,

- A version \\( v \\),

- The multisignature authorization threshold \\( t \\),

- All \\( n \\) addresses (\\( \pk \\)) used for multisignature address creation.

$$
\mathrm{MSig} = \Hash(\MSigPrefix, v, t, \pk_1, \ldots \pk_n)
$$

One address **MAY** be specified multiple times in multisignature address creation.
In this case, every occurrence is counted independently in validation.

> The repetition of the same address in the multisignature defines the "weight" of
> the address.

The multisignature validation process checks that:

1. All non-empty signatures are valid;

1. The valid signatures count is not less than the threshold.

Validation fails if any of the signatures is invalid, even if the count of all remaining
correct signatures is greater or equals than the threshold.