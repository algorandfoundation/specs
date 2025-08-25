# 📡 Peer & Connection Management

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `MaxConnectionsPerIP` |      `8`      | 3 (default was `30`)  |           35            |

**Description:**

Defines the maximum number of connections allowed per `IP` address.

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `IncomingConnectionsLimit` |    `2400`     | 0 (default was `-1`)  |           27            |

**Description:**

A non-negative number that specifies the maximum incoming connections for the gossip
protocol configured in `NetAddress`. A value of `0` means no connections allowed.

> Estimating 1.5 MB per incoming connection.

---

| Parameter Name                      | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `P2PHybridIncomingConnectionsLimit` |    `1200`     |          34           |           34            |

**Description:**

Used as `IncomingConnectionsLimit` for P2P connections in [Hybrid Network](../network/network-nn-definitions-hybrid.md).
For pure [P2P Network](../network/network-nn-definitions-p2p.md) the field `IncomingConnectionsLimit`
is used instead.

---

| Parameter Name              | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `BroadcastConnectionsLimit` |     `-1`      |           4           |            4            |

**Description:**

Defines the maximum number of peer connections that will receive broadcast (gossip)
messages from this node.

Succinctly, it works in the following way:

- If a node has more connections than the specified limit, it prioritizes broadcasting
to peers in the following order:
    1. Outgoing connections: Peers a node actively connects to.
    2. Peers with higher stake: Determined by the amount of ALGO held, as indicated
       by their [participation key](../partkey.md#voting-keys-).

- Special values:
    - `0`: Disables all outgoing broadcast messages, including transaction broadcasts to peers.
    - `-1`: No limit on the number of connections receiving broadcasts (default setting).

> For further details, refer to the Algorand Network [non-normative specification](../network/network-overview.md).

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `AnnounceParticipationKey` |    `true`     |           4           |            4            |

**Description:**

Indicates if this node should announce its [participation key](../partkey.md#voting-keys-)
with the largest stake to its peers. In case of a _DoS_ attack, this allows peers
to prioritize connections.

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `PriorityPeers` | Empty string  |           4           |            4            |

**Description:**

Specifies peer `IP` addresses that should always get outgoing broadcast messages from\
this node.

---

| Parameter Name                 | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `ConnectionsRateLimitingCount` |     `60`      |           4           |            4            |

**Description:**

Used with `ConnectionsRateLimitingWindowSeconds` to determine whether a connection
request should be accepted. The gossip network examines all the incoming requests
in the past `ConnectionsRateLimitingWindowSeconds` seconds that share the same origin.
If the total count exceeds this value, the connection is refused.

---

| Parameter Name                         | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `ConnectionsRateLimitingWindowSeconds` |      `1`      |           4           |            4            |

**Description:**

Used with `ConnectionsRateLimitingCount` to determine whether a connection request
should be accepted. Providing a zero value in this variable disables the connection
_rate limiting_.

---

| Parameter Name                        | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `DisableOutgoingConnectionThrottling` |    `false`    |           5           |            5            |

**Description:**

Disables _connection throttling_ of the network library, which allows the network
library to continuously disconnect Relay Nodes based on their relative (and absolute)
performance.

---

| Parameter Name                        | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `DisableLocalhostConnectionRateLimit` |    `true`     |          16           |           16            |

**Description:**

Controls whether the incoming _connection rate limit_ applies to connections originating
from the local machine. Setting this to `true` allows this node to create a large
local-machine network that won’t trip the incoming connection limit observed by
Relay Nodes.

---