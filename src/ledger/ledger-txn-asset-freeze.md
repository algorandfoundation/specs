$$
\newcommand \Asset {\mathrm{Asa}}
$$

# Asset Freeze Transaction

## Fields

An _asset freeze_ transaction additionally has the following fields:

| FIELD          | CODEC  |   TYPE    | REQUIRED |
|:---------------|:------:|:---------:|:--------:|
| Asset ID       | `faid` | `uint64`  |   Yes    |
| Freeze Address | `fadd` | `address` |   Yes    |
| Frozen Status  | `afrz` |  `bool`   |   Yes    |

### Asset ID

The _asset ID_ \\( \Asset_\mathrm{frz,ID} \\) identifies the asset being _frozen_
or _unfrozen_.

### Freeze Address

The _freeze address_ \\( I_\mathrm{frz} \\) identifies the account whose holdings
of the _asset ID_ should be _frozen_ or _unfrozen_.

### Frozen Status

The _frozen status_ \\( \Asset_f \\) is a flag setting of whether the _freeze address_
holdings of _asset ID_ should be frozen (`true`) or unfrozen (`false`).

## Semantic

TODO

## Validation

-   The _asset ID_ \\( \Asset_\mathrm{frz,ID} \\) **MUST** be non-zero.
-   The _freeze address_ \\( I_\mathrm{frz} \\) **MUST** be provided.
