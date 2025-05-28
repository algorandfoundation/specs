# ⚙️ General & Versioning

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `Version`      |     `35`      |           0           |           35            |

**Description:**

Tracks the current version of the default configuration values, allowing migration
from older versions to newer ones. It is crucial when modifying default values for
existing parameters.

> This field must be updated accordingly whenever a new version is introduced.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `RunHosted`    |    `false`    |           3           |            3            |

**Description:**

Configures whether to run the Algorand node in Hosted mode.

---

| Parameter Name     | Default Value | Introduced in Version | Last Updated in Version |
|--------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableFollowMode` |    `false`    |          27           |           27            |

**Description:**

Launches the node in [Follower Mode](./node-nn-init-follower.md), which significantly
alters its behavior in terms of participation and API accessibility. When enabled,
this mode disables the [Agreement Service](../abft/abft-overview.md) (meaning the
node does not participate in consensus), and it disables APIs related to broadcasting
transactions, effectively making the node passive in terms of network operations.
Instead, Follower Mode enables APIs that allow the node to retrieve detailed information
from the Ledger cache and access the state of the blockchain at a specific round.
This can be useful for nodes that must observe the network and the blockchain’s state
without actively participating in consensus or transaction propagation.

---