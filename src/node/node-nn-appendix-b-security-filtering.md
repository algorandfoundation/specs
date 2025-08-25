# 🛡️ Security & Filtering

---

| Parameter Name                     | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `IncomingMessageFilterBucketCount` |      `5`      |           0           |            0            |

**Description:**

Specifies the number of hash buckets used to filter and manage incoming messages.
When a [message is received](../network/network-overview.md), the node computes
its hash. The hash is then assigned to one of the available buckets based on its
value. Each bucket holds a set of message hashes, allowing the node to quickly check
if it has already processed a message and filter out duplicates.

---

| Parameter Name                    | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `IncomingMessageFilterBucketSize` |     `512`     |           0           |            0            |

**Description:**

Defines the size of each incoming message hash bucket.

---

| Parameter Name                     | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `OutgoingMessageFilterBucketCount` |      `3`      |           0           |            0            |

**Description:**

Defines the number of outgoing message hash buckets.

---

| Parameter Name                    | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `OutgoingMessageFilterBucketSize` |     `128`     |           0           |            0            |

**Description:**

Defines the size of each outgoing message hash bucket.

---

| Parameter Name                          | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableOutgoingNetworkMessageFiltering` |    `true`     |           0           |            0            |

**Description:**

Enables the filtering of outgoing messages by comparing their hashes with those
in the message hash buckets.

---

| Parameter Name                | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableIncomingMessageFilter` |    `false`    |           0           |            0            |

**Description:**

Enables the filtering of incoming messages.

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxIncomingFilteringFlags` |      `1`      |          26           |           26            |

**Description:**

Instructs [`algod`](API-overview.md#algorand-daemon) filtering of incoming transaction
messages.

Flag values:

- `0x00`: Disabled.
- `0x01` (`txFilterRawMsg`): Check for raw transaction message duplicates.
- `0x02` (`txFilterCanonical`): Check for canonical transaction group duplicates.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxIncomingFilterMaxSize` |   `500000`    |          28           |           28            |

**Description:**

Sets the maximum size for the de-duplication cache used by the incoming transaction
filter. Only relevant if `TxIncomingFilteringFlags` is non-zero.

---