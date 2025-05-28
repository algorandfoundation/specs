## 📊 Metrics & Telemetry

---

| Parameter Name              | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `NodeExporterListenAddress` |    `:9100`    |           0           |            0            |

**Description:**

Sets the specific address for publishing metrics.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableMetricReporting` |    `false`    |           0           |            0            |

**Description:**

Determines whether the metrics collection service is enabled for the node. When
enabled, the node will collect performance and usage metrics from the specific instance
of [`algod`](API-overview.md#algorand-daemon). Additionally, machine-wide metrics
are also collected. This enables monitoring across all instances on the same machine,
helping with performance analysis and troubleshooting.

---

| Parameter Name     |   Default Value   | Introduced in Version | Last Updated in Version |
|--------------------|:-----------------:|:---------------------:|:-----------------------:|
| `NodeExporterPath` | `./node_exporter` |           0           |            0            |

**Description:**

Specifies the path to the `node_exporter` binary, which exposes node metrics for
monitoring and integration with systems like _Prometheus_. The `node_exporter` collects
and exposes various performance and health metrics from the node.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableAssembleStats` | Empty string  |           3           |            3            |

**Description:**

Specifies whether to emit the `AssembleBlockMetrics` telemetry event.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableProcessBlockStats` | Empty string  |           3           |            3            |

**Description:**

Specifies whether to emit the `ProcessBlockMetrics` telemetry event.

---

| Parameter Name                  | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `PeerConnectionsUpdateInterval` |    `3600`     |           5           |            5            |

**Description:**

Defines the interval at which the peer connections’ information is sent to telemetry.
Defined in seconds.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `HeartbeatUpdateInterval` |     `600`     |          27           |           27            |

**Description:**

Defines the interval at which the _heartbeat_ information is sent to the telemetry
(when enabled). Defined in seconds. Minimum value is `60`.

---

| Parameter Name         | Default Value | Introduced in Version | Last Updated in Version |
|------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableRuntimeMetrics` |    `false`    |          22           |           22            |

**Description:**

Exposes Go runtime metrics in `/metrics` and via `node_exporter`.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableNetDevMetrics` |    `false`    |          34           |           34            |

**Description:**

Exposes network interface total bytes sent/received metrics in `/metrics`

---

| Parameter Name              | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableAccountUpdatesStats` |    `false`    |          16           |           16            |

**Description:**

Specifies whether to emit the `AccountUpdates` telemetry event.

---

| Parameter Name                | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `AccountUpdatesStatsInterval` | `5000000000`  |          16           |           16            |

**Description:**

Time interval in nanoseconds between `accountUpdates` telemetry events.

---

| Parameter Name   | Default Value | Introduced in Version | Last Updated in Version |
|------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableUsageLog` |    `false`    |          31           |           31            |

**Description:**

Enables 10Hz log of CPU and RAM usage. Also adds `algod_ram_usage` (number of bytes
in use) to `/metrics`.

---