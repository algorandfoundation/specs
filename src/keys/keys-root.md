# Root Keys

Root keys are used to identify ownership of an account. An Algorand node only interacts with
the public key of a root key. The public key of a root key is also used as the account
address. Root keys are used to sign transaction messages as well as delegating the
voting authentication using _voting keys_, unless that specific account was rekeyed. A rekeyed
account would use the rekeyed key in lieu of the root key.

A relationship between a _root key_ and _voting keys_ is established when accounts
_register_ their participation in the agreement protocol.

> For further details on the key registration (`keyreg`) process, refer to Ledger
> [specification](../ledger/ledger-transactions.md).