# FALCON

Algorand uses a [deterministic](../../_archive/dev/cryptographic-specs/falcon-deterministic.pdf)
version of [FALCON lattice-based signature scheme](https://falcon-sign.info/falcon.pdf).

FALCON is _quantum-resilient_ and a _SNARK-friendly_ digital signature scheme used
to sign in State Proofs and to authorize transactions from post-quantum accounts
(scheme identifier `f1`, see
[Authorization and Signatures](../ledger/ledger-txn-authorization.md#post-quantum-signature)).

FALCON signatures contain a _salt version_. Algorand only accepts signatures with
a salt version equal to `0`.

The library defines the following sizes:

| Component              |               Size (bytes)                |
|------------------------|:-----------------------------------------:|
| Public Key             |               \\( 1793 \\)                |
| Private Key            |               \\( 2305 \\)                |
| Signature - CT Format  |               \\( 1538 \\)                |
| Signature - Compressed | Variable, up to a maximum of \\( 1423 \\) |
