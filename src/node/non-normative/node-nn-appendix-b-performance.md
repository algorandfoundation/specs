# 🚀 Performance & Resource Management

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `ReservedFDs`  |     `256`     |           2           |            2            |

**Description:**

This configuration parameter specifies the number of _reserved file descriptors_
(FDs) that the node will allocate. These reserved FDs are set aside for operations
that require temporary file descriptors, such as DNS queries, SQLite database interactions,
and other short-lived network operations. The total number of file descriptors available
to the node, as specified by the node’s file descriptor limit (`RLIMIT_NOFILE`),
should always be greater than or equal to:

`IncomingConnectionsLimit + RestConnectionsHardLimit + ReservedFDs`.

This parameter is typically left at its default value and should not be changed
unless necessary. If the node’s file descriptor limit is lower than the sum of the
three components, it could cause issues with node functionality.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `DisableLedgerLRUCache` |    `false`    |          27           |           27            |

**Description:**

Disables LRU caches in Ledger.

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `BlockServiceMemCap` |  `500000000`  |          28           |           28            |

**Description:**

The memory capacity in bytes that the block service is allowed to use for HTTP block
requests. It redirects the block requests to a different node when it exceeds this
capacity.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `GoMemLimit`   |      `0`      |          34           |           34            |

**Description:**

Provides the Go runtime with a soft memory limit. The default behavior is unlimited,
unless the `GOMEMLIMIT` environment variable is set.

---
