$$
\newcommand \App {\mathrm{App}}
\newcommand \MaxAppProgramCost {\App_{c,\max}}
\newcommand \ExtraProgramPages {\mathrm{ExtraProgramPages}}
\newcommand \MaxGlobalSchemaEntries {\App_{\mathrm{GS},\max}}
\newcommand \MaxLocalSchemaEntries {\App_{\mathrm{LS},\max}}
\newcommand \MaxAppTotalProgramLen {\App_{\mathrm{prog},t,\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
\newcommand \MinBalance {b_\min}
\newcommand \AppFlatOptInMinBalance {\App_{\mathrm{optin},\MinBalance}}
\newcommand \AppFlatParamsMinBalance {\App_{\mathrm{create},\MinBalance}}
\newcommand \MaxAppKeyLen {\App_{\mathrm{k},\max}}
\newcommand \SchemaBytesMinBalance {\App_{\mathrm{b},\MinBalance}}
\newcommand \SchemaMinBalancePerEntry {\App_{\mathrm{s},\MinBalance}}
\newcommand \SchemaUintMinBalance {\App_{\mathrm{u},\MinBalance}}
\newcommand \Box {\mathrm{Box}}
\newcommand \MaxBoxSize {\Box_\max}
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

  - For AVM Version 3 or lower, the program’s cost as determined by the Stateful `Check`
  function **MUST NOT** exceed \\( \MaxAppProgramCost \\).

  - For AVM Version 4 or higher programs, the program’s cost during execution **MUST NOT**
  exceed \\( \MaxAppProgramCost \\).

- A mutable stateful “Clear State” program (`ClearStateProgram`), executed when an
opted-in user forcibly removes the local application state associated with this
application from their account data. This happens when an `ApplicationCall` transaction
referring to this application ID is executed with `OnCompletion == ClearState`.
This program, when executed, is not permitted to cause the transaction to fail.
This program may modify the local or global state associated with this application.
This field is encoded with msgpack field `clearp`.

  - For AVM Version 3 or lower, the program’s cost as determined by the Stateful `Check`
  function **MUST NOT** exceed \\( \MaxAppProgramCost \\).

  - For AVM Version 4 or higher programs, the program’s cost during execution **MUST NOT**
  exceed \\( \MaxAppProgramCost \\).

- An immutable “global state schema” (`GlobalStateSchema`), which sets a limit on
the size of the global [Key/Value Store](#keyvalue-stores) that may be associated
with this application (see [State Schemas](#state-schemas)). This field is encoded
with msgpack field `gsch`.

  - The maximum number of values that this schema may permit is \\( \MaxGlobalSchemaEntries \\).

- An immutable “local state schema” (`LocalStateSchema`), which sets a limit on
the size of a [Key/Value Store](#keyvalue-stores) that this application will allocate
in the account data of an account that has opted in (see ["State Schemas"](#state-schemas)).
This field is encoded with msgpack field `lsch`.

  - The maximum number of values that this schema may permit is \\( \MaxLocalSchemaEntries \\).

- An immutable “extra pages” value (`ExtraProgramPages`), which limits the total
size of the application programs. The sum of the lengths of `ApprovalProgram`
and `ClearStateProgram` may not exceed \\( \MaxAppTotalProgramLen \times (1+\ExtraProgramPages) \\)
bytes. This field is encoded with msgpack field `epp` and may not exceed \\( \MaxExtraAppProgramPages \\).
This `ExtraProgramPages` field is taken into account on application update as well.

- The “global state” (`GlobalState`) associated with this application, stored as
a [Key/Value Store](#keyvalue-stores). This field is encoded with msgpack field `gs`.

Each application created increases the minimum balance requirements of the creator
by \\( \AppFlatParamsMinBalance \times (1+\ExtraProgramPages) \\) μALGO, plus the
[`GlobalStateSchema` minimum balance contribution](#app-minimum-balance-changes).

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

$$
(\SchemaMinBalancePerEntry + \SchemaUintMinBalance) \times \mathrm{NumUint} + (\SchemaMinBalancePerEntry + \SchemaBytesMinBalance) \times \mathrm{NumByteSlice}
$$

When creating an application, there is a base minimum balance increase of
\\( \AppFlatParamsMinBalance \\) μALGO. There is an additional minimum balance increase
of \\( \AppFlatParamsMinBalance \times \ExtraProgramPages \\) μALGO. Finally,
there is an additional minimum balance increase, in μALGO, based on the `GlobalStateSchema`
for that application, described by the following formula:

$$
(\SchemaMinBalancePerEntry + \SchemaUintMinBalance) \times \mathrm{NumUint} + (\SchemaMinBalancePerEntry + \SchemaBytesMinBalance) \times \mathrm{NumByteSlice}
$$

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