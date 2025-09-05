# 🎣 Fast Catchup

---

| Parameter Name                  | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupFailurePeerRefreshRate` |     `10`      |           0           |            0            |

**Description:**

Specifies the maximum number of consecutive attempts to [Fast Catchup](./node-nn-sync.md#fast-catchup)
after which peer connections are replaced.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupParallelBlocks` |     `16`      | 3 (default was `50`)  |            5            |

**Description:**

Is the maximum number of blocks that the [Fast Catchup](./node-nn-sync.md#fast-catchup)
will fetch in parallel. If less than [`Protocol.SeedLookback`](../abft/abft-parameters.md),
then `Protocol.SeedLookback` will be used to limit the catchup. Setting this to `0`
would disable the catchup.

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchpointInterval` |    `10000`    |           7           |            7            |

**Description:**

Defines how often a [_Catchpoint_](./node-nn-sync.md#fast-catchup) is generated,
measured in rounds. These Ledger snapshots allow nodes to sync quickly by downloading
and verifying the Ledger state at a specific round instead of replaying all transactions.
Setting this to `0` disables the Catchpoints from being generated.

---

| Parameter Name                | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchpointFileHistoryLength` |     `365`     |           7           |            7            |

**Description:**

Defines how many _Catchpoint Files_ to store. A value of `0` means don’t store any,
`-1` means unlimited; a positive number suggests the maximum number of most recent
Catchpoint Files to store.

---

| Parameter Name                    | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupHTTPBlockFetchTimeoutSec` |      `4`      |           9           |            9            |

**Description:**

Sets the maximum time (in seconds) that a node will wait for an HTTP response when
requesting a block from a Relay Node during [Fast Catchup](./node-nn-sync.md#fast-catchup).
If the request takes longer than this timeout, the node abandons the request and
tries with another Relay Node.

---

| Parameter Name                      | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupGossipBlockFetchTimeoutSec` |      `4`      |           9           |            9            |

**Description:**

Controls how long the gossip query for fetching a block from a Relay Node would take
before giving up and trying another Relay Node.

---

| Parameter Name                       | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupLedgerDownloadRetryAttempts` |     `50`      |           9           |            9            |

**Description:**

Controls the number of attempts the _Ledger fetcher_ would perform before giving
up the [Fast Catchup](./node-nn-sync.md#fast-catchup) to the provided Catchpoint.

---

| Parameter Name                      | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupBlockDownloadRetryAttempts` |    `1000`     |           9           |            9            |

**Description:**

Controls the number of attempts the _Block fetcher_ would perform before giving up
on a provided Catchpoint.

---

| Parameter Name       | Default Value | Introduced in Version | Last Updated in Version |
|----------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchpointTracking` |      `0`      |          11           |           11            |

**Description:**

Determines if _Catchpoints_ are going to be tracked. The value is interpreted as
follows:

- `-1`: Do not track Catchpoints.
- `1`: Track Catchpoints as long as `CatchpointInterval` > `0`.
- `2`: Track Catchpoints and always generate Catchpoint Files as long as `CatchpointInterval` > `0`.
- `0`: Automatic (default). In this mode, a Non-Archival node would not track the
  Catchpoints, while an Archival node would track the Catchpoints as long as `CatchpointInterval` > `0`.
- Any other values of this field would behave as if the default value was provided.

---

| Parameter Name                  |  Default Value   |      Introduced in Version       | Last Updated in Version |
|---------------------------------|:----------------:|:--------------------------------:|:-----------------------:|
| `MaxCatchpointDownloadDuration` | `43200000000000` | 13 (default was `7200000000000`) |           28            |

**Description:**

Defines the maximum duration for which a client will keep the outgoing connection
of a Catchpoint download request open for processing before shutting it down. In
Networks with large Catchpoint files, slow connections, or slow storage could be
a good reason to increase this value.

> This is a client-side only configuration value, and it’s independent of the actual
> Catchpoint file size.

---

| Parameter Name                            | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `MinCatchpointFileDownloadBytesPerSecond` |    `20480`    |          13           |           13            |

**Description:**

Defines the minimal download speed that would be considered to be “acceptable” by
the Catchpoint file fetcher, measured in bytes per second. The connection would
be recycled if the provided stream speed drops below this threshold. If this field
is `0`, the default value would be used instead.

> The download speed is evaluated per Catchpoint “chunk”.

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `CatchupBlockValidateMode` |    `0000`     |          16           |           16            |

**Description:**

A configuration used by the [Fast Catchup](./node-nn-sync.md#fast-catchup) service.
It can be used to omit certain validations to speed up the synchronization
process, or to apply extra validations. The value is a bitmask (where `bit 0` is
the LSB and `bit 3` is the MSB).

The value of each bit is interpreted as follows:

- `bit 0`:
  - `0`: Verify the block certificate.
  - `1`: Skip this validation.

- `bit 1`:
  - `0`: Verify payset committed hash in [block header](../ledger/ledger-block.md) matches payset hash.
  - `1`: Skip this validation.

- `bit 2`:
  - `0`: Skip verifying the transaction signatures on the block are valid.
  - `1`: Verify transaction signatures in the block.

- `bit 3`:
  - `0`: Skip verifying that the recomputed payset hash matches the payset committed hash in the block header.
  - `1`: Perform verification as described above.

> Not all permutations of the above bitmask are currently functional. In particular,
> the functional ones are:
>
> - `0000`: Default behavior, perform standard validations and skip extra validations.
> - `0011`: Speed up synchronization, skip standard and extra validations.
> - `1100`: Pedantic, perform standard and extra validations.

---
