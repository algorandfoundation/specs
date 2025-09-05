# Algorand Keys Specification

An Algorand node interacts with three types of cryptographic keys:

- _Root keys_, a key pair (public and private) used to control the access to a particular
account. These key pairs are also known as _Spending Keys_ (as they sign accounts’ transactions).

- _Voting keys_, a set of keys used for authentication, i.e. identify an account
in the Algorand Byzantine Fault Tolerant protocol (see [ABFT section](../abft/abft.md)).
Algorand uses a hierarchical (two-level) signature scheme that ensures [forward security](https://en.wikipedia.org/wiki/Forward_secrecy),
which will be detailed in the next section. These key pairs are also known as _Participation Keys_.

- _VRF Selection keys_, keys used for proving membership of selection (see [Cryptography primitives specification](../crypto/crypto.md)).

An _agreement vote message_ (see [Networking section](../network/network-overview.md))
is valid only when it contains a proper VRF proof (\\( y \\)) and is signed with
the correct _voting key_.
