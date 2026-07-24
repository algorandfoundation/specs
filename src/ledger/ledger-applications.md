$$
\newcommand \App {\mathrm{App}}
\newcommand \MaxAppProgramCost {\App_{c,\max}}
\newcommand \ExtraProgramPages {\mathrm{ExtraProgramPages}}
\newcommand \MaxGlobalSchemaEntries {\App_{\mathrm{GS},\max}}
\newcommand \MaxLocalSchemaEntries {\App_{\mathrm{LS},\max}}
\newcommand \MaxAppTotalProgramLen {\App_{\mathrm{prog},t,\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
\newcommand \MinBalance {b_{\min}}
\newcommand \AppFlatOptInMinBalance {\App_{\mathrm{optin},\MinBalance}}
\newcommand \AppFlatParamsMinBalance {\App_{\mathrm{create},\MinBalance}}
\newcommand \MaxAppKeyLen {\App_{\mathrm{k},\max}}
\newcommand \SchemaBytesMinBalance {\App_{\mathrm{b},\MinBalance}}
\newcommand \SchemaMinBalancePerEntry {\App_{\mathrm{s},\MinBalance}}
\newcommand \SchemaUintMinBalance {\App_{\mathrm{u},\MinBalance}}
\newcommand \Box {\mathrm{Box}}
\newcommand \MaxBoxSize {\Box_{\max}}
\newcommand \BoxByteMinBalance {\Box_{\mathrm{byte},\MinBalance}}
\newcommand \BoxFlatMinBalance {\Box_{\mathrm{flat},\MinBalance}}
$$

# Applications

Each account can create applications, each named by a globally-unique 64-bit unsigned
integer (the _application ID_).

Applications are associated with a set of _application parameters_, which can be
encoded as a msgpack struct:

- A mutable stateful “Approval” program (`ApprovalProgram`), whose result determines
whether an `ApplicationCall` transaction referring to this application ID is to be
allowed. This program executes for all `ApplicationCall` transactions referring
to this application ID except for those whose `OnCompletion == ClearState`, in which
case the `ClearStateProgram` is executed instead. This program may modify the local
or global state associated with this application. This field is encoded with msgpack
field `approv`.

  - For AVM Version 3 or lower, the program’s cost as determined by the Stateful
  `Check` function **MUST NOT** exceed \\( \MaxAppProgramCost \\).

  - For AVM Version 4 or higher programs, the program’s cost during execution **MUST
  NOT** exceed \\( \MaxAppProgramCost \\).

- A mutable stateful “Clear State” program (`ClearStateProgram`), executed when an
opted-in user forcibly removes the local application state associated with this
application from their account data. This happens when an `ApplicationCall` transaction
referring to this application ID is executed with `OnCompletion == ClearState`.
This program, when executed, is not permitted to cause the transaction to fail.
This program may modify the local or global state associated with this application.
This field is encoded with msgpack field `clearp`.

  - For AVM Version 3 or lower, the program’s cost as determined by the Stateful
  `Check` function **MUST NOT** exceed \\( \MaxAppProgramCost \\).

  - For AVM Version 4 or higher programs, the program’s cost during execution **MUST
  NOT** exceed \\( \MaxAppProgramCost \\).

- A “global state schema” (`GlobalStateSchema`), which sets a limit on
the size of the global [Key/Value Store](#keyvalue-stores) that may be associated
with this application (see [State Schemas](#state-schemas)). This field is encoded
with msgpack field `gsch`. It is set at creation and **MAY** be changed by an
[application update](./ledger-txn-semantics-application.md#step-6). It **MUST NOT**
be reduced below the application’s current global state usage.

  - The maximum number of values that this schema may permit is \\( \MaxGlobalSchemaEntries \\).

- An immutable “local state schema” (`LocalStateSchema`), which sets a limit on
the size of a [Key/Value Store](#keyvalue-stores) that this application will allocate
in the account data of an account that has opted in (see ["State Schemas"](#state-schemas)).
This field is encoded with msgpack field `lsch`. Unlike the global state schema, it
**MUST NOT** be changed after creation, because each opted-in account caches a copy
of it in order to compute its own minimum balance requirement.

  - The maximum number of values that this schema may permit is \\( \MaxLocalSchemaEntries \\).

- An “extra pages” value (`ExtraProgramPages`), which limits the total
size of the application programs. The sum of the lengths of `ApprovalProgram`
and `ClearStateProgram` may not exceed \\( \MaxAppTotalProgramLen \times (1+\ExtraProgramPages) \\)
bytes. This field is encoded with msgpack field `epp` and may not exceed \\( \MaxExtraAppProgramPages \\).
It is set at creation and **MAY** be changed by an
[application update](./ledger-txn-semantics-application.md#step-6), provided the
(possibly new) programs still fit within the (possibly new) page allowance.

- An “application version” (`Version`) value that begins at \\( 0 \\) when an Application
is created or when the _protocol version_ including this field goes into effect
whichever is later. This field is encoded with msgpack field `v`.

- The “global state” (`GlobalState`) associated with this application, stored as
a [Key/Value Store](#keyvalue-stores). This field is encoded with msgpack field `gs`.

- A “size sponsor” (`SizeSponsor`) account. When non-zero, it identifies the account
responsible for the minimum balance contributions of this application’s `ExtraProgramPages`
and `GlobalStateSchema`. When zero, the application’s creator bears those contributions.
This field is encoded with msgpack field `ss`, and is exposed to the AVM as the
`AppSizeSponsor` field of `app_params_get` (see [Size Sponsor](#size-sponsor)).

Each application created increases the minimum balance requirement of the creator
by \\( \AppFlatParamsMinBalance \times (1+\ExtraProgramPages) \\) μALGO, plus the
[`GlobalStateSchema` minimum balance contribution](#app-minimum-balance-changes).
When a later [application update](./ledger-txn-semantics-application.md#step-6) changes
these sizes, the portion of the requirement attributable to `ExtraProgramPages` and
`GlobalStateSchema` moves to the application’s [size sponsor](#size-sponsor).

Each application opted in to increases the minimum balance requirements of the opting-in
account by \\( \AppFlatOptInMinBalance \\) μALGO plus the [`LocalStateSchema` minimum
balance contribution](#app-minimum-balance-changes).

## Key/Value Stores

A Key/Value Store, or KV, is an associative array mapping _keys_ of type byte-array
to _values_ of type byte-array or 64-bit unsigned integer.

The values in a KV are either:

- `Bytes`, representing a byte-array,
- `Uint`, representing an unsigned 64-bit integer value.

The maximum length of a key in a KV is \\( \MaxAppKeyLen \\) bytes.

## State Schemas

A _state schema_ represents limits on the number of each value type that may appear
in a [Key/Value Store](#keyvalue-stores).

State schemas control the maximum size of global and local state KVs.

A state schema is composed of two fields:

- `NumUint` represents the maximum number of _integer values_ that may appear in
some KV.
- `NumByteSlice` represents the maximum number of _byte-array values_ that may appear
in some KV.

## App Minimum Balance Changes

When an account opts in to an application or creates an application, the minimum
balance requirements for that account increases. The minimum balance requirement
is decreased equivalently when an account closes out or deletes an app.

When opting in to an application, there is a base minimum balance increase of
\\( \AppFlatOptInMinBalance \\) μALGO. There is an additional minimum balance increase,
in μALGO, based on the `LocalStateSchema` for that application, described by the
following formula:

<!-- markdownlint-disable MD013 -->
$$
(\SchemaMinBalancePerEntry + \SchemaUintMinBalance) \times \mathrm{NumUint} + (\SchemaMinBalancePerEntry + \SchemaBytesMinBalance) \times \mathrm{NumByteSlice}
$$
<!-- markdownlint-enable MD013 -->

When creating an application, there is a base minimum balance increase of
\\( \AppFlatParamsMinBalance \\) μALGO. There is an additional minimum balance increase
of \\( \AppFlatParamsMinBalance \times \ExtraProgramPages \\) μALGO. Finally,
there is an additional minimum balance increase, in μALGO, based on the `GlobalStateSchema`
for that application, described by the following formula:

<!-- markdownlint-disable MD013 -->
$$
(\SchemaMinBalancePerEntry + \SchemaUintMinBalance) \times \mathrm{NumUint} + (\SchemaMinBalancePerEntry + \SchemaBytesMinBalance) \times \mathrm{NumByteSlice}
$$
<!-- markdownlint-enable MD013 -->

## Size Sponsor

The minimum balance contributions for an application’s `ExtraProgramPages` and
`GlobalStateSchema` are borne by a single account, its _size sponsor_. At creation,
that account is the creator, and the application’s `SizeSponsor` field is left zero
to signify this.

An [application update](./ledger-txn-semantics-application.md#step-6) **MAY** change
`ExtraProgramPages` and `GlobalStateSchema`. Because the account submitting the update
need not be the creator, the responsibility for these contributions follows the
account that most recently set the sizes:

- The contributions for the _former_ `ExtraProgramPages` and `GlobalStateSchema` are
removed from the current size sponsor (the account named by `SizeSponsor`, or the
creator when `SizeSponsor` is zero).

- The contributions for the _new_ `ExtraProgramPages` and `GlobalStateSchema` are added
to the account that submitted the update (the transaction’s _sender_), which becomes
the new size sponsor. `SizeSponsor` is set to that account, except that when the sender
is the creator, `SizeSponsor` is reset to zero.

As with any transaction, the update **FAILS** unless the resulting balances still
satisfy every affected account’s minimum balance requirement; in particular the sender
must be able to cover the contributions it takes on.

When the application is deleted, the contributions for its `ExtraProgramPages` and
`GlobalStateSchema` are released from the current size sponsor.

## Boxes

The Box store is an associative array mapping keys of type: `(uint64 x []byte)` to
values of type `[]byte`.

- The _key_ is a pair in which the first value corresponds to an Application ID,
and the second is a _box name_, \\( 1 \\) to \\( \MaxAppKeyLen \\) bytes in length.
Unlike Global/Local State keys, an empty array is not a valid Box name. However,
empty Box names may appear in transactions to increase the I/O budget or allow creation
of Boxes whose Application ID is not known at transaction group construction time
(see below).

- The _value_ is a byte-array of length not greater than \\( \MaxBoxSize \\).

When an application executes an opcode that creates, resizes, or destroys a box,
the minimum balance of the associated application account (whose address is the hash
of the application ID) is modified.

When a box with name \\( n \\) and size \\( s \\) is created, the minimum balance
requirement is raised by \\( \BoxFlatMinBalance + \BoxByteMinBalance \times (\mathrm{len}(n) + s) \\).
The same amount is decremented from the minimum balance when the box is destroyed.
