# 🔄 Transaction Pool & Sync

---

| Parameter Name                    | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxPoolExponentialIncreaseFactor` |      `2`      |           0           |            0            |

**Description:**

Sets the increase factor of the [Transaction Pool](../../ledger/non-normative/ledger-nn-txpool.md)
fee threshold. When the transaction pool is full, the priority of a new transaction
must be at least `TxPoolExponentialIncreaseFactor` times greater than the minimum-priority
of a transaction already in the pool; otherwise, the new transaction is discarded.

> Should be set to `2` on MainNet.

---

| Parameter Name                      | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogServiceRateWindowSeconds` |     `10`      |          27           |           27            |

**Description:**

Defines the time window (in seconds) used to determine the service rate of the transaction
backlog (`txBacklog`). It helps to manage how quickly the node processes and serves
transactions waiting in the backlog by monitoring the rate over a specific time period.

---

| Parameter Name                     | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogReservedCapacityPerPeer` |     `20`      |          27           |           27            |

**Description:**

Determines the dedicated capacity allocated to each peer for serving transactions
from the transaction backlog (`txBacklog`). This ensures each peer has a specific
portion of the overall transaction processing capacity, preventing one peer from
monopolizing the node’s transaction handling resources.

---

| Parameter Name                     | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogAppTxRateLimiterMaxSize` |   `1048576`   |          32           |           32            |

**Description:**

Defines the maximum size for the _transaction rate limiter_, which is used to regulate
the number of transactions that an Application can submit to the node within a given
period. This rate limiter prevents individual Applications from overwhelming the
network with excessive transactions. The value may be interpreted as the maximum
sum of transaction bytes per period.

---

| Parameter Name                | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogAppTxPerSecondRate` |     `100`     |          32           |           32            |

**Description:**

Determines the target transaction rate per second for an Application’s transactions
within the _transaction rate limiter_. This means the node will aim to allow an Application
to submit a specific number of transactions per second. If the Application tries
to send more transactions than the rate limit allows, those transactions will be
delayed or throttled.

---

| Parameter Name                       | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogRateLimitingCongestionPct` |     `50`      |          32           |           32            |

**Description:**

Determines the threshold percentage at which the _transaction backlog rate limiter_
will be activated. When the backlog reaches a certain percentage, the node will start
to limit the rate of transactions, either by slowing down incoming transactions or
applying throttling measures. This helps prevent the backlog from growing too large
and causing congestion on the network. If the backlog falls below this threshold,
rate limiting is relaxed.

---

| Parameter Name                   | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableTxBacklogAppRateLimiting` |    `true`     |          32           |           32            |

**Description:**

Determines whether an _Application-specific rate limiter_ should be applied when
adding transactions to the transaction backlog. If enabled, the node enforces rate
limits on how many Application transactions can be enqueued, preventing excessive
transaction submission from a single app.

---

| Parameter Name                          | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogAppRateLimitingCountERLDrops` |    `false`    |          35           |           35            |

**Description:**

Determines whether transaction messages dropped by the ERL (_Exponential Rate Limiter_)
congestion manager and the _transaction backlog rate limiter_ should also be counted
by the Application rate limiter. When enabled, all dropped transactions are included
in the Application rate limiter’s calculations, making its rate-limiting decisions
more accurate. However, this comes at the cost of additional deserialization overhead,
as more transactions need to be processed even if they are ultimately dropped.

---

| Parameter Name                | Default Value |  Introduced in Version   | Last Updated in Version |
|-------------------------------|:-------------:|:------------------------:|:-----------------------:|
| `EnableTxBacklogRateLimiting` |    `true`     | 27 (default was `false`) |           30            |

**Description:**

Determines whether a rate limiter and congestion manager should be applied when
adding transactions to the transaction backlog. When enabled, the total transaction
backlog size increases by `MAX_PEERS * TxBacklogReservedCapacityPerPeer`, allowing
each peer to have a dedicated portion of the backlog. This helps manage network
congestion by preventing any single source from overwhelming the queue.

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `TxBacklogSize` |    `26000`    |          27           |           27            |

**Description:**

Defines the queue size for storing received transactions before they are processed.
The default value (`26000`) approximates the number of transactions that fit in a
single block. However, if `EnableTxBacklogRateLimiting` is enabled, the total backlog
size increases by `MAX_PEERS * TxBacklogReservedCapacityPerPeer`, allocating additional
capacity per peer.

---

| Parameter Name | Default Value |  Introduced in Version  | Last Updated in Version |
|----------------|:-------------:|:-----------------------:|:-----------------------:|
| `TxPoolSize`   |    `75000`    | 0 (default was `50000`) |           23            |

**Description:**

Defines the maximum number of transactions stored in the [Transaction Pool](../../ledger/non-normative/ledger-nn-txpool.md)
buffer before being processed or discarded.

---

| Parameter Name         | Default Value | Introduced in Version | Last Updated in Version |
|------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxSyncTimeoutSeconds` |     `30`      |           0           |            0            |

**Description:**

Defines the maximum time a node will wait for responses after attempting to synchronize
transactions by gossiping them to peers. After gossiping, the node waits for acknowledgments,
such as confirmation that the transaction has been added to a peer’s Transaction
Pool or relayed to others. If no acknowledgment is received within the time limit
set by `TxSyncTimeoutSeconds`, the node stops the synchronization attempt and moves
on to other tasks. However, the node will retry synchronization in future cycles.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxSyncIntervalSeconds` |     `60`      |           0           |            0            |

**Description:**

Defines the number of seconds between transaction synchronizations.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TxSyncServeResponseSize` |   `1000000`   |           3           |            3            |

**Description:**

Sets the maximum size, in bytes, that the synchronization server will return when
serving transaction synchronization requests.

---

| Parameter Name                  | Default Value |  Introduced in Version   | Last Updated in Version |
|---------------------------------|:-------------:|:------------------------:|:-----------------------:|
| `VerifiedTranscationsCacheSize` |   `150000`    | 14 (default was `30000`) |           23            |

**Description:**

Defines the number of transactions that the verified transactions cache would hold
before cycling the cache storage in a _round-robin_ fashion.

---

| Parameter Name           | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------|:-------------:|:---------------------:|:-----------------------:|
| `ForceFetchTransactions` |    `false`    |          17           |           17            |

**Description:**

Forces a node to retrieve all transactions observed into its [Transaction Pool](../../ledger/non-normative/ledger-nn-txpool.md),
regardless of whether the node is participating in consensus or not.

---

| Parameter Name                    | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TransactionSyncDataExchangeRate` |      `0`      |          17           |           17            |

**Description:**

Overrides the auto-computed data exchange rate between two peers. The unit of the
data exchange rate is in bytes per second. Setting the value to `0` implies allowing
the transaction sync to calculate the value dynamically.

---

| Parameter Name                               | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `TransactionSyncSignificantMessageThreshold` |      `0`      |          17           |           17            |

**Description:**

Defines the threshold used for a _Transaction Sync_ message before it can be used
to calculate the data exchange rate. Setting this to `0` would use the default values.
The threshold is defined in bytes as a unit.

---
