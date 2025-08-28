# SHA256

Algorand uses [SHA-256 algorithm](https://datatracker.ietf.org/doc/html/rfc4634)
to allow verification of Algorand's state and transactions on environments where
SHA-512/256 is not supported.

In Algorand, the SHA-256 algorithm is used to:

- Compute the hash of the previous _Light Block Header_ (`prev`) (see Ledger [normative
specification](../ledger/ledger-block.md#previous-hash));

- Generate an additional commitment (`txn256`) of the transactions included in the
block (_payset_) (see Ledger [normative specification](../ledger/ledger-block.md#transaction-commitments)).