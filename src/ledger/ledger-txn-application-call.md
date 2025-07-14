# Application Call Transaction

## Fields

An _application call_ transaction additionally has the following fields:

- The _application ID_, encoded as msgpack field `apid`, is a 64-bit unsigned integer
that identifies the application being called. If the _application ID_ is omitted
(zero), this transaction is _creating_ an application.

- The _on completion action_, encoded as msgpack field `apan`, is a 64-bit unsigned
integer that specifies an additional effect of this transaction on the application’s
state in the _sender_ or _application creator’s_ account data. This field may take
on one of the following values:

|        ACTION         | VALUE | EFFECT                                                                                                                                                                                                                                                |
|:---------------------:|:-----:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|       `NoOpOC`        |  `0`  | _Only_ execute the `ApprovalProgram` associated with this _application ID_, with no additional effects.                                                                                                                                               |
|       `OptInOC`       |  `1`  | _Before_ executing the `ApprovalProgram`, allocate _local state_ for this _application ID_ into the _sender_’s account data.                                                                                                                          |
|     `CloseOutOC`      |  `2`  | _After_ executing the `ApprovalProgram`, clear any _local state_ for this _application ID_ out of the _sender_’s account data.                                                                                                                        |
|    `ClearStateOC`     |  `3`  | _Do not_ execute the `ApprovalProgram`, and instead execute the `ClearStateProgram` (which may not reject this transaction). Additionally, clear any _local state_ for this _application ID_ out of the _sender_’s account data (as in `CloseOutOC`). |
| `UpdateApplicationOC` |  `4`  | _After_ executing the `ApprovalProgram`, _replace_ the `ApprovalProgram` and `ClearStateProgram` associated with this _application ID_ with the programs specified in this transaction.                                                               |
| `DeleteApplicationOC` |  `5`  | _After_ executing the `ApprovalProgram`, _delete_ the parameters of with this _application ID_ from the account data of the application’s creator.                                                                                                    |

- The _application arguments_, encoded as msgpack field `apaa`, is an **OPTIONAL**
list of byte-arrays. There **MUST NOT** be more than \\( \MaxAppArgs \\) entries
in this list, and the sum of their lengths in bytes **MUST NOT** exceed \\( \MaxAppTotalArgLen \\).

- The _foreign accounts_, encoded as msgpack field `apat`, is **OPTIONAL** list of
accounts, besides the _sender_, whose _local states_ **MAY** be referred to by executing
the `ApprovalProgram` or the `ClearStateProgram`. These accounts are referred to
by their 32-byte addresses. There **MUST NOT** be more than \\( \MaxAppTxnAccounts \\)
entries in this list.

- The _foreign application IDs_, encoded as msgpack field `apfa`, is an **OPTIONAL**
list of _application IDs_, besides the application whose `ApprovalProgram` or `ClearStateProgram`
is executing, that the executing program **MAY** read _global state_ from. These
applications are referred to by their 64-bit unsigned integer IDs. There **MUST NOT**
be more than \\( \MaxAppTxnForeignApps \\) entries in this list.

- The _foreign asset IDs_, encoded as msgpack field `apas`, is an **OPTIONAL** list
of _asset IDs_, that the executing `ApprovalProgram` or `ClearStateProgram` **MAY**
read _asset parameters_ from. These assets are referred to by their 64-bit unsigned
integer IDs. There **MUST NOT** be more than \\( \MaxAppTxnForeignAssets \\) entries
in this list.

- The _box references_, encoded as msgpack field `apbx`, is an **OPTIONAL** list
of _boxes_, that the executing program or any other program in the same group **MAY**
access for reading or writing when the _box reference_ matches the running program
_application IDs_. These _boxes_ are referred to by a msgpack object containing:

  - A 64-bit unsigned integer index (`i`),
  - A byte-array name (`n`).
  
The index (`i`) is a \\( 1 \\)-based index in the _foreign application IDs_ (`apfa`)
list. A \\( 0 \\) index is interpreted as the _application ID_ of this transaction
(`apid`, or the ID allocated for the created application when `apid` is 0). There
**MUST NOT** be more than \\( \MaxAppBoxReferences \\) entries in this list.

- The _local state schema_, encoded as msgpack field `apls`, is a msgpack object
containing:

  - A 64-bit unsigned integer, encoded as msgpack field `nui`, representing the
  number of _local_ 64-bit unsigned integer variables for the application,
  - A 64-bit unsigned integer, encoded as msgpack field `nbs`, representing the
  number of _local_ byte-array variables for the application,
  
  This field is only used during application creation, and sets bounds on the size
of the _local state_ for accounts that opt in to this application. There **MUST NOT**
be more than \\( \MaxLocalSchemaEntries \\) _local_ variables for the application.

- The _global state schema_, encoded as msgpack field `apgs`, is a msgpack object
containing:

  - A 64-bit unsigned integer, encoded as msgpack field `nui`, representing the
  number of _global_ 64-bit unsigned integer variables for the application,
  - A 64-bit unsigned integer, encoded as msgpack field `nbs`, representing the
  number of _global_ byte-array variables for the application.
  
  This field is only used during application creation, and sets bounds on the size
of the _global state_ associated with this application. There **MUST NOT** be more 
than \\( \MaxGlobalSchemaEntries \\) _global_ variables for the application. 

- The _extra program pages_, encoded as msgpack field `apep`, is a 32-bit unsigned
integer representing the number of _program pages_ besides the first one. A _program
page_ is a chunk of application bytecode whose length in bytes **MUST NOT** exceed
\\( \MaxAppProgramLen \\). This field is only used during application creation, and
requests an increased maximum size for the `ApprovalProgram` or `ClearStateProgram`
programs.

- The _approval program_, encoded as msgpack field `apap`, is a byte-array containing
the approval program bytecode. This field is used for application creation and updates,
and sets the corresponding application’s `ApprovalProgram`.

- The _clear state program_, encoded as msgpack field `apsu`, is a byte-array containing
the clear state program bytecode. This field is used for application creation and
updates, and sets the corresponding application’s `ClearStateProgram`.
  - The `ApprovalProgram` and the `ClearStateProgram` **MUST** have the same version
  number if either is \\( 6 \\) or higher.

Furthermore, the sum of the number of _foreign accounts_ in `apat`, _foreign application 
IDs_ in `apfa`, _foreign asset IDs_ in `apas`, and _box references_ in `apbx` **MUST
NOT** exceed \\( \MaxAppTotalTxnReferences \\).

## Validation

TODO

## Semantic

TODO