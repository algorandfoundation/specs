$$
\newcommand \Asset {\mathrm{Asa}}
\newcommand \MaxAssetDecimals {\Asset_{d,\max}}
\newcommand \MaxAssetNameBytes {\Asset_{n,\max}}
\newcommand \MaxAssetUnitNameBytes {\Asset_{u,\max}}
\newcommand \MaxAssetURLBytes {\Asset_{r,\max}}
$$

# Asset Configuration Transaction

## Fields

An _asset configuration_ transaction additionally has the following fields:

| FIELD            | CODEC  |   TYPE   |         REQUIRED          |
|:-----------------|:------:|:--------:|:-------------------------:|
| Asset ID         | `caid` | `uint64` | Yes (except for Creation) |
| Asset Parameters | `apar` | `struct` |    Yes (for Creation)     |

### Asset ID

The _asset ID_ \\( \Asset_\mathrm{cfg,ID} \\) identifies the asset being configured.

> If the _asset ID_ is omitted (zero), this transaction is _creating_ an asset.

### Asset Parameters

The _asset parameters_ are the parameters for configuring the asset.

These _asset parameters_ is struct containing:

| FIELD          | CODEC |    TYPE    | DESCRIPTION                                                                                |
|:---------------|:-----:|:----------:|:-------------------------------------------------------------------------------------------|
| Total          |  `t`  |  `uint64`  | Total amount of units of the asset                                                         |
| Decimals       | `dc`  |  `uint32`  | Number of digits after the decimal place                                                   |
| Default Frozen | `df`  |   `bool`   | Flag that specifies if the asset requires whitelisting (yes if `true`)                     |
| Unit Name      | `un`  |  `string`  | Asset unit symbol (or asset short-name)                                                    |
| Asset Name     | `an`  |  `string`  | Asset name                                                                                 |
| URL            | `au`  |  `string`  | URL to retrieve additional asset information                                               |
| Metadata Hash  | `am`  | `[32]byte` | Commitment to asset metadata                                                               |
| Manager        |  `m`  | `address`  | Account allowed to set the asset role-based access control and destroy the asset           |
| Reserve        |  `r`  | `address`  | Account whose asset holdings should be interpreted as “not mined” (this is purely a label) |
| Freeze         |  `f`  | `address`  | Account allowed to change the account’s frozen state for the asset holdings                |
| Clawback       |  `c`  | `address`  | Account allowed to transfer units of the asset from any account                            |

- The _decimals_ **MUST NOT** exceed \\( \MaxAssetDecimals \\).

- The _unit name_ byte length **MUTS NOT** exceed \\( \MaxAssetUnitNameBytes \\).

- The _asset name_ byte length **MUST NOT** exceed \\( \MaxAssetNameBytes \\).

- The _URL_ byte length **MUST NOT** exceed \\( \MaxAssetURLBytes \\).

> If the _asset parameters_ are omitted (struct of zero values), this transaction
> is _deleting_ the asset.

## Semantic

TODO

## Validation

TODO