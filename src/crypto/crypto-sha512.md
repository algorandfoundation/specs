# SHA512/256

Algorand uses the [SHA-512/256 algorithm](https://doi.org/10.6028/NIST.FIPS.180-4)
as its primary cryptographic hash function.

In Algorand, the SHA-512/256 algorithm is used to:

- Commit to data for signing and for the [Byzantine Fault Tolerance protocol](../abft/abft-overview.md),

- Rerandomize its [random seed](../abft/abft-messages-seed.md).
