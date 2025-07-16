# FALCON

Algorand uses a [deterministic](https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/falcon-deterministic.pdf)
version of [FALCON lattice-based signature scheme](https://falcon-sign.info/falcon.pdf).

FALCON is _quantum-resilient_ and a _SNARK-friendly_ digital signature scheme used
to sign in State Proofs.

FALCON signatures contain a _salt version_. Algorand only accepts signatures with
a salt version equal to `0`.

The library defines the following sizes:

| Component              |               Size (bytes)                |
|------------------------|:-----------------------------------------:|
| Public Key             |               \\( 1793 \\)                |
| Private Key            |               \\( 2305 \\)                |
| Signature - CT Format  |               \\( 1538 \\)                |
| Signature - Compressed | Variable, up to a maximum of \\( 1423 \\) |

Algorand uses a _random seed_ of \\( 48 \\) bytes for FALCON key generation.
