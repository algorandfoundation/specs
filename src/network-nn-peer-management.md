$$
\newcommand \WS {\mathrm{WS}}
\newcommand \PtoP {\mathrm{P2P}}
$$

# Peer Management

The node’s _peer discovery_ is based on either:

- A `Phonebook`, for the Relay Network \\( \WS \\), with initial addresses of
relay nodes from the Algorand service record (`SRV`),

- A `PeerStore`, for the Peer-to-Peer Network \\( \PtoP \\).

{{#include ./.include/styles.md:example}}
> For the Algorand MainNet `Phonebook` bootstrapping, the DNS is `mainnet.algorand.network`
> and the service record is `algobootstrap`. The MainNet SRV can be queried with:
>
> ```shell
> dig _algobootstrap._tcp.mainnet.algorand.network SRV
> ```

Both tracks `addressData`, which contains:

- `retryAfter`, the time to wait before retrying to connect to the address,

- `recentConnectionTimes`, the log of connection times used to observe the maximum
connections to the address in a given time window,

- `networkNames`, lists the networks to which the given address belongs,

- `role`, is the role that this address serves (`relay` or `archival`),

- `persistent`, set to `true` for peers whose record should not be removed from
the peer container.

The `Phonebook` tracks rate-limiting info and the `addressData` for each address. 

The `PeerStore` works as a union between both `Peerstore` (tracks peers' information)
and a `CertifiedAddrBook` (adds specific functionalities to the `addrBook` in order to allow for storage, retrieval, update and deletion of self-certified peer records; records signed by the peer containing their address and an associated lifetime `ttl` after which they expire) from `libp2p`.

{{#include ./.include/styles.md:impl}}
> - `Phonebook` [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/phonebook/phonebook.go#L107-L115),
> - `PeerStore` [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/p2p/peerstore/peerstore.go#L41-L71),
> - `addressData` [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/phonebook/phonebook.go#L77-L93).