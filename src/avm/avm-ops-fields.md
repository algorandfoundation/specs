# Fields

## Transaction Fields

> For further details on transaction fields, refer to the `txn` [opcode specification](./avm-appendix-a.md).

### Scalar Fields

{{#include ../.include/auto-avm-fields-txn-scalar.md}}

### Array Fields

{{#include ../.include/auto-avm-fields-txn-array.md}}

## Global Fields

Global fields are fields that are common to all the transactions in the group. In
particular, it includes consensus parameters.

{{#include ../.include/auto-avm-fields-global.md}}

## Asset Fields

Asset fields include `AssetHolding` and `AssetParam` fields that are used in the
`asset_holding_get` and `asset_params_get` opcodes.

{{#include ../.include/auto-avm-fields-asset.md}}

## Application Fields

Application fields used in the `app_params_get` opcode.

{{#include ../.include/auto-avm-fields-application.md}}

## Account Fields

Account fields used in the `acct_params_get` opcode.

{{#include ../.include/auto-avm-fields-account.md}}