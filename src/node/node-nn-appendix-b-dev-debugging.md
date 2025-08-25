# 🛠️ Developer & Debugging

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableDeveloperAPI` |    `false`    |           9           |            9            |

**Description:**

Enables `teal/compile` and `teal/dryrun` [API endpoints](API-overview.md).

---

| Parameter Name      | Default Value | Introduced in Version | Last Updated in Version |
|---------------------|:-------------:|:---------------------:|:-----------------------:|
| `DeadlockDetection` |      `0`      |           1           |            1            |

**Description:**

Controls whether the node actively detects potential deadlocks in its operations.
A deadlock occurs when two or more processes are stuck waiting for each other to
release resources, preventing progress. Deadlock detection is enabled when set to
a positive value, allowing the node to monitor and identify such situations. A value
of `-1` disables deadlock detection, and a value of `0` sets the default behavior,
where the system determines whether to enable deadlock detection automatically based
on the environment.

---

| Parameter Name               | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `DeadlockDetectionThreshold` |     `30`      |          20           |           20            |

**Description:**

Defines the time limit, in seconds, that the node waits before considering a potential
deadlock situation. If a process or operation exceeds this threshold without progressing,
the node will trigger deadlock detection to identify and handle the issue.

---

| Parameter Name   | Default Value | Introduced in Version | Last Updated in Version |
|------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableProfiler` |    `false`    |           0           |            0            |

**Description:**

Allows the node to expose Go’s `pprof` profiling endpoints, which provide detailed
performance metrics such as CPU, memory, and `goroutine` usage. This is useful for
debugging and performance analysis. When enabled, the node will serve profiling
data through its API, allowing developers to inspect real-time runtime behavior.
However, since _pprof_ can expose sensitive performance details, it should be disabled
in production or whenever the API is accessible to untrusted individuals, as an attacker
could use this information to analyze and exploit the system.

---

| Parameter Name              | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `NetworkMessageTraceServer` | Empty string  |          13           |           13            |

**Description:**

A `host:port` address to report graph propagation trace info to.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableTxnEvalTracer` |    `false`    |          27           |           27            |

**Description:**

Turns on features in the `BlockEvaluator`, which collect data on transactions, exposing
them via [`algod` APIs](API-overview.md#algorand-daemon). It will store [state deltas](../ledger/ledger-nn-state-delta.md)
created during block evaluation, potentially consuming much larger amounts of memory.

---