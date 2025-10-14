# Heartbeat Transaction

The _heartbeat_ is a special transaction used to challenge the liveness of an _online_
account.

## Fields

A _heartbeat_ transaction additionally has the following fields:

| FIELD                  | CODEC |    TYPE     | REQUIRED |
|:-----------------------|:-----:|:-----------:|:--------:|
| Heartbeat Address      |  `a`  |  `address`  |   Yes    |
| Heartbeat Seed         | `sd`  | `[32]bytes` |   Yes    |
| Heartbeat Vote ID      | `vid` | `[32]bytes` |   Yes    |
| Heartbeat Key Dilution | `kd`  |  `uint64`   |   Yes    |
| Heartbeat Proof        | `prf` |  `struct`   |   Yes    |

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

## Validation

TODO

## Semantic

TODO
