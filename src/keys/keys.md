# Algorand Keys Specification

An Algorand node interacts with three types of cryptographic material:

- _Root keys_, the authorization material used to control the access to a particular
account: a single key pair (such as Ed25519 or a post-quantum scheme), a multisignature
composition of key pairs, or a logic signature program. Root keys are also known as
_Spending Keys_ (as they authorize accounts’ transactions).

- _Voting keys_, a set of keys used for authentication, i.e. identify an account
in the Algorand Byzantine Fault Tolerant protocol (see [ABFT section](../abft/abft.md)).
Algorand uses a hierarchical (two-level) signature scheme that ensures [forward security](https://en.wikipedia.org/wiki/Forward_secrecy),
which will be detailed in the next section. These key pairs are also known as _Participation Keys_.

- _VRF Selection keys_, keys used for proving membership of selection (see [Cryptography primitives specification](../crypto/crypto.md)).

An _agreement vote message_ (see [Networking section](../network/network-overview.md))
is valid only when it contains a proper VRF proof (\\( y \\)) and is signed with
the correct _voting key_.
