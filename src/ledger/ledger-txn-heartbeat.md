# Heartbeat Transaction

The _heartbeat_ is a special transaction used to challenge the liveness of an _online_
account.

## Fields

A _heartbeat_ transaction additionally has the following fields:

| FIELD                        | CODEC |    TYPE     | REQUIRED |
|:-----------------------------|:-----:|:-----------:|:--------:|
| Heartbeat Address            |  `a`  |  `address`  |   Yes    |
| Heartbeat Seed               | `sd`  | `[32]bytes` |   Yes    |
| Heartbeat Vote ID            | `vid` | `[32]bytes` |   Yes    |
| Heartbeat Key Dilution       | `kd`  |  `uint64`   |   Yes    |
| Heartbeat Proof              | `prf` |  `struct`   |   Yes    |
| Heartbeat Challenge Discount |  `c`  |   `bool`    |    No    |

### Heartbeat Address

The _heartbeat address_ is an account address that this heartbeat transaction proves
liveness for.

### Heartbeat Seed

The _heartbeat seed_ is a block seed.

- It **MUST** be the block seed found in the _first valid round_ of the transaction.

### Heartbeat Vote ID

The _heartbeat vote id_ is a public key.

- It **MUST** be the current public key of the root voting key of the _heartbeat
address_’s account state.

### Heartbeat Key Dilution

The _heartbeat key dilution_ is a key dilution parameter (see [Algorand Participation
Keys specification](../keys/keys-ephemeral.md)).

- It **MUST** be the current key dilution of the _heartbeat address_’s account state.

### Heartbeat Proof

The _heartbeat proof_ **MUST** contain a valid signing of the _heartbeat seed_ using
the _heartbeat vote id_ and the _heartbeat key dilution_ using the voting signature
scheme defined in the [Algorand Participation Keys specification](../keys/keys-participation.md).

### Heartbeat Challenge Discount

The _heartbeat challenge discount_ (**OPTIONAL**) is a flag requesting the reduced fee
that a challenged account owes when responding to a challenge (see the
[Heartbeat Transaction Semantics](./ledger-txn-semantics-heartbeat.md)). It is a
request rather than an assertion: the discount is granted only if the _heartbeat
address_ is in fact under challenge, and an account willing to pay the ordinary fee
**MAY** leave it unset even while challenged.

- When set, the transaction's [_note_](./ledger-transactions.md#note),
[_lease_](./ledger-transactions.md#lease), and
[_rekey to address_](./ledger-transactions.md#rekey-to) **MUST** be empty.

## Validation

TODO

## Semantic

TODO
