# 📜 Logging

---

| Parameter Name         | Default Value | Introduced in Version | Last Updated in Version |
|------------------------|:-------------:|:---------------------:|:-----------------------:|
| `BaseLoggerDebugLevel` |      `4`      |  0 (default was `1`)  |            1            |

**Description:**

Specifies the logging level for [`algod`](API-overview.md#algorand-daemon) (`node.log`).

The levels are:

- `0`: _Panic_: Highest level of severity. Logs and then calls `panic()`.

- `1`: _Fatal_: Logs and then calls `os.Exit(1)`. It will exit even if the logging
level is set to _Panic_.

- `2`: _Error_: Used for errors that should definitely be noted. Commonly used for
hooks to send errors to an error tracking service.

- `3`: _Warn_: Non-critical entries that deserve attention.

- `4`: _Info_: General operational entries.

- `5`: _Debug_: Verbose logging, usually only enabled when debugging.

---

| Parameter Name      | Default Value |    Introduced in Version     | Last Updated in Version |
|---------------------|:-------------:|:----------------------------:|:-----------------------:|
| `CadaverSizeTarget` |      `0`      | 0 (default was `1073741824`) |           24            |

**Description:**

Specifies the maximum size of the `agreement.cdv` file in bytes. Once full, the file
will be renamed to `agreement.archive.log` and a new `agreement.cdv` will be created.

---

| Parameter Name     | Default Value | Introduced in Version | Last Updated in Version |
|--------------------|:-------------:|:---------------------:|:-----------------------:|
| `CadaverDirectory` | Empty string  |          27           |           27            |

**Description:**

If not set, `MakeService` will attempt to use `ColdDataDir` instead.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `LogFileDir`   | Empty string  |          31           |           31            |

**Description:**

An optional directory to store the log file, `node.log`. If not set, the node will
use the `HotDataDir`. The `-o` GOAL CLI option can override this output location.

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `LogArchiveDir` | Empty string  |          31           |           31            |

**Description:**

An optional directory to store the log archive. If not specified, the node will
use the `ColdDataDir`.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `LogSizeLimit` | `1073741824`  |           0           |            0            |

**Description:**

Sets the node log file size limit in bytes. When set to `0`, logs will be written
to _stdout_.

---

| Parameter Name   |   Default Value    | Introduced in Version | Last Updated in Version |
|------------------|:------------------:|:---------------------:|:-----------------------:|
| `LogArchiveName` | `node.archive.log` |           4           |            4            |

**Description:**

Text template for creating the log archive filename. If the filename ends with `.gz`
or `.bz2` it will be compressed.

Available template variables:

- Time at the start of log:
  - {{.Year}}
  - {{.Month}}
  - {{.Day}}
  - {{.Hour}}
  - {{.Minute}}
  - {{.Second}}

- Time at the end of log:
  - {{.EndYear}}
  - {{.EndMonth}}
  - {{.EndDay}}
  - {{.EndHour}}
  - {{.EndMinute}}
  - {{.EndSecond}}

---

| Parameter Name     | Default Value | Introduced in Version | Last Updated in Version |
|--------------------|:-------------:|:---------------------:|:-----------------------:|
| `LogArchiveMaxAge` | Empty string  |           4           |            4            |

**Description:**

Specifies the maximum age for a node log. Valid units are `s` seconds, `m` minutes, `h` hours.

---

| Parameter Name        | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableRequestLogger` |    `false`    |           4           |            4            |

**Description:**

Enables the logging of the incoming requests to the telemetry server.

---

| Parameter Name   | Default Value | Introduced in Version | Last Updated in Version |
|------------------|:-------------:|:---------------------:|:-----------------------:|
| `TelemetryToLog` |    `true`     |           5           |            5            |

**Description:**

Configures whether to record messages to `node.log` that are usually only sent to
remote event monitoring.

---

| Parameter Name                         | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableVerbosedTransactionSyncLogging` |    `false`    |          17           |           17            |

**Description:**

Allows the _Transaction Sync_ to write extensive message exchange information to
the log file. This option is disabled by default to prevent the rapid growth of logs.

---
