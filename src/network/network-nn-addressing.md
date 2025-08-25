$$
\newcommand \WS {\mathrm{WS}}
\newcommand \PtoP {\mathrm{P2P}}
\newcommand \Peer {\mathrm{Peer}}
$$

# Addressing

The following section presents how the two Algorand _network layers_ (\\( \WS \\)
and \\( \PtoP \\)) resolve _peer addressing_, to univocally identify themselves
amongst \\( \Peer \\)s, establish two-way connections, and effectively route messages
regardless of the underlying architecture.

## Websocket Addressing Scheme

The Relay Network \\( \WS \\) relies on an `ip:port` scheme to let a \\( \Peer \\)
present itself to and address other peers.

This schema is defined in the `NetAddress` parameter of the _node configuration_.

> See details in the node configuration [non-normative section](./infrastructure-overview.md#node-configuration-values).

The `PublicAddress` also can be set in the _node configuration_ to let a \\( \Peer \\)
differentiate itself from other peers, and to be used in the [identity challenges](#network-identity).

{{#include ../.include/styles.md:impl}}
> The reference implementation checks the scheme of network addresses against this
> _regex_:
>
> `^[-a-zA-Z0-9.]+:\\d+$`

{{#include ../.include/styles.md:impl}}
> Websocket network address [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/wsNetwork.go#L332).

## P2P Addressing Scheme

The Peer-to-Peer Network \\( \PtoP \\) makes use of the underlying [`libp2p`](network-nn-appendix-a.md)
library primitives for \\( \Peer \\) addressing, identification and connection.

> This section relies on the `libp2p` [specifications](https://github.com/libp2p/specs)
> and [developer documentation](https://docs.libp2p.io/concepts/fundamentals/).

In this addressing scheme, each node participating in the \\( \PtoP \\) network
holds a public and private [Ed25519](../crypto/crypto.md#ed25519) key pair. The private
key is kept secret, and the public key is shared to all participants.

The _peer identity_ (`PeerID`) is a _unique_ reference to a specific \\( \Peer \\)
within the \\( \PtoP \\) network, serving as a unique identifier for each \\( \Peer \\).
It is linked to the public key of the participant, as it is derived as [hash](../crypto/crypto.md#hash-functions)
of said key, encoded in `base58`.

> See `libp2p` [PeerID specification](https://github.com/libp2p/specs/blob/master/peer-ids/peer-ids.md)
> for details on how these are constructed and encoded.

The `PeerID` are visible and may be incorporated into [multiaddresses](#multiaddress)
to route messages.

\\( \Peer \\) private keys are used to sign all messages and are kept as secrets
by the node.

{{#include ../.include/styles.md:impl}}
> `PeerID` are cast-able to `str` type and are used as plain strings in packages
> where importing `libp2p` packages may not be needed.

{{#include ../.include/styles.md:impl}}
> A `GetPrivKey` [function](https://github.com/algorand/go-algorand/blob/eff5fb40deb279ba8b2d7f25fbfa5bfe8002d422/network/p2p/peerID.go#L56)
> manages loading and creation of private keys in the \\( \PtoP \\) network. It
> prioritizes, in this order:
>
> 1. User supplied path to `privKey`,
> 1. The default path to `privKey`,
> 1. Generating a new `privKey`.

{{#include ../.include/styles.md:impl}}
> If a new private key is generated, and should be persisted, its default path is
> `"peerIDPrivKey.key"` (inside the root directory). The behavior of this lookup
> is governed by _node configuration_ values `P2PPersistPeerID` and `P2PPrivateKeyLocation`
> (see the Algorand Infrastructure [non-normative section](./infrastructure-overview.md#node-configuration-values)).

### Multiaddress

A multiaddress is a convention for encoding multiple layers of addressing information
into a single “future-proof” path structure. It allows overlay of protocols and
interoperation of many _peer addressing_ layers.

When exchanging addresses, peers send a multiaddress containing both their network
address and `PeerID`.

Regular `NetAddress` (as the scheme presented in the [previous section](#websocket-addressing-scheme))
may be easily converted into a `libp2p` formatted listen multiaddress.

Given a network address `[a]:[b]` (where `[a]` is the IP address and `[b]` is the
open port), the conversion scheme is `/ip4/[a]/tcp/[b]`.

> Refer to the `libp2p` [specifications](https://github.com/libp2p/specs/blob/master/addressing/README.md#the-p2p-multiaddr)
> for further detail on this structure.

{{#include ../.include/styles.md:example}}
> Here are some examples of syntactically valid _multiaddresses_:
>
> - `/ip4/127.0.0.1/tcp/8080`, for a multiaddress composed only of a network address
> listening to `localhost` on the port `8080`.
>
> - `/ip4/192.168.1.1/tcp/8180/p2p/Qmewz5ZHN1AAGTarRbMupNPbZRfg3p5jUGoJ3JYEatJVVk`,
> for a multiaddress composed of a network address `192.168.1.1:8180`, joined together
> with the `PeerID` equal to `Qmewz5ZHN1AAGTarRbMupNPbZRfg3p5jUGoJ3JYEatJVVk`.
>
> - `/ip4/192.255.2.8/tcp/8180/ws`, for a multiaddress composed only of a network address
> `192.255.2.8:8180` indicating that the connection is through websockets `ws`.

## Hybrid Network Addressing Scheme

The hybrid network maintains a single `IdentityTracker` entity, shared between both
network definitions (\\( \WS \\) and \\( \PtoP \\)).

Note that a `PublicAddress` must be set for hybrid nodes to operate properly.

For _peer identity_ deduplication, a signing schema involving both the \\( \PtoP \\)
private key and the \\( \WS \\) identity challenge is put in place. This is to correlate
both \\( \Peer \\) definitions and prevent it from existing in both \\( \Peer \\) lists.

> See the hybrid network [identity challenge](#hybrid-network-identity-challenge)
> for further details on this process.