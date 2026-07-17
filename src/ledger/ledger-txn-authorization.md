$$
\newcommand \Hash {\mathrm{Hash}}
\newcommand \pk {\mathrm{pk}}
\newcommand \MSigPrefix {\texttt{MultisigAddr}}
\newcommand \PQAPrefix {\texttt{PQA}}
\newcommand \PQProgramPrefix {\texttt{PQProgram}}
\newcommand \Tx {\mathrm{Tx}}
\newcommand \Fee {\mathrm{fee}}
\newcommand \MinTxnFee {T_{\Fee,\min}}
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

- Exactly one of a _signature_ (field `sig`), _multisignature_ (field `msig`),
_logic signature_ (field `lsig`), or _post-quantum signature_ (field `pqsig`).

The _authorizer address_, a 32-byte address, determines against what to verify the
`sig` / `msig` / `lsig` / `pqsig`, as described below.

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

  - The logic `l` which is versioned bytecode (see [AVM specifications](../avm/avm.md)).

  - An **OPTIONAL** single signature `sig` of 64-bytes valid from the authorizer
  address of the transaction which has signed the bytes in `l`.

  - An **OPTIONAL** multisignature `lmsig` from the authorizer address of the transaction
  over the bytes of the authorizer address and the bytes in `l`.

  - An **OPTIONAL** post-quantum signature `pqsig` from the authorizer address of
  the transaction over the bytes of the authorizer address and the bytes in `l`,
  as described in the [Logic Signature Delegation](#logic-signature-delegation)
  section.

  - An **OPTIONAL** array of byte strings `arg` which are arguments supplied to the
  program in `l` (`arg` bytes are not covered by `sig`, `msig`, or `pqsig`).

The logic signature is valid if exactly one of `sig`, `msig`, or `pqsig` is a valid
signature of the program by the authorizer address of the transaction, or if none
of them is set and the hash of the program is equal to the authorizer address.

Also the program **MUST** execute and finish with a single non-zero value on the
AVM stack (see [AVM specifications](../avm/avm.md) for details on program execution
semantics).

A valid _post-quantum signature_ (`pqsig`) is an object which derives the _authorizer
address_ and signs the transaction with a post-quantum signature scheme, as described
in the [Post-Quantum Signature](#post-quantum-signature) section.

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

## Post-Quantum Signature

A post-quantum signature authorizes a transaction with a post-quantum digital signature
scheme, either directly (`SignedTxn` field `pqsig`) or by delegating a logic signature
(`lsig` field `pqsig`, see [Logic Signature Delegation](#logic-signature-delegation)).

The `pqsig` object contains the following fields:

- The scheme identifier `sch`, a 2-byte string identifying the post-quantum signature
scheme. The supported values are:

  - `f1`, denoting [deterministic FALCON-1024](../crypto/crypto-falcon.md).

- The address salt `slt`, a 1-byte unsigned integer.

- The canonical public key `pk` of the scheme, a byte string.

- The canonical signature `sig` of the scheme, a non-empty byte string. For scheme
`f1`, it must be a FALCON-1024 signature in compressed format.

The _post-quantum address_ of a scheme identifier, salt, and public key is derived
by hashing their concatenation with the domain separation prefix \\( \PQAPrefix \\):

$$
\mathrm{PQAddr} = \Hash(\PQAPrefix, \mathtt{sch}, \mathtt{slt}, \pk)
$$

> The salt takes part in the address derivation, so one public key derives up to
> \\( 256 \\) distinct addresses. This allows clients to select, by rejection sampling
> over the salt, an address which is not a valid Ed25519 public key, so that no
> Ed25519 signature may ever authorize the account. This property is not enforced
> by consensus.

A post-quantum signature is valid if all the following conditions hold:

1. The scheme identifier `sch` is supported;

1. The post-quantum address derived from `sch`, `slt`, and `pk` is equal to the
_authorizer address_ of the transaction;

1. The signature `sig` is valid for the message \\( \Hash(\Tx) \\), the 32-byte
[transaction identifier](./ledger-transactions.md), under the public key `pk`,
according to the scheme denoted by `sch`.

> Note that, unlike `sig` and `msig`, which sign the domain-separated encoded
> transaction, the message signed by a `f1` signature is the 32-byte _hash_ of the
> domain-separated encoded transaction.

### Logic Signature Delegation

A post-quantum account **MAY** delegate a [logic signature](../avm/avm-mode-logic-signatures.md#delegated-signature-mode):
the `lsig` object carries a `pqsig` object, as defined above, in place of an Ed25519
signature or multisignature delegation.

A post-quantum logic signature delegation is valid if all the following conditions
hold:

1. The scheme identifier `sch` is supported;

1. The post-quantum address derived from `sch`, `slt`, and `pk` is equal to the
_authorizer address_ of the transaction;

1. The signature `sig` is valid for the message \\( \Hash(\PQProgramPrefix, A, \mathtt{l}) \\),
the 32-byte hash of the _authorizer address_ \\( A \\) concatenated with the program
bytecode `l` (with domain separation prefix \\( \PQProgramPrefix \\)), under the
public key `pk`, according to the scheme denoted by `sch`.

> The signed message binds the delegating account address: a delegation produced
> for one account is not valid for any other account, in particular for a different
> salted address derived from the same public key.

### Fee Surcharge

A transaction authorized with a post-quantum signature, either directly or through
a [post-quantum delegated logic signature](#logic-signature-delegation), requires
an additional fee, given by the scheme _fee contribution_:

- `f1`: \\( 2 \times \MinTxnFee \\).

This contribution adds to the [minimum fee](./ledger-txn-groups.md) otherwise required
by the transaction or by its transaction group, if any.
