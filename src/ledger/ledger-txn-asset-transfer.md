$$
\newcommand \Asset {\mathrm{Asa}}
$$

# Asset Transfer Transaction

## Fields

An _asset transfer_ transaction additionally has the following fields:

| FIELD          | MSGPACK  |   TYPE    | OPTIONAL |
|:---------------|:--------:|:---------:|:--------:|
| Asset ID       |  `xaid`  | `uint64`  |    No    |
| Asset Amount   |  `aamt`  | `uint64`  |   Yes    |
| Asset Sender   |  `asnd`  | `address` |   Yes    |
| Asset Receiver |  `arcv`  | `address` |    No    |
| Asset Close-to | `aclose` | `address` |   Yes    |

### Asset ID

The _asset ID_ \\( \Asset_\mathrm{xfer,ID} \\) identifies the asset being transferred.

### Asset Amount

The _asset amount_ \\( \Asset_a \\) indicates the number of _asset units_ being
transferred.

> If the _asset amount_ is omitted (\\( \Asset_a = 0 \\)), the number of _asset units_
> transferred is zero.

### Asset Sender

The _asset sender_ \\( \Asset_I \\) identifies the source address for the asset
transfer (non-zero if the transaction is a _clawback_).

> If the _asset sender_ is omitted (\\( \Asset_I = 0 \\)), the source address of
> the asset transfer is the _sender_ of the transaction.

### Asset Receiver

The _asset receiver_ \\( \Asset_{I^\prime} \\) identifies the destination address
for the asset transfer.

### Asset Close-to Address

The _asset close to_ address \\( \Asset_{I_0}\\) collects all remaining _asset units_
in the _sender_ account _after_ the asset transfer.

> If the _asset close to_ address is omitted (\\( \Asset_{I_0}\\)), the field has
> no effect.

## Semantic

TODO

## Validation

TODO