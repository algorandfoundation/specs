---
numbersections: true
title: "Algorand Transaction Execution Approval Language"
date: \today
abstract: >
  Algorand allows transactions to be effectively signed by a small program. If the program evaluates to true then the transaction is allowed. This document defines the language and bytecode format.
---

# The Algorand Virtual Machine (AVM) and TEAL.

The AVM is a bytecode based stack interpreter that executes programs
associated with Algorand transactions. TEAL is an assembly language
syntax for specifying a program that is ultimately converted to AVM
bytecode. These programs can be used to check the parameters of the
transaction and approve the transaction as if by a signature. This use
is called a _Smart Signature_. Starting with v2, these programs may
also execute as _Smart Contracts_, which are often called
_Applications_. Contract executions are invoked with explicit
application call transactions.

Programs have read-only access to the transaction they are attached
to, the other transactions in their atomic transaction group, and a
few global values. In addition, _Smart Contracts_ have access to
limited state that is global to the application, per-account local
state for each account that has opted-in to the application, and
additional per-application arbitrary state in named _boxes_. For both types of
program, approval is signaled by finishing with the stack containing a
single non-zero uint64 value, though `return` can be used to signal an
early approval which approves based only upon the top stack value
being a non-zero uint64 value.

#### Transaction Fields
##### Scalar Fields
| Index | Name | Type | In | Notes |
| - | ------ | -- | - | --------- |
| 0 | Sender | address |      | 32 byte address |
| 1 | Fee | uint64 |      | microalgos |
| 2 | FirstValid | uint64 |      | round number |
| 3 | FirstValidTime | uint64 | v7  | UNIX timestamp of block before txn.FirstValid. Fails if negative |
| 4 | LastValid | uint64 |      | round number |
| 5 | Note | []byte |      | Any data up to 1024 bytes |
| 6 | Lease | [32]byte |      | 32 byte lease value |
| 7 | Receiver | address |      | 32 byte address |
| 8 | Amount | uint64 |      | microalgos |
| 9 | CloseRemainderTo | address |      | 32 byte address |
| 10 | VotePK | [32]byte |      | 32 byte address |
| 11 | SelectionPK | [32]byte |      | 32 byte address |
| 12 | VoteFirst | uint64 |      | The first round that the participation key is valid. |
| 13 | VoteLast | uint64 |      | The last round that the participation key is valid. |
| 14 | VoteKeyDilution | uint64 |      | Dilution for the 2-level participation key |
| 15 | Type | []byte |      | Transaction type as bytes |
| 16 | TypeEnum | uint64 |      | Transaction type as integer |
| 17 | XferAsset | uint64 |      | Asset ID |
| 18 | AssetAmount | uint64 |      | value in Asset's units |
| 19 | AssetSender | address |      | 32 byte address. Source of assets if Sender is the Asset's Clawback address. |
| 20 | AssetReceiver | address |      | 32 byte address |
| 21 | AssetCloseTo | address |      | 32 byte address |
| 22 | GroupIndex | uint64 |      | Position of this transaction within an atomic transaction group. A stand-alone transaction is implicitly element 0 in a group of 1 |
| 23 | TxID | [32]byte |      | The computed ID for this transaction. 32 bytes. |
| 24 | ApplicationID | uint64 | v2  | ApplicationID from ApplicationCall transaction |
| 25 | OnCompletion | uint64 | v2  | ApplicationCall transaction on completion action |
| 27 | NumAppArgs | uint64 | v2  | Number of ApplicationArgs |
| 29 | NumAccounts | uint64 | v2  | Number of Accounts |
| 30 | ApprovalProgram | []byte | v2  | Approval program |
| 31 | ClearStateProgram | []byte | v2  | Clear state program |
| 32 | RekeyTo | address | v2  | 32 byte Sender's new AuthAddr |
| 33 | ConfigAsset | uint64 | v2  | Asset ID in asset config transaction |
| 34 | ConfigAssetTotal | uint64 | v2  | Total number of units of this asset created |
| 35 | ConfigAssetDecimals | uint64 | v2  | Number of digits to display after the decimal place when displaying the asset |
| 36 | ConfigAssetDefaultFrozen | bool | v2  | Whether the asset's slots are frozen by default or not, 0 or 1 |
| 37 | ConfigAssetUnitName | []byte | v2  | Unit name of the asset |
| 38 | ConfigAssetName | []byte | v2  | The asset name |
| 39 | ConfigAssetURL | []byte | v2  | URL |
| 40 | ConfigAssetMetadataHash | [32]byte | v2  | 32 byte commitment to unspecified asset metadata |
| 41 | ConfigAssetManager | address | v2  | 32 byte address |
| 42 | ConfigAssetReserve | address | v2  | 32 byte address |
| 43 | ConfigAssetFreeze | address | v2  | 32 byte address |
| 44 | ConfigAssetClawback | address | v2  | 32 byte address |
| 45 | FreezeAsset | uint64 | v2  | Asset ID being frozen or un-frozen |
| 46 | FreezeAssetAccount | address | v2  | 32 byte address of the account whose asset slot is being frozen or un-frozen |
| 47 | FreezeAssetFrozen | bool | v2  | The new frozen value, 0 or 1 |
| 49 | NumAssets | uint64 | v3  | Number of Assets |
| 51 | NumApplications | uint64 | v3  | Number of Applications |
| 52 | GlobalNumUint | uint64 | v3  | Number of global state integers in ApplicationCall |
| 53 | GlobalNumByteSlice | uint64 | v3  | Number of global state byteslices in ApplicationCall |
| 54 | LocalNumUint | uint64 | v3  | Number of local state integers in ApplicationCall |
| 55 | LocalNumByteSlice | uint64 | v3  | Number of local state byteslices in ApplicationCall |
| 56 | ExtraProgramPages | uint64 | v4  | Number of additional pages for each of the application's approval and clear state programs. An ExtraProgramPages of 1 means 2048 more total bytes, or 1024 for each program. |
| 57 | Nonparticipation | bool | v5  | Marks an account nonparticipating for rewards |
| 59 | NumLogs | uint64 | v5  | Number of Logs (only with `itxn` in v5). Application mode only |
| 60 | CreatedAssetID | uint64 | v5  | Asset ID allocated by the creation of an ASA (only with `itxn` in v5). Application mode only |
| 61 | CreatedApplicationID | uint64 | v5  | ApplicationID allocated by the creation of an application (only with `itxn` in v5). Application mode only |
| 62 | LastLog | []byte | v6  | The last message emitted. Empty bytes if none were emitted. Application mode only |
| 63 | StateProofPK | []byte | v6  | 64 byte state proof public key |
| 65 | NumApprovalProgramPages | uint64 | v7  | Number of Approval Program pages |
| 67 | NumClearStateProgramPages | uint64 | v7  | Number of ClearState Program pages |

