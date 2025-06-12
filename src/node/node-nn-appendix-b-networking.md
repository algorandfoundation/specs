# 🌐 Networking

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `GossipFanout` |      `4`      |           0           |            0            |

**Description:**

Defines the maximum number of peers the node will establish outgoing connections
with. The node will connect to fewer peers if the available peer list is smaller
than this value. The node does not create multiple outgoing connections to the same
peer.

> For further details, refer to the Network [non-normative specification](../network/network-overview.md).

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `NetAddress`   | Empty string  |           0           |            0            |

**Description:**

Specifies the `IP` address and/or the `port` where the node listens for incoming connections.
Leaving this field blank disables incoming connections. The value can be an `IP`,
`IP:port` pair, or just a `:port`. The node defaults to port `4160` if no port is specified.
Setting the port to `:0` allows the system to assign an available port automatically.

{{#include ../.include/styles.md:example}}
> `127.0.0.1:0` binds the node to _any available port_ on `localhost`.

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `PublicAddress` | Empty string  |           0           |            0            |

**Description:**

Defines the public address that the node advertises to other nodes for incoming connections.
For `mainnet` Relay Nodes, this should include the full `SRV` host name and the publicly
accessible port number. A valid entry helps prevent self-gossip and is used for
identity exchange, ensuring redundant connections are de-duplicated.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `TLSCertFile`  | Empty string  |           0           |            0            |

**Description:**

The certificate file used for the [Relay Network](../network/network-nn-definitions-ws.md)
if provided.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `TLSKeyFile`   | Empty string  |           0           |            0            |

**Description:**

The key file used for the [Relay network](../network/network-nn-definitions-ws.md) if provided.

---

| Parameter Name   |                                           Default Value                                            | Introduced in Version |           Last Updated in Version            |
|------------------|:--------------------------------------------------------------------------------------------------:|:---------------------:|:--------------------------------------------:|
| `DNSBootstrapID` | `<network>.algorand.network?backup=<network>.algorand.net&dedup=<name>.algorand-<network>.(network |         net)`         | 0 (default was `<network>.algorand.network`) | 28 |

**Description:**

Specifies the names of a set of DNS `SRV` records that identify the set of nodes available
to connect to.

> For further information on the specifics of this value’s syntax, refer to DNS
> bootstrap [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/config/dnsbootstrap.go).

---

| Parameter Name               | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `FallbackDNSResolverAddress` | Empty string  |           0           |            0            |

**Description:**

Defines the fallback DNS resolver address used if the system resolver fails to retrieve
`SRV` records.

---

| Parameter Name                 | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `UseXForwardedForAddressField` | Empty string  |           0           |            0            |

**Description:**

Indicates whether the node should use the `X-Forwarded-For` HTTP Header when determining
the source of a connection. Unless the proxy vendor provides another header field,
it should be set to the string `X-Forwarded-For`.

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `ForceRelayMessages` | Empty string  |           0           |            0            |

**Description:**

Indicates whether the Network library should relay messages even if no `NetAddress`
is specified.

---

| Parameter Name     | Default Value | Introduced in Version | Last Updated in Version |
|--------------------|:-------------:|:---------------------:|:-----------------------:|
| `DNSSecurityFlags` |      `9`      |  6 (default was `1`)  |           34            |

**Description:**

Instructs [`algod`](API-overview.md#algorand-daemon) validating DNS responses.

Possible flag values are:

- `0`: Disabled.
- `1`: Validate `SRV` response.
- `2`: Validate relay names for addresses resolution.
- `4`: Validate telemetry and metrics names for addresses resolution.
- `8`: Validate `TXT` response.

---

| Parameter Name      | Default Value | Introduced in Version | Last Updated in Version |
|---------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnablePingHandler` |    `true`     |           6           |            6            |

**Description:**

Controls whether the gossip node responds to ping messages with a pong message.

---

| Parameter Name           | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------|:-------------:|:---------------------:|:-----------------------:|
| `NetworkProtocolVersion` | Empty string  |           6           |            6            |

**Description:**

Overrides the Network protocol version (if present).

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableGossipService` |    `true`     |          33           |           33            |

**Description:**

Enables the gossip network HTTP WebSockets endpoint. Its functionality depends on
`NetAddress,` which must also be provided. This service is required to serve gossip
traffic.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableLedgerService` |    `false`    |           7           |            7            |

**Description:**

Enables the [Ledger](../ledger/ledger-overview.md) serving service. This functionality
depends on `NetAddress`, which must also be provided. This service is required for
the [Fast Catchup](./node-nn-sync.md#fast-catchup).

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableBlockService` |    `false`    |           7           |            7            |

**Description:**

Controls whether to enable the [block](../ledger/ledger.md#blocks) serving service.
This functionality depends on `NetAddress`, which must also be provided. This service
is required for the [Fast Catchup](./node-nn-sync.md#fast-catchup).

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableGossipBlockService` |    `true`     |           8           |            8            |

**Description:**

Determines whether the node serves blocks to peers over the gossip network. This
service is essential for Relay Nodes and other nodes to request and receive block
data, especially during [Fast Catchup](./node-nn-sync.md#fast-catchup). For this
to work, the node must have a `NetAddress` set, allowing it to accept incoming connections.

---

| Parameter Name      | Default Value | Introduced in Version | Last Updated in Version |
|---------------------|:-------------:|:---------------------:|:-----------------------:|
| `DisableNetworking` |    `false`    |          16           |           16            |

**Description:**

Disables all the incoming and outgoing communication a node may perform. This is
useful when we have a _single-node Private Network_, where no other nodes need to
be communicated with. Features like [Fast Catchup](./node-nn-sync.md#fast-catchup)
would be completely non-operational, rendering many node inner systems useless.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableP2P`    |    `false`    |          31           |           31            |

**Description:**

Enables the [Peer-to-Peer Network](../network/network-nn-definitions-p2p.md). When
both `EnableP2P` and `EnableP2PHybridMode` are set, `EnableP2PHybridMode` takes
precedence.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableP2PHybridMode` |    `false`    |          34           |           34            |

**Description:**

Turns on both [Relay and Peer-to-Peer (Hybrid) Networking](../network/network-nn-definitions-hybrid.md).
Enabling this setting also requires `PublicAddress` to be set.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `P2PHybridNetAddress` | Empty string  |          31           |           31            |

**Description:**

Sets the listen address used for P2P networking, if [Hybrid Network](../network/network-nn-definitions-hybrid.md)
is set.

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableDHTProviders` |    `false`    |          34           |           34            |

**Description:**

Enables the _Distributed Hash Table_ (DHT). This feature allows the node to participate
in a DHT-based network that advertises its available capabilities to other nodes.

> For further details, refer to the Algorand P2P Network capabilities [non-normative specification](../network/network-nn-definitions-p2p.md).

---

| Parameter Name     | Default Value | Introduced in Version | Last Updated in Version |
|--------------------|:-------------:|:---------------------:|:-----------------------:|
| `P2PPersistPeerID` |    `false`    |          29           |           29            |

**Description:**

Writes the private key used for the node’s PeerID to the `P2PPrivateKeyLocation`.
This is only used when `EnableP2P` is true. If the location flag is not specified,
it uses the default location.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `P2PPrivateKeyLocation` | Empty string  |          29           |           29            |

**Description:**

Allows the user to specify a custom path to the _private key_ used for the node’s
PeerID. The private key provided must be an [Ed25519](../crypto.md#ed25519) private
key. This is only used when `EnableP2P` is set to `true`. If this parameter is not
set, it uses the default location.

---