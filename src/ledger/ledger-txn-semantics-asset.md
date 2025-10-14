$$
\newcommand \MinBalance {b_{\min}}
$$

# Asset Transaction Semantics

## Asset Configuration

An [_asset configuration_](./ledger-txn-asset-config.md) transaction has the following
semantics:

- If the [_asset ID_](./ledger-txn-asset-config.md#asset-id) is zero, create a new
asset with an ID corresponding to one plus this transaction’s unique counter value.
The transaction’s counter value is the transaction counter field from the block
header plus the positional index of this transaction in the block (starting from
\\( 0 \\)).

On asset creation, the [_asset parameters_](ledger-txn-asset-config.md#asset-parameters)
for the created asset are stored in the creator’s account under the newly allocated
asset ID. The creating account also allocates space to hold asset units of the newly
allocated asset. All units of the newly created asset (i.e., the _total_ specified
in the parameters) are held by the creator. When the creator holding is initialized,
it ignores the _default frozen_flag and is always initialized to unfrozen.

- If the [_asset ID_](./ledger-txn-asset-config.md#asset-id) is non-zero, the transaction
**MUST** be issued by the _asset manager_ (based on the asset’s current parameters).
A zero manager address means no such transaction can be issued.

  - If the [_asset parameters_](ledger-txn-asset-config.md#asset-parameters) are
  omitted (the zero value), the asset is destroyed. This is allowed only if the
  _asset creator_ holds all of the units of that asset (i.e., equal to the _total_
  in the parameters).

  - If the [_asset parameters_](ledger-txn-asset-config.md#asset-parameters) are
  not omitted, any non-zero key in the asset’s current parameters (as stored in
  the asset creator’s account) is updated to the key specified in the _asset parameters_.
  This applies to the _manager_, _reserve_, _freeze_, and _clawback_ keys.  Once
  a key is set to zero, it cannot be updated. Other parameters are immutable.

## Asset Transfer

An [_asset transfer_](./ledger-txn-asset-transfer.md) transaction has the following
semantics:

- If the [_asset sender_](./ledger-txn-asset-transfer.md#asset-sender) field is non-zero,
the transaction **MUST** be issued by the asset’s clawback address, and this transaction
can neither allocate nor close out holdings of an asset (i.e., the asset close-to
field **MUST NOT** be specified, and the source account **MUST** already have allocated
space to store holdings of the asset in question). In this _clawback_ case, freezes
**MUST** be bypassed on both the source and destination of this transfer.

- If the [_asset sender_](./ledger-txn-asset-transfer.md#asset-sender) field is zero,
the asset sender is assumed to be the transaction’s sender, and freezes **MUST NOT**
be bypassed.

- If the [_asset amount_](./ledger-txn-asset-transfer.md#asset-amount) is \\( 0 \\),
the transaction allocates space in the sender’s account to store the _asset ID_.
The holdings are initialized with a zero number of units of that asset, and the
_default frozen_ flag from the asset’s parameters. Space cannot be allocated for
asset IDs that have never been created, or that have been destroyed, at the time
of space allocation. Space can remain allocated, however, after the asset is destroyed.

- The transaction moves the specified number of units of the asset from the [_asset
sender_](./ledger-txn-asset-transfer.md#asset-sender) to the [_asset receiver_](./ledger-txn-asset-transfer.md#asset-receiver).

  - If either account is frozen, and freezes are not bypassed, the transaction fails
  to execute.

  - If either account has no space allocated to hold units of this asset, the transaction
  fails to execute.

  - If the [_asset sender_](./ledger-txn-asset-transfer.md#asset-sender) has fewer
  than the specified number of units of that asset, the transaction fails to execute.

- If the [_asset close-to_](./ledger-txn-asset-transfer.md#asset-close-to-address)
field is specified, the transaction transfers all remaining units of the asset to
the [_close-to address_](./ledger-txn-asset-transfer.md#asset-close-to-address).

  - If the [_close-to address_](./ledger-txn-asset-transfer.md#asset-close-to-address)
  is not the creator address, then neither the [_asset sender_](./ledger-txn-asset-transfer.md#asset-sender)’s
  holdings of this asset nor the [_close-to address_](./ledger-txn-asset-transfer.md#asset-close-to-address)’s
  holdings can be frozen; otherwise, the transaction fails to execute.

  - Closing to the _asset creator_ is always allowed, even if the source and/or creator
  account’s holdings are frozen.

  - If the [_asset sender_](./ledger-txn-asset-transfer.md#asset-sender) or [_close-to
  address_](./ledger-txn-asset-transfer.md#asset-close-to-address) does not have
  allocated space for the asset in question, the transaction fails to execute.

  - After transferring all outstanding units of the asset, space for the asset is
  deallocated from the sender account.

## Asset Freeze

An [_asset freeze_](./ledger-txn-asset-freeze.md) transaction has the following
semantics:

- If the transaction is not issued by the _freeze address_ in the specified asset’s
parameters, the transaction fails to execute.

- If the specified [_asset ID_](./ledger-txn-asset-freeze.md#asset-id) does not exist
in the specified account, the transaction fails to execute.

- The [_freeze_](./ledger-txn-asset-freeze.md#frozen-status) flag of the specified
asset in the specified account is updated to the [_frozen status_](./ledger-txn-asset-freeze.md#frozen-status)
flag value from the freeze transaction.

## Asset Allocation

When an asset transaction allocates space in an account for an asset, whether by
creation or opt-in, the sender’s minimum balance requirement is incremented by
\\( \MinBalance \\).

When the space is deallocated, whether by asset destruction or asset close-to, the
minimum balance requirement of the sender is decremented by \\( \MinBalance \\).