##### Array Fields
| Index | Name | Type | In | Notes |
| - | ------ | -- | - | --------- |
| 26 | ApplicationArgs | []byte | v2  | Arguments passed to the application in the ApplicationCall transaction |
| 28 | Accounts | address | v2  | Accounts listed in the ApplicationCall transaction |
| 48 | Assets | uint64 | v3  | Foreign Assets listed in the ApplicationCall transaction |
| 50 | Applications | uint64 | v3  | Foreign Apps listed in the ApplicationCall transaction |
| 58 | Logs | []byte | v5  | Log messages emitted by an application call (only with `itxn` in v5). Application mode only |
| 64 | ApprovalProgramPages | []byte | v7  | Approval Program as an array of pages |
| 66 | ClearStateProgramPages | []byte | v7  | ClearState Program as an array of pages |


Additional details in the [opcodes document](TEAL_opcodes.md#txn) on the `txn` op.

**Global Fields**

Global fields are fields that are common to all the transactions in the group. In particular it includes consensus parameters.

| Index | Name | Type | In | Notes |
| - | ------ | -- | - | --------- |
| 0 | MinTxnFee | uint64 |      | microalgos |
| 1 | MinBalance | uint64 |      | microalgos |
| 2 | MaxTxnLife | uint64 |      | rounds |
| 3 | ZeroAddress | address |      | 32 byte address of all zero bytes |
| 4 | GroupSize | uint64 |      | Number of transactions in this atomic transaction group. At least 1 |
| 5 | LogicSigVersion | uint64 | v2  | Maximum supported version |
| 6 | Round | uint64 | v2  | Current round number. Application mode only. |
| 7 | LatestTimestamp | uint64 | v2  | Last confirmed block UNIX timestamp. Fails if negative. Application mode only. |
| 8 | CurrentApplicationID | uint64 | v2  | ID of current application executing. Application mode only. |
| 9 | CreatorAddress | address | v3  | Address of the creator of the current application. Application mode only. |
| 10 | CurrentApplicationAddress | address | v5  | Address that the current application controls. Application mode only. |
| 11 | GroupID | [32]byte | v5  | ID of the transaction group. 32 zero bytes if the transaction is not part of a group. |
| 12 | OpcodeBudget | uint64 | v6  | The remaining cost that can be spent by opcodes in this program. |
| 13 | CallerApplicationID | uint64 | v6  | The application ID of the application that called this application. 0 if this application is at the top-level. Application mode only. |
| 14 | CallerApplicationAddress | address | v6  | The application address of the application that called this application. ZeroAddress if this application is at the top-level. Application mode only. |
| 15 | AssetCreateMinBalance | uint64 | v10  | The additional minimum balance required to create (and opt-in to) an asset. |
| 16 | AssetOptInMinBalance | uint64 | v10  | The additional minimum balance required to opt-in to an asset. |
| 17 | GenesisHash | [32]byte | v10  | The Genesis Hash for the network. |
| 18 | PayoutsEnabled | bool | v11  | Whether block proposal payouts are enabled. |
| 19 | PayoutsGoOnlineFee | uint64 | v11  | The fee required in a keyreg transaction to make an account incentive eligible. |
| 20 | PayoutsPercent | uint64 | v11  | The percentage of transaction fees in a block that can be paid to the block proposer. |
| 21 | PayoutsMinBalance | uint64 | v11  | The minimum balance an account must have in the agreement round to receive block payouts in the proposal round. |
| 22 | PayoutsMaxBalance | uint64 | v11  | The maximum balance an account can have in the agreement round to receive block payouts in the proposal round. |


**Asset Fields**

Asset fields include `AssetHolding` and `AssetParam` fields that are used in the `asset_holding_get` and `asset_params_get` opcodes.

| Index | Name | Type | Notes |
| - | ------ | -- | --------- |
| 0 | AssetBalance | uint64 | Amount of the asset unit held by this account |
| 1 | AssetFrozen | bool | Is the asset frozen or not |


| Index | Name | Type | In | Notes |
| - | ------ | -- | - | --------- |
| 0 | AssetTotal | uint64 |      | Total number of units of this asset |
| 1 | AssetDecimals | uint64 |      | See AssetParams.Decimals |
| 2 | AssetDefaultFrozen | bool |      | Frozen by default or not |
| 3 | AssetUnitName | []byte |      | Asset unit name |
| 4 | AssetName | []byte |      | Asset name |
| 5 | AssetURL | []byte |      | URL with additional info about the asset |
| 6 | AssetMetadataHash | [32]byte |      | Arbitrary commitment |
| 7 | AssetManager | address |      | Manager address |
| 8 | AssetReserve | address |      | Reserve address |
| 9 | AssetFreeze | address |      | Freeze address |
| 10 | AssetClawback | address |      | Clawback address |
| 11 | AssetCreator | address | v5  | Creator address |


**App Fields**

App fields used in the `app_params_get` opcode.

| Index | Name | Type | Notes |
| - | ------ | -- | --------- |
| 0 | AppApprovalProgram | []byte | Bytecode of Approval Program |
| 1 | AppClearStateProgram | []byte | Bytecode of Clear State Program |
| 2 | AppGlobalNumUint | uint64 | Number of uint64 values allowed in Global State |
| 3 | AppGlobalNumByteSlice | uint64 | Number of byte array values allowed in Global State |
| 4 | AppLocalNumUint | uint64 | Number of uint64 values allowed in Local State |
| 5 | AppLocalNumByteSlice | uint64 | Number of byte array values allowed in Local State |
| 6 | AppExtraProgramPages | uint64 | Number of Extra Program Pages of code space |
| 7 | AppCreator | address | Creator address |
| 8 | AppAddress | address | Address for which this application has authority |


**Account Fields**

Account fields used in the `acct_params_get` opcode.

| Index | Name | Type | In | Notes |
| - | ------ | -- | - | --------- |
| 0 | AcctBalance | uint64 |      | Account balance in microalgos |
| 1 | AcctMinBalance | uint64 |      | Minimum required balance for account, in microalgos |
| 2 | AcctAuthAddr | address |      | Address the account is rekeyed to. |
| 3 | AcctTotalNumUint | uint64 | v8  | The total number of uint64 values allocated by this account in Global and Local States. |
| 4 | AcctTotalNumByteSlice | uint64 | v8  | The total number of byte array values allocated by this account in Global and Local States. |
| 5 | AcctTotalExtraAppPages | uint64 | v8  | The number of extra app code pages used by this account. |
| 6 | AcctTotalAppsCreated | uint64 | v8  | The number of existing apps created by this account. |
| 7 | AcctTotalAppsOptedIn | uint64 | v8  | The number of apps this account is opted into. |
| 8 | AcctTotalAssetsCreated | uint64 | v8  | The number of existing ASAs created by this account. |
| 9 | AcctTotalAssets | uint64 | v8  | The numbers of ASAs held by this account (including ASAs this account created). |
| 10 | AcctTotalBoxes | uint64 | v8  | The number of existing boxes created by this account's app. |
| 11 | AcctTotalBoxBytes | uint64 | v8  | The total number of bytes used by this account's app's box keys and values. |
| 12 | AcctIncentiveEligible | bool | v11  | Has this account opted into block payouts |
| 13 | AcctLastProposed | uint64 | v11  | The round number of the last block this account proposed. |
| 14 | AcctLastHeartbeat | uint64 | v11  | The round number of the last block this account sent a heartbeat. |


### Flow Control

| Opcode | Description |
| - | -- |
| `err` | Fail immediately. |
| `bnz target` | branch to TARGET if value A is not zero |
| `bz target` | branch to TARGET if value A is zero |
| `b target` | branch unconditionally to TARGET |
| `return` | use A as success value; end |
| `pop` | discard A |
| `popn n` | remove N values from the top of the stack |
| `dup` | duplicate A |
| `dup2` | duplicate A and B |
| `dupn n` | duplicate A, N times |
| `dig n` | Nth value from the top of the stack. dig 0 is equivalent to dup |
| `bury n` | replace the Nth value from the top of the stack with A. bury 0 fails. |
| `cover n` | remove top of stack, and place it deeper in the stack such that N elements are above it. Fails if stack depth <= N. |
| `uncover n` | remove the value at depth N in the stack and shift above items down so the Nth deep value is on top of the stack. Fails if stack depth <= N. |
| `frame_dig i` | Nth (signed) value from the frame pointer. |
| `frame_bury i` | replace the Nth (signed) value from the frame pointer in the stack with A |
| `swap` | swaps A and B on stack |
| `select` | selects one of two values based on top-of-stack: B if C != 0, else A |
| `assert` | immediately fail unless A is a non-zero number |
| `callsub target` | branch unconditionally to TARGET, saving the next instruction on the call stack |
| `proto a r` | Prepare top call frame for a retsub that will assume A args and R return values. |
| `retsub` | pop the top instruction from the call stack and branch to it |
| `switch target ...` | branch to the Ath label. Continue at following instruction if index A exceeds the number of labels. |
| `match target ...` | given match cases from A[1] to A[N], branch to the Ith label where A[I] = B. Continue to the following instruction if no matches are found. |

### State Access

| Opcode | Description |
| - | -- |
| `balance` | balance for account A, in microalgos. The balance is observed after the effects of previous transactions in the group, and after the fee for the current transaction is deducted. Changes caused by inner transactions are observable immediately following `itxn_submit` |
| `min_balance` | minimum required balance for account A, in microalgos. Required balance is affected by ASA, App, and Box usage. When creating or opting into an app, the minimum balance grows before the app code runs, therefore the increase is visible there. When deleting or closing out, the minimum balance decreases after the app executes. Changes caused by inner transactions or box usage are observable immediately following the opcode effecting the change. |
| `app_opted_in` | 1 if account A is opted in to application B, else 0 |
| `app_local_get` | local state of the key B in the current application in account A |
| `app_local_get_ex` | X is the local state of application B, key C in account A. Y is 1 if key existed, else 0 |
| `app_global_get` | global state of the key A in the current application |
| `app_global_get_ex` | X is the global state of application A, key B. Y is 1 if key existed, else 0 |
| `app_local_put` | write C to key B in account A's local state of the current application |
| `app_global_put` | write B to key A in the global state of the current application |
| `app_local_del` | delete key B from account A's local state of the current application |
| `app_global_del` | delete key A from the global state of the current application |
| `asset_holding_get f` | X is field F from account A's holding of asset B. Y is 1 if A is opted into B, else 0 |
| `asset_params_get f` | X is field F from asset A. Y is 1 if A exists, else 0 |
| `app_params_get f` | X is field F from app A. Y is 1 if A exists, else 0 |
| `acct_params_get f` | X is field F from account A. Y is 1 if A owns positive algos, else 0 |
| `voter_params_get f` | X is field F from online account A as of the balance round: 320 rounds before the current round. Y is 1 if A had positive algos online in the agreement round, else Y is 0 and X is a type specific zero-value |
| `online_stake` | the total online stake in the agreement round |
| `log` | write A to log state of the current application |
| `block f` | field F of block A. Fail unless A falls between txn.LastValid-1002 and txn.FirstValid (exclusive) |

### Box Access

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

| Opcode | Description |
| - | -- |
| `box_create` | create a box named A, of length B. Fail if the name A is empty or B exceeds 32,768. Returns 0 if A already existed, else 1 |
| `box_extract` | read C bytes from box A, starting at offset B. Fail if A does not exist, or the byte range is outside A's size. |
| `box_replace` | write byte-array C into box A, starting at offset B. Fail if A does not exist, or the byte range is outside A's size. |
| `box_splice` | set box A to contain its previous bytes up to index B, followed by D, followed by the original bytes of A that began at index B+C. |
| `box_del` | delete box named A if it exists. Return 1 if A existed, 0 otherwise |
| `box_len` | X is the length of box A if A exists, else 0. Y is 1 if A exists, else 0. |
| `box_get` | X is the contents of box A if A exists, else ''. Y is 1 if A exists, else 0. |
| `box_put` | replaces the contents of box A with byte-array B. Fails if A exists and len(B) != len(box A). Creates A if it does not exist |
| `box_resize` | change the size of box named A to be of length B, adding zero bytes to end or removing bytes from the end, as needed. Fail if the name A is empty, A is not an existing box, or B exceeds 32,768. |

### Inner Transactions

The following opcodes allow for "inner transactions". Inner
transactions allow stateful applications to have many of the effects
of a true top-level transaction, programmatically.  However, they are
different in significant ways.  The most important differences are
that they are not signed, duplicates are not rejected, and they do not
appear in the block in the usual away. Instead, their effects are
noted in metadata associated with their top-level application
call transaction.  An inner transaction's `Sender` must be the
SHA512_256 hash of the application ID (prefixed by "appID"), or an
account that has been rekeyed to that hash.

In v5, inner transactions may perform `pay`, `axfer`, `acfg`, and
`afrz` effects.  After executing an inner transaction with
`itxn_submit`, the effects of the transaction are visible beginning
with the next instruction with, for example, `balance` and
`min_balance` checks. In v6, inner transactions may also perform
`keyreg` and `appl` effects. Inner `appl` calls fail if they attempt
to invoke a program with version less than v4, or if they attempt to
opt-in to an app with a ClearState Program less than v4.

In v5, only a subset of the transaction's header fields may be set: `Type`/`TypeEnum`,
`Sender`, and `Fee`. In v6, header fields `Note` and `RekeyTo` may
also be set.  For the specific (non-header) fields of each transaction
type, any field may be set.  This allows, for example, clawback
transactions, asset opt-ins, and asset creates in addition to the more
common uses of `axfer` and `acfg`.  All fields default to the zero
value, except those described under `itxn_begin`.

Fields may be set multiple times, but may not be read. The most recent
setting is used when `itxn_submit` executes. For this purpose `Type`
and `TypeEnum` are considered to be the same field. When using
`itxn_field` to set an array field (`ApplicationArgs` `Accounts`,
`Assets`, or `Applications`) each use adds an element to the end of
the array, rather than setting the entire array at once.

`itxn_field` fails immediately for unsupported fields, unsupported
transaction types, or improperly typed values for a particular
field. `itxn_field` makes acceptance decisions entirely from the field
and value provided, never considering previously set fields. Illegal
interactions between fields, such as setting fields that belong to two
different transaction types, are rejected by `itxn_submit`.

| Opcode | Description |
| - | -- |
| `itxn_begin` | begin preparation of a new inner transaction in a new transaction group |
| `itxn_next` | begin preparation of a new inner transaction in the same transaction group |
| `itxn_field f` | set field F of the current inner transaction to A |
| `itxn_submit` | execute the current inner transaction group. Fail if executing this group would exceed the inner transaction limit, or if any transaction in the group fails. |
| `itxn f` | field F of the last inner transaction |
| `itxna f i` | Ith value of the array field F of the last inner transaction |
| `itxnas f` | Ath value of the array field F of the last inner transaction |
| `gitxn t f` | field F of the Tth transaction in the last inner group submitted |
| `gitxna t f i` | Ith value of the array field F from the Tth transaction in the last inner group submitted |
| `gitxnas t f` | Ath value of the array field F from the Tth transaction in the last inner group submitted |
