$$
\newcommand \App {\mathrm{App}}
\newcommand \MaxAppTotalTxnReferences {\App_{r,\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
\newcommand \MaxAppProgramLen {\App_{\mathrm{prog},\max}}
\newcommand \MaxGlobalSchemaEntries {\App_{\mathrm{GS},\max}}
\newcommand \MaxLocalSchemaEntries {\App_{\mathrm{LS},\max}}
\newcommand \MaxAppArgs {\App_{\mathrm{arg},\max}}
\newcommand \MaxAppTotalArgLen {\App_{\mathrm{ay},\max}}
\newcommand \MaxAppTxnAccounts {\App_{\mathrm{acc},\max}}
\newcommand \MaxAppTxnForeignApps {\App_{\mathrm{app},\max}}
\newcommand \MaxAppTxnForeignAssets {\App_{\mathrm{asa},\max}}
\newcommand \Box {\mathrm{Box}}
\newcommand \MaxAppBoxReferences {\App_{\Box,\max}}
\newcommand \MaxAppKeyLen {\App_{\mathrm{k},\max}}
$$

# Application Call Transaction

## Fields

An _application call_ transaction additionally has the following fields:

| FIELD                | CODEC  |    TYPE     |         REQUIRED          |
|:---------------------|:------:|:-----------:|:-------------------------:|
| Application ID       | `apid` |  `uint64`   | Yes (except for Creation) |
| On Completion Action | `apan` |  `uint64`   |            Yes            |
| Approval Program     | `apap` |  `[]byte`   |            No             |
| Clear State Program  | `apsu` |  `[]byte`   |            No             |
| Extra Program Pages  | `apep` |  `uint64`   |            No             |
| Global State Schema  | `apgs` |  `struct`   |            No             |
| Local State Schema   | `apls` |  `struct`   |            No             |
| Arguments            | `apaa` | `[][]byte`  |            No             |
| Foreign Accounts     | `apat` | `[]address` |            No             |
| Foreign Applications | `apfa` | `[]uint64`  |            No             |
| Foreign Assets       | `apas` | `[]uint64`  |            No             |
| Box References       | `apbx` | `[]struct`  |            No             |

The sum of the number of _foreign accounts_ in `apat`, _foreign application_ in `apfa`,
_foreign asset_ in `apas`, and _box references_ in `apbx` **MUST NOT** exceed \\( \MaxAppTotalTxnReferences \\).

### Application ID

The _application ID_ identifies the application being called.

> If the _application ID_ is omitted (zero), this transaction is _creating_ an application.

### On Completion Action

The _on completion action_ specifies an additional effect of this transaction on
the application’s state in the _sender_ or _application creator’s_ account data.

The `apan` field values are enumerated as follows:

|        ACTION         | VALUE | EFFECT                                                                                                                                                                                                                                               |
|:---------------------:|:-----:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|       `NoOpOC`        |  `0`  | _Only_ execute the Approval Program associated with this _application ID_, with no additional effects.                                                                                                                                               |
|       `OptInOC`       |  `1`  | _Before_ executing the Approval Program, allocate _local state_ for this _application ID_ into the _sender_’s account data.                                                                                                                          |
|     `CloseOutOC`      |  `2`  | _After_ executing the Approval Program, clear any _local state_ for this _application ID_ out of the _sender_’s account data.                                                                                                                        |
|    `ClearStateOC`     |  `3`  | _Do not_ execute the Approval Program, and instead execute the Clear State Program (which may not reject this transaction). Additionally, clear any _local state_ for this _application ID_ out of the _sender_’s account data (as in `CloseOutOC`). |
| `UpdateApplicationOC` |  `4`  | _After_ executing the Approval Program, _replace_ the Approval Program and Clear State Program associated with this _application ID_ with the programs specified in this transaction.                                                                |
| `DeleteApplicationOC` |  `5`  | _After_ executing the Approval Program, _delete_ the parameters of with this _application ID_ from the account data of the application’s creator.                                                                                                    |


### Approval Program

The _approval program_ (**OPTIONAL**) contains the approval program bytecode.

> This field is used for _application creation_ and _updates_, and sets the corresponding
> application’s Approval Program.

### Clear State Program

The _clear state program_ (**OPTIONAL**) contains the clear state program bytecode.

> This field is used for _application creation_ and _updates_, and sets the corresponding
> application’s Clear State Program.

- The Approval Program and the Clear State Program **MUST** have the same version
number if either is \\( 6 \\) or higher.

### Extra Program Pages

A _program page_ (**OPTIONAL**) is a chunk of application program bytecode. The
_extra program pages_ define the number of _program pages_ besides the first one. 

> This field is only used during _application creation_, and requests an increased
> maximum size for the Approval Program or Clear State Program.

- There **MUST NOT** be more than \\( \MaxExtraAppProgramPages \\) _extra program
pages_,

- The _program page_ byte length **MUST NOT** exceed \\( \MaxAppProgramLen \\).

### Global State Schema

The _global state schema_ (**OPTIONAL**) defines the _global_ state allocated into
the creator account that of the _application ID_.

The _global state schema_ is a structure containing:

| FIELD           | CODEC |   TYPE   | DESCRIPTION                                                                   |
|:----------------|:-----:|:--------:|:------------------------------------------------------------------------------|
| Number of Uints | `nui` | `uint64` | The number of _global_ 64-bit unsigned integer variables for the application. |
| Number of Bytes | `nbs` | `uint64` | The number of _global_ byte-array variables for the application.              |

> This field is only used during _application creation_, and sets bounds on the size
> of the _global state_ associated with this application.

- There **MUST NOT** be more than \\( \MaxGlobalSchemaEntries \\) _global_ variables
for the application.

TODO: Restrictions on key-value lengths

### Local State Schema

The _local state schema_ (**OPTIONAL**) defines the _local_ state allocated into
the accounts that opt-in the _application ID_.

The _local state schema_ is a structure containing:

| FIELD           | CODEC |   TYPE   | DESCRIPTION                                                                  |
|:----------------|:-----:|:--------:|:-----------------------------------------------------------------------------|
| Number of Uints | `nui` | `uint64` | The number of _local_ 64-bit unsigned integer variables for the application. |
| Number of Bytes | `nbs` | `uint64` | The number of _local_ byte-array variables for the application.              |

> This field is only used during _application creation_, and sets bounds on the size
> of the _local state_ for accounts that opt in to this application.

- There **MUST NOT** be more than \\( \MaxLocalSchemaEntries \\) _local_ variables
for the application.

TODO: Restrictions on key-value lengths

### Arguments

The _application arguments_ (**OPTIONAL**) list provides byte-array arguments to
the application being called.

- There **MUST NOT** be more than \\( \MaxAppArgs \\) entries in this list,

- The sum of their byte lengths **MUST NOT** exceed \\( \MaxAppTotalArgLen \\).

### Foreign Accounts

The _foreign accounts_ (**OPTIONAL**) list specifies the accounts, besides the _sender_,
whose _local states_ **MAY** be referred to by executing the Approval Program or
the Clear State Program. These accounts are referred to by their 32-byte addresses.

- There **MUST NOT** be more than \\( \MaxAppTxnAccounts \\) entries in this list.

### Foreign Applications

The _foreign applications_ (**OPTIONAL**) list specifies the _application IDs_,
besides the application whose Approval Program or Clear State Program is executing,
that the executing program **MAY** read _global state_ from. These applications
are referred to by their 64-bit unsigned integer IDs. 

- There **MUST NOT** be more than \\( \MaxAppTxnForeignApps \\) entries in this list.

### Foreign Assets

The _foreign assets_ (**OPTIONAL**) list specifies the _asset IDs_ from which the
executing Approval Program or Clear State Program **MAY** read _asset parameters_.
These assets are referred to by their 64-bit unsigned integer IDs.

- There **MUST NOT** be more than \\( \MaxAppTxnForeignAssets \\) entries in this
list.

### Box References

The _box references_ (**OPTIONAL**) list specifies the _boxes_ that the executing
Approval Program, or any other Approval Program in the same group, **MAY** access
for reading or writing when the _box reference_ matches the running program _application
IDs_.

The _box_ is a structure containing:

| FIELD | CODEC |   TYPE   | DESCRIPTION                                                          |
|:------|:-----:|:--------:|:---------------------------------------------------------------------|
| Index |  `i`  | `uint64` | A \\( 1 \\)-based index in the _foreign applications_ (`apfa`) list. |
| Name  |  `n`  | `[]byte` | The box identifier.                                                  |
 
> A \\( 0 \\) index (`i`) is interpreted as the _application ID_ of this transaction
> (`apid`, or the ID allocated for the created application when `apid` is \\( 0 \\)).

- There **MUST NOT** be more than \\( \MaxAppBoxReferences \\) entries in this list.

- The _box name_ byte length **MUST NOT** exceed \\( \MaxAppKeyLen \\).

## Validation

 - The _on completion action_ **MUST** be a valid value.
 - The _approval program_ and _clear state program_ **MUST NOT** be supplied unless the _application id_ is \\( 0 \\) or when the _on completion action_ is \\( 4 \\).
 - The _local state_, _global state_, and _extra program pages_ **MUST NOT** be supplied unless the _application id_ is \\( 0 \\)
 - The _application arguments_ **MUST NOT** exceed \\( \MaxAppArgs \\) entries.
 - The sum of all _application arguments_ bytes **MUST NOT** exceed \\( \MaxAppTotalArgLen \\).
 - The number of _foreign accounts_ **MUST NOT** exceed \\( \MaxAppTxnAccounts \\).
 - The number of _foreign applications_ **MUST NOT** exceed \\( \MaxAppTxnForeignApps \\).
 - The number of _foreign assets_ **MUST NOT** exceed \\( \MaxAppTxnForeignAssets \\).
 - The number of _boxes_ **MUST NOT** exceed \\( \MaxAppBoxReferences \\).
 - The sum of all _foreign accounts_, _foreign applications_, _foreign assets_, and _boxes_ **MUST NOT** exceed \\( \MaxAppTotalTxnReferences \\).
 - The _extra program pages_ **MUST NOT** exceed \\( \MaxExtraAppProgramPages \\).
 - The _approval program_ **MUST NOT** be supplied unless the _application id_ is \\( 0 \\) or when the _on completion action_ is \\( 4 \\).
 - The _approval program_ byte length **MUST NOT** exceed _extra program pages_ * MaxAppProgramLen.
 - The _clear state program_ byte length **MUST NOT** exceed _extra program pages_ * MaxAppProgramLen.
 - The sum of the _approval program_ byte length and _clear state program_ byte length **MUST NOT** exceed _extra program pages_ * MaxAppTotalProgramLen.
 - All _boxes_ **MUST** be supplied with an index no greater than the number of _foreign applications_ entries.
 - All _boxes_ **MUST** be supplied with a name no longer than MaxAppKeyLen.
 - The _local state schema_ **MUST NOT** exceed MaxLocalSchemaEntries.
 - The _global state schema_ **MUST NOT** exceed MaxGlobalSchemaEntries.

## Semantic

TODO
