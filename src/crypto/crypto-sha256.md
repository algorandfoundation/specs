# SHA256

Algorand uses [SHA-256 algorithm](https://datatracker.ietf.org/doc/html/rfc4634)
to allow verification of Algorand's state and transactions on environments where
SHA-512/256 is not supported.

In Algorand, the SHA-256 algorithm is used to:

- Hash the _Light Block Header_ (see Ledger [normative specification](../ledger/ledger-overview.md)),

- Generate an additional commitment of the _payset_ included in the block.