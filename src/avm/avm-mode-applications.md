$$
\newcommand \App {\mathrm{App}}
\newcommand \MaxAppProgramCost {\App_{c,\max}}
\newcommand \MaxTxGroupSize {GT_\max}
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
a group, then the total execution cost of all such calls **MUST NOT** exceed
\\( n \times \MaxAppProgramCost \\).

In Version 6, inner Application Calls become possible, and each such call increases
the pooled opcode budget by \\( \MaxAppProgramCost \\) at the time the inner group
is submitted (with the `itxn_submit` opcode), allowing a maximum opcode budget of:

$$
\MaxTxGroupSize \times (1 + \MaxInnerTransactions) \times \MaxAppProgramCost = 190{,}400
$$

## Clear Program Execution

Executions of the Clear State Program are more stringent to ensure that Applications
may be closed out (by accounts) and have a chance to clean up their internal state.

At the beginning of a Clear State Program execution, the pooled budget available
**MUST** be \\( \MaxAppProgramCost \\) or higher. If it is not, the containing transaction
group fails without clearing the Application's state.

During the Clear State Program execution, no more than \\( \MaxAppProgramCost \\)
may be drawn. If further execution is attempted, the Clear State Program fails, and
the Application's state _is cleared_.

## Resource Availability

Applications have limits on the amount of blockchain state they may examine.

These limits are enforced by failing any opcode that attempts to access a resource
unless the resource is _available_. These resources are:

- _Accounts_, which **MUST** be available to access their balance, or other Account
parameters such as voting details.

- _Assets_, which **MUST** be available to access global asset parameters, such as
the asset's URL, name, or privileged addresses.

- _Holdings_, which **MUST** be available to access a particular Account's balance
or frozen status for a particular asset.

- _Applications_, which **MUST** be available to read an Application's programs,
parameters, or Global State.

- _Locals_, which **MUST** be available to read a particular Account's Local State
for a particular Application.

- _Boxes_, which **MUST** be available to read or write a box, designated by an
Application and name for the Box.

Resources are _available_ based on the contents of the executing transaction and,
in later versions, the contents of other transactions in the same group.

- A resource in the _foreign array_ fields of the [Application Call transaction]()
([_foreign accounts_](), [_foreign assets_](), and [_foreign applications_]()) is
_available_.

- The transaction [_sender_]() (`snd`) is _available_.

- The Global Fields `CurrentApplicationID`, and `CurrentApplicationAddress` are _available_.

- In pre-Version 4 programs, all Holdings are _available_ to the `asset_holding_get`
opcode, and all Locals are _available_ to the `app_local_get_ex` opcode if the Account
of the resource is _available_.

- In Version 6 (and later) programs, any Asset or Application created earlier
in the same transaction group (whether by a top-level or inner transaction) is _available_.
In addition, any Account that is the associated Account of an Application that was
created earlier in the group is _available_.

- In Version 7 (and later) programs, the Account associated with any Application
present in the [_foreign applications_ field](../ledger/ledger-txn-application-call.md#foreign-applications)
is _available_.

- In Version 4 (and later) programs, Holdings and Locals are _available_ if both
components of the resource are _available_ according to the above rules.

- In Version 9 (and later) programs, there is _group resource sharing_. Any
resource that is _available_ in _some_ top-level transaction in a group is _available_
in _all_ Version 9 or later Application calls in the group, whether those Application
calls are top-level or inner.

- Version 9 (and later) programs **MAY** use the [_transaction access list_]()
instead of the _foreign arrays_. When using the _transaction access list_, each resource
**MUST** be listed explicitly, since the _automatic availability_ of the _foreign
arrays_ is no longer provided, in particular:

  - Holdings and Locals are _no longer automatically available_ because their components
  are.

  - Application Accounts are _no longer automatically available_ because of the availability
  of their corresponding Applications.

However, the _transaction access list_ allows for the listing of more resources
than the _foreign arrays_. Listed resources become _available_ to other (post-Version 8
programs) Applications through _group resource sharing_.

- When considering whether a Holding or Local is _available_ by _group resource sharing_,
the Holding or Local **MUST** be _available_ in a top-level transaction based on
pre-Version 9 rules.

{{#include ../_include/styles.md:example}}
> If account `A` is made available in one transaction, and asset `X` is made available
> in another, _group resource sharing_ does _not_ make `A`'s `X` Holding available.
     
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
contains a [box reference]() (in transaction's _box references_ `apbx` or _access
list_ `al`) that denotes the Box. A _box reference_ contains an index `i`, and name
`n`. The index refers to the `i`-th Application in the transaction's _foreign applications_
or _access list_ array (only one of which can be used), with the usual convention that
`0` indicates the Application ID of the Application called by that transaction. No
Box is ever _available_ to a Clear State Program.

Regardless of _availability_, any attempt to access an Asset or Application with
an ID less than \\( 256 \\) from within an Application will fail immediately. This
avoids any ambiguity in opcodes that interpret their integer arguments as resource
IDs _or_ indexes into the _foreign assets_ or _foreign applications_ arrays.

It is **RECOMMENDED** that Application authors avoid supplying array indexes to these 
opcodes, and always use explicit resource IDs. By using explicit IDs, contracts will
better take advantage of group resource sharing.

The array indexing interpretation **MAY** be deprecated in a future program version.