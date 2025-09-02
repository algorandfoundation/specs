$$
\newcommand \App {\mathrm{App}}
\newcommand \MaxAppProgramCost {\App_{c,\max}}
\newcommand \MaxTxGroupSize {GT_{\max}}
\newcommand \MaxInnerTransactions {\App_\mathrm{itxn}}
\newcommand \MaxAppTotalProgramLen {\App_{\mathrm{prog},t,\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
$$

# Execution Environment for Applications (Smart Contracts)

Applications (Smart Contracts) are executed in [_Application Call_ transactions]().
Like Logic Signatures, Applications indicate success by leaving a single non-zero
`uint64` value on the Stack.

A failed Application Call to an Approval Program is not a valid transaction, thus
not written to the blockchain.

An Application Call with [On Complete]() set to `ClearStateOC` invokes the Clear
State Program, rather than the usual Approval Program. If the Clear State Program
fails, application state changes are rolled back, but the transaction still succeeds,
and the sender's Local State for the called application is removed.

Applications have access to everything a Logic Signature may access (see [section]()),
as well as the ability to examine blockchain state, such as balances and application
state (their own state and the state of other applications).

Applications also have access to some [Global Fields]() that are not visible to Logic
Signatures because their values change over time.

Since Applications access changing state, nodes have to rerun their code to determine
if the Application Call transactions in their Transaction Pool would still succeed
each time a block is added to the blockchain.

## Bytecode Size

The size of an Application is defined as the length of its approval program bytecode plus its clearstate program bytecode. The sum of these two programs **MUST NOT** exceed \\( \MaxAppTotalProgramLen \times \MaxExtraAppProgramPages \\).

## Opcode Budget

Applications have limits on their execution cost.

Before Version 4, this was a static limit on the cost of all the instructions in
the program.

Starting in Version 4, the cost is tracked dynamically during execution
and **MUST NOT** exceed \\( \MaxAppProgramCost \\).

Beginning with Version 5, programs costs are pooled and tracked dynamically across
Application executions in a group. If \\( n \\) application invocations appear in
a group, then the total execution cost of all such calls **MUST NOT** exceed \\( n \times \MaxAppProgramCost \\).

In Version 6, inner Application Calls become possible, and each such call increases
the pooled opcode budget by \\( \MaxAppProgramCost \\) at the time the inner group
is submitted (with the `itxn_submit` opcode), allowing a maximum opcode budget of:

$$
\MaxTxGroupSize \times (1 + \MaxInnerTransactions) \times \MaxAppProgramCost = 190{,}400
$$

## Clear Program Execution

Executions of the Clear State Program are more stringent, to ensure that Applications
may be closed out (by accounts) and have a chance to clean up their internal state.

At the beginning of a Clear State Program execution, the pooled budget available
**MUST** be \\( \MaxAppProgramCost \\) or higher. If it is not, the containing transaction
group fails without clearing the Application's state.

During the Clear State Program execution, no more than \\( \MaxAppProgramCost \\)
may be drawn. If further execution is attempted, the Clear State Program fails, and
the Application's state _is cleared_.

## Resource Availability

Applications have limits on the amount of blockchain state they may examine.

Opcodes may only access blockchain resources such as Accounts, Assets, Boxes, and
Application state if the given resource is _available_.

- A resource in the _foreign array_ fields of the [Application Call transaction]()
([_foreign accounts_](), [_foreign assets_](), and [_foreign applications_]()) is
_available_.

- The transaction [_sender_]() (`snd`) is _available_.

- The Global Fields `CurrentApplicationID`, and `CurrentApplicationAddress` are _available_.

- Prior to Version 4, all Assets were considered _available_ to the `asset_holding_get`
opcode, and all Applications were _available_ to the `app_local_get_ex` opcode.

- Since Version 6, any Asset or Application created earlier in the same transaction
group (whether by a top-level or inner transaction) is _available_. In addition,
any Account associated with an Application created earlier in the group is _available_.

- Since Version 7, the Account associated with any Application in the _foreign applications_
field is _available_.
   
- Since Version 9, resources are shared and pooled at group-level. Any resource
available in _some_ top-level transaction in a transaction group is available in
_all_ Version 9 or later application calls in the group, whether those application
calls are top-level or inner.

- When considering whether an _asset holding_ or _application local state_ is _available_
by group-level resource sharing, the _holding_ or _local state_ **MUST BE** _available_
in a top-level transaction _without_ considering group sharing.

{{#include ../_include/styles.md:example}}
> If account `A` is made available in one transaction, and asset `X` is made available
> in another, group resource sharing does _not_ make `A`'s `X` holding available.
     
- Top-level transactions that are not Application Calls also make resources _available_
to group-level resource sharing. The following resources are made _available_ by
other transaction types:

  1. [`pay`](): _sender_ (`snd`), _receiver_ (`rcv`), and _close-to_ (`close`) (if set).

  1. [`keyreg`](): _sender_ (`snd`).

  1. [`acfg`](): _sender_ (`snd`), _configured asset_ (`caid`), and the _configured
  asset holding_ of the _sender_.

  1. [`axfer`](): _sender_ (`snd`), _asset receiver_ (`arcv`), _asset sender_ (`asnd`)
  (if set), _asset close-to_ (`aclose`) (if set), _transferred asset_ (`xaid`), and
  the _transferred asset holding_ of each of those accounts.

  1. [`afrz`](): _sender_ (`snd`), _freeze account_ (`fadd`), _freeze asset_ (`faid`),
  and the _freeze asset holding_ of the _freeze account_. The _freeze asset holding_
  of the _sender_ is _not_ made available.

- A Box is _available_ to an Approval Program if _any_ transaction in the same group
contains a [box reference]() (`apbx`) that denotes the box. A box reference contains
an index `i`, and name `n`. The index refers to the `i`-th application in the transaction's
_foreign applications_ array, with the usual convention that `0` indicates the application
ID of the Application called by that transaction. No box is ever _available_ to a
Clear State Program.

Regardless of _availability_, any attempt to access an Asset or Application with
an ID less than \\( 256 \\) from within an Application will fail immediately. This
avoids any ambiguity in opcodes that interpret their integer arguments as resource
IDs _or_ indexes into the _foreign assets_ or _foreign applications_ arrays.

It is **RECOMMENDED** that Application authors avoid supplying array indexes to these 
opcodes, and always use explicit resource IDs. By using explicit IDs, contracts will
better take advantage of group resource sharing. The array indexing interpretation
**MAY** be deprecated in a future version.