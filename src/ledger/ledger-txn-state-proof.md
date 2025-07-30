$$
\newcommand \Proven {\mathrm{Proven}}
\newcommand \Total {\mathrm{Total}}
\newcommand \W {\mathrm{Weight}}
\newcommand \StateProof {\mathrm{SP}}
\newcommand \StateProofInterval {\delta_\StateProof}
\newcommand \StateProofWeightThreshold {f_\StateProof}
\newcommand \Offset {\mathrm{Offset}}
$$

# State Proof Transaction

The _state proof_ is a special transaction used to disseminate and store [State
Proofs]().

## Fields

A _state proof_ transaction additionally has the following fields:

| FIELD                  |  CODEC   |   TYPE   | REQUIRED |
|:-----------------------|:--------:|:--------:|:--------:|
| State Proof Type       | `sptype` | `uint64` |   Yes    |
| State Proof            |   `sp`   | `struct` |   Yes    |
| Message                | `spmsg`  | `struct` |   Yes    |
| State Proof Last Round | `sprnd`  | `uint64` |   Yes    |

### State Proof Type

The _state proof type_ identifies the type of the State Proof.

> Currently, always \\( 0 \\).

### State Proof

The _state proof_ structure as defined in the [State Proof specification](../crypto.md#state-proof-format).

### Message

The _message_ is a structure that composes the State Proof message, whose hash is
being attested to by the State Proof.

The _message_ structure is defined in the [State Proof message section](./ledger-state-proofs.md#message).

## Semantic

TODO

## Validation

In order for a _state proof_ transaction to be valid, the following conditions **MUST**
be meet:

- The _transaction type_ **MUST** be `stpf`.

- The _sender_ **MUST** be equal to a special address, which is the hash of the domain-separation
prefix `SpecialAddr` (see the corresponding section in the [Algorand Cryptographic
Primitive Specification](./crypto.md#domain-separation)) with the string constant
`StateProofSender`.

- The _fee_ **MUST BE** \\( 0 \\).

- The _lease_ **MUST BE** omitted.

- The _group_ **MUST BE** omitted. 

- The _rekey to_ **MUST BE** omitted.

- The _note_ **MUST BE** omitted.

- The transaction **MUST NOT** have any signature.

- The _state proof round_ (defined in the _message_ structure) **MUST** be exactly
equal to the next expected State Proof round in the _block header_, as described in
the [State Proof tracking section](./ledger-state-proofs.md#tracking).

- The state proof verification code **MUST** return `true` (see [State Proof validity](../crypto/stateproofvalidty.md)),
given the State Proof _message_ and the State Proof _transaction fields_.

In addition, the verifier should also be given a trusted commitment to the _participant
array_ and \\( \Proven\W \\) value. The trusted data **SHOULD** be taken from the
Ledger at the relevant round.

To encourage the formation of shorter State Proof, the rule for validity of _state
proof_ transactions is dependent on the _first valid round_ in the transaction.

In particular, the signed weight of a State Proof **MUST** be:

- Equal to the _total online stake_, \\( \Total\W \\), if the _first valid round_
on the transaction is no greater than the _state proof round_ (defined in the _message_
structure) plus \\( \frac{\StateProofInterval}{2} \\).

- At least \\( \Proven\W + (\Total\W - \Proven\W) \times \frac{\Offset}{\frac{\StateProofInterval}{2}} \\),
if the _first valid round_ on the transaction is the _state proof round_ (defined
in the _message_ structure) plus \\( \frac{\StateProofInterval}{2} + \Offset \\).

- At least the minimum weight being proven by the proof, \\( \Proven\W \\), if the
_first valid round_ on the transaction is no less than _state proof round_ (defined
in the _message_ structure) plus \\( \StateProofInterval \\).

Where \\( \Proven\W = \frac{\Total\W \times \StateProofWeightThreshold}{2^{32}} \\)

When a _state proof_ transaction is applied to the state, the next expected State
Proof round for that type of State Proof is incremented by \\( \StateProofInterval \\).

> A node should be able to verify a _state proof_ transaction at any time, even if
> the transaction _first valid round_ is greater than the next expected State Proof
> round in the _block header_.
