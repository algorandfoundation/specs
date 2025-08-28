# SHA512

Algorand uses the [SHA-512 algorithm](https://datatracker.ietf.org/doc/html/rfc4634)
to strengthen post-quantum security by increasing collision resistance against Grover's
algorithm.

In Algorand, the SHA-512 algorithm is used to:

- Compute an additional hash of the previous _Light Block Header_ (`prev512`) (see Ledger [normative
specification](../ledger/ledger-block.md#previous-hash)),

- Generate an additional commitment (`txn512`) of the transactions included in the
block (_payset_) (see Ledger [normative specification](../ledger/ledger-block.md#transaction-commitments)).