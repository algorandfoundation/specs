# State Access

## Block Access

{{#include ../.include/auto/avm-ops-state-access-block.md}}

## Account Access

{{#include ../.include/auto/avm-ops-state-access-account.md}}

## Asset Access

{{#include ../.include/auto/avm-ops-state-access-asset.md}}

## Application Access

{{#include ../.include/auto/avm-ops-state-access-app.md}}

## Box Access

Box opcodes that create, delete, or resize boxes affect the minimum
balance requirement of the calling application's account.  The change
is immediate, and can be observed after exection by using
`min_balance`.  If the account does not possess the new minimum
balance, the opcode fails.

All box related opcodes fail immediately if used in a
ClearStateProgram. This behavior is meant to discourage Smart Contract
authors from depending upon the availability of boxes in a ClearState
transaction, as accounts using ClearState are under no requirement to
furnish appropriate Box References.  Authors would do well to keep the
same issue in mind with respect to the availability of Accounts,
Assets, and Apps though State Access opcodes _are_ allowed in
ClearState programs because the current application and sender account
are sure to be _available_.

{{#include ../.include/auto/avm-ops-state-access-box.md}}