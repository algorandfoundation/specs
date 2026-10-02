# State Access

## Block Access

{{#include ../_include/auto/opcodes/block-access.md}}

## Account Access

{{#include ../_include/auto/opcodes/account-access.md}}

## Asset Access

{{#include ../_include/auto/opcodes/asset-access.md}}

## Application Access

{{#include ../_include/auto/opcodes/application-access.md}}

## Box Access

Box opcodes that create, delete, or resize boxes affect the [minimum
balance requirement](../ledger/ledger-account-state.md#minimum-balance-requirement)
of the calling application's account. The change is immediate, and can
be observed after execution by using `min_balance`. The requirement
itself is enforced for the transaction as a whole, as described in the
Ledger's [account state validity
conditions](../ledger/ledger-validation.md).

All box related opcodes fail immediately if used in a
ClearStateProgram. This behavior is meant to discourage Smart Contract
authors from depending upon the availability of boxes in a ClearState
transaction, as accounts using ClearState are under no requirement to
furnish appropriate Box References. Authors would do well to keep the
same issue in mind with respect to the availability of Accounts,
Assets, and Apps though State Access opcodes _are_ allowed in
ClearState programs because the current application and sender account
are sure to be _available_.

An application may always operate on its own boxes, but access to another
application's boxes requires that application to have opted in, via two
mutable [application parameters](../ledger/ledger-applications.md#applications):
setting `ForeignBoxReads` permits any application to read its boxes, while
setting `FamilyBoxAccess` permits applications sharing its creator to both
read and modify them. Boxes of an application that has set `FamilyBoxAccess`
are further subject to the
[family reentrancy rule](../ledger/ledger-applications.md#family-reentrancy).

{{#include ../_include/auto/opcodes/box-access.md}}
