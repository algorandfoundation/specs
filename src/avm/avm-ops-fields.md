# Fields

## Transaction Fields

> For further details on transaction fields, refer to the `txn` [opcode specification](./avm-appendix-a.md).

### Scalar Fields

{{#include ../_include/auto/opcodes/txn-fields.md}}

### Array Fields

{{#include ../_include/auto/opcodes/txna-fields.md}}

## Global Fields

Global fields are fields that are common to all the transactions in the group. In
particular, it includes consensus parameters.

{{#include ../_include/auto/opcodes/global-fields.md}}

## Asset Fields

Asset fields include `AssetHolding` and `AssetParam` fields that are used in the
`asset_holding_get` and `asset_params_get` opcodes.

### Asset Holding

{{#include ../_include/auto/opcodes/asset_holding-fields.md}}

### Asset Parameters

{{#include ../_include/auto/opcodes/asset_params-fields.md}}

## Application Fields

Application fields used in the `app_params_get` opcode.

{{#include ../_include/auto/opcodes/app_params-fields.md}}

## Account Fields

Account fields used in the `acct_params_get` opcode.

{{#include ../_include/auto/opcodes/acct_params-fields.md}}
