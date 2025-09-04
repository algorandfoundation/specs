# 🗳️ Consensus & Agreement

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableAgreementReporting` |    `false`    |           3           |            3            |

**Description:**

Controls [Agreement](../abft/abft-overview.md) events reporting. When enabled,
it prints additional events related to the agreement periods within the consensus
process. This is useful for tracking and debugging the stages of agreement reached
by the node during the consensus rounds.

---

| Parameter Name               | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableAgreementTimeMetrics` |    `false`    |           3           |            3            |

**Description:**

Controls whether the node collects and reports metrics related to the timing of
the agreement process within the [Agreement](../abft/abft-overview.md) protocol.
When enabled, it provides detailed data on the time taken for agreement events during
consensus rounds.

---

| Parameter Name         | Default Value |    Introduced in Version     | Last Updated in Version |
|------------------------|:-------------:|:----------------------------:|:-----------------------:|
| `ProposalAssemblyTime` |  `500000000`  | 19 (default was `250000000`) |           23            |

**Description:**

The maximum amount of time to spend on generating a proposal block. Expressed in
nanoseconds.

---

| Parameter Name                      | Default Value |  Introduced in Version   | Last Updated in Version |
|-------------------------------------|:-------------:|:------------------------:|:-----------------------:|
| `AgreementIncomingVotesQueueLength` |    `20000`    | 21 (default was `10000`) |           27            |

**Description:**

Sets the buffer size holding incoming [votes](abft.md#votes).

---

| Parameter Name                          | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `AgreementIncomingProposalsQueueLength` |     `50`      | 21 (default was `25`) |           27            |

**Description:**

Sets the buffer size holding incoming [proposals](abft.md#proposals).

---

| Parameter Name                        | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `AgreementIncomingBundlesQueueLength` |     `15`      | 21 (default was `7`)  |           27            |

**Description:**

Sets the buffer size holding incoming [bundles](abft.md#bundles).

---
