# 💾 Storage & Archival

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `Archival`     |    `false`    |           0           |            0            |

**Description:**

Enables saving a full copy of the blockchain history. Non-Archival nodes will only
maintain the necessary state to validate blockchain messages and participate in
the consensus protocol. Non-Archival nodes use significantly less storage space.

> The `Archival` parameter enables the node to save the complete history of the
> blockchain starting from the moment this setting is activated. Therefore, this
> setting must be enabled **before** you start the node for the first time. If the
> node has already been running without this setting enabled, the existing databases
> must be **deleted** and fully synchronized from the genesis.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `HotDataDir`   | Empty string  |          31           |           31            |

**Description:**

An optional directory to store data frequently accessed by the node. For isolation,
the node will create a subdirectory in this location, named by the network [`genesisID`](../ledger/ledger.md#genesis-identifier)
The node uses the default data directory provided at runtime if not specified. Individual
resources may override this setting. Setting `HotDataDir` to a dedicated high-performance
disk allows for basic disk tuning.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `ColdDataDir`  | Empty string  |          31           |           31            |

**Description:**

An optional directory for storing infrequently accessed data. The node creates a
subdirectory within this location, named after the network [`genesisID`](../ledger/ledger.md#genesis-identifier)
The node uses the default data directory provided at runtime if not specified. Individual
resources may have their own override settings, which take precedence over this value.
A slower disk for `ColdDataDir` can optimize storage costs and resource allocation.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `TrackerDBDir` | Empty string  |          31           |           31            |

**Description:**

An optional directory to store the tracker database. For isolation, the node will
create a subdirectory in this location, named by the network [`genesisID`](../ledger/ledger.md#genesis-identifier).
If not specified, the node will use the `HotDataDir`.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `BlockDBDir`   | Empty string  |          31           |           31            |

**Description:**

An optional directory to store the [block](../ledger/ledger.md#blocks) database.
For isolation, the node will create a subdirectory in this location, named by the
network [`genesisID`](../ledger/ledger.md#genesis-identifier). If not specified,
the node will use the `ColdDataDir`.

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchpointDir` | Empty string  |          31           |           31            |

**Description:**

An optional directory to store _Catchpoint Files_, except for the in-progress temporary
file, which will use the `HotDataDir` and is not separately configurable. For isolation,
the node will create a subdirectory in this location, named by the network [`genesisID`](../ledger/ledger.md#genesis-identifier).
If not specified, the node will use the `ColdDataDir`.

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `StateproofDir` | Empty string  |          31           |           31            |

**Description:**

An optional directory to persist state about observed and issued [state proof messages](../ledger/ledger.md#state-proof-message).
For isolation, the node will create a subdirectory in this location, named by the network [`genesisID`](../ledger/ledger.md#genesis-identifier).
If not specified, the node will use the `HotDataDir`.

---

| Parameter Name | Default Value | Introduced in Version | Last Updated in Version |
|----------------|:-------------:|:---------------------:|:-----------------------:|
| `CrashDBDir`   | Empty string  |          31           |           31            |

**Description:**

An optional directory to persist [Agreement participation](../abft/abft-overview.md)
state. For isolation, the node will create a subdirectory in this location, named
by the network [`genesisID`](../ledger/ledger.md#genesis-identifier). If not specified,
the node will use the `HotDataDir`

---

| Parameter Name                      | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `OptimizeAccountsDatabaseOnStartup` |    `false`    |          10           |           10            |

**Description:**

Controls whether the Account database would be optimized on [`algod`](API-overview.md#algorand-daemon)
startup.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `LedgerSynchronousMode` |      `2`      |          12           |           12            |

**Description:**

Defines the synchronous mode the [Ledger](../ledger/ledger-overview.md) database
uses.

The supported options are:

- `0`: SQLite continues without syncing as soon as it has handed data off to the operating system.
- `1`: SQLite database engine will still sync at the most critical moments, but less often than in FULL mode.
- `2`: SQLite database engine will use the VFS’s xSync method to ensure all content is safely written to the disk surface before continuing.
- `3`: In addition to what is being done in `2`, it provides some guarantee of durability if the commit is followed closely by a power loss.

> For further information, see the description of [`SynchronousMode`](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/util/db/dbutil.go#L435).

---

| Parameter Name                   | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `AccountsRebuildSynchronousMode` |      `1`      |          12           |           12            |

**Description:**

Defines the synchronous mode the [Ledger](../ledger/ledger-overview.md) database uses while the Account database
is being rebuilt. This is not a typical operational use-case, and is expected to
happen only on either startup (after enabling the _Catchpoint Interval_, or on certain
database upgrades) or during fast catchup. The values specified here and their meanings
are identical to the ones in `LedgerSynchronousMode`.

---

| Parameter Name    | Default Value | Introduced in Version | Last Updated in Version |
|-------------------|:-------------:|:---------------------:|:-----------------------:|
| `MaxAcctLookback` |      `4`      |          23           |           23            |

**Description:**

Sets the maximum lookback range for Account states.

{{#include ../.include/styles.md:example}}
> The Ledger can answer Account state questions for the range `[Latest - MaxAcctLookback, Latest]`.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `MaxBlockHistoryLookback` |      `0`      |          31           |           31            |

**Description:**

Sets the maximum lookback range for Block information.

{{#include ../.include/styles.md:example}}
> The Block DB can return transaction IDs for questions for the range `[Latest - MaxBlockHistoryLookback, Latest]`

---

| Parameter Name  | Default Value | Introduced in Version | Last Updated in Version |
|-----------------|:-------------:|:---------------------:|:-----------------------:|
| `StorageEngine` |   `sqlite`    |          28           |           28            |

**Description:**

Sets the type of storage to use for the Ledger. Available options are:

- `sqlite` (default).
- `pebbledb` (experimental, in development).

---