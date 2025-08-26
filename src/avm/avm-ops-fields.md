# Fields

## Transaction Fields

### Scalar Fields

| INDEX |           NAME            |   TYPE   | IN | DESCRIPTION                                                                                                                                                                  |
|:-----:|:-------------------------:|:--------:|:--:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|   0   |          Sender           | address  |    | 32 byte address                                                                                                                                                              |
|   1   |            Fee            |  uint64  |    | microalgos                                                                                                                                                                   |
|   2   |        FirstValid         |  uint64  |    | round number                                                                                                                                                                 |
|   3   |      FirstValidTime       |  uint64  | v7 | UNIX timestamp of block before txn.FirstValid. Fails if negative                                                                                                             |
|   4   |         LastValid         |  uint64  |    | round number                                                                                                                                                                 |
|   5   |           Note            |  []byte  |    | Any data up to 1024 bytes                                                                                                                                                    |
|   6   |           Lease           | [32]byte |    | 32 byte lease value                                                                                                                                                          |
|   7   |         Receiver          | address  |    | 32 byte address                                                                                                                                                              |
|   8   |          Amount           |  uint64  |    | microalgos                                                                                                                                                                   |
|   9   |     CloseRemainderTo      | address  |    | 32 byte address                                                                                                                                                              |
|  10   |          VotePK           | [32]byte |    | 32 byte address                                                                                                                                                              |
|  11   |        SelectionPK        | [32]byte |    | 32 byte address                                                                                                                                                              |
|  12   |         VoteFirst         |  uint64  |    | The first round that the participation key is valid.                                                                                                                         |
|  13   |         VoteLast          |  uint64  |    | The last round that the participation key is valid.                                                                                                                          |
|  14   |      VoteKeyDilution      |  uint64  |    | Dilution for the 2-level participation key                                                                                                                                   |
|  15   |           Type            |  []byte  |    | Transaction type as bytes                                                                                                                                                    |
|  16   |         TypeEnum          |  uint64  |    | Transaction type as integer                                                                                                                                                  |
|  17   |         XferAsset         |  uint64  |    | Asset ID                                                                                                                                                                     |
|  18   |        AssetAmount        |  uint64  |    | value in Asset's units                                                                                                                                                       |
|  19   |        AssetSender        | address  |    | 32 byte address. Source of assets if Sender is the Asset's Clawback address.                                                                                                 |
|  20   |       AssetReceiver       | address  |    | 32 byte address                                                                                                                                                              |
|  21   |       AssetCloseTo        | address  |    | 32 byte address                                                                                                                                                              |
|  22   |        GroupIndex         |  uint64  |    | Position of this transaction within an atomic transaction group. A stand-alone transaction is implicitly element 0 in a group of 1                                           |
|  23   |           TxID            | [32]byte |    | The computed ID for this transaction. 32 bytes.                                                                                                                              |
|  24   |       ApplicationID       |  uint64  | v2 | ApplicationID from ApplicationCall transaction                                                                                                                               |
|  25   |       OnCompletion        |  uint64  | v2 | ApplicationCall transaction on completion action                                                                                                                             |
|  27   |        NumAppArgs         |  uint64  | v2 | Number of ApplicationArgs                                                                                                                                                    |
|  29   |        NumAccounts        |  uint64  | v2 | Number of Accounts                                                                                                                                                           |
|  30   |      ApprovalProgram      |  []byte  | v2 | Approval program                                                                                                                                                             |
|  31   |     ClearStateProgram     |  []byte  | v2 | Clear state program                                                                                                                                                          |
|  32   |          RekeyTo          | address  | v2 | 32 byte Sender's new AuthAddr                                                                                                                                                |
|  33   |        ConfigAsset        |  uint64  | v2 | Asset ID in asset config transaction                                                                                                                                         |
|  34   |     ConfigAssetTotal      |  uint64  | v2 | Total number of units of this asset created                                                                                                                                  |
|  35   |    ConfigAssetDecimals    |  uint64  | v2 | Number of digits to display after the decimal place when displaying the asset                                                                                                |
|  36   | ConfigAssetDefaultFrozen  |   bool   | v2 | Whether the asset's slots are frozen by default or not, 0 or 1                                                                                                               |
|  37   |    ConfigAssetUnitName    |  []byte  | v2 | Unit name of the asset                                                                                                                                                       |
|  38   |      ConfigAssetName      |  []byte  | v2 | The asset name                                                                                                                                                               |
|  39   |      ConfigAssetURL       |  []byte  | v2 | URL                                                                                                                                                                          |
|  40   |  ConfigAssetMetadataHash  | [32]byte | v2 | 32 byte commitment to unspecified asset metadata                                                                                                                             |
|  41   |    ConfigAssetManager     | address  | v2 | 32 byte address                                                                                                                                                              |
|  42   |    ConfigAssetReserve     | address  | v2 | 32 byte address                                                                                                                                                              |
|  43   |     ConfigAssetFreeze     | address  | v2 | 32 byte address                                                                                                                                                              |
|  44   |    ConfigAssetClawback    | address  | v2 | 32 byte address                                                                                                                                                              |
|  45   |        FreezeAsset        |  uint64  | v2 | Asset ID being frozen or un-frozen                                                                                                                                           |
|  46   |    FreezeAssetAccount     | address  | v2 | 32 byte address of the account whose asset slot is being frozen or un-frozen                                                                                                 |
|  47   |     FreezeAssetFrozen     |   bool   | v2 | The new frozen value, 0 or 1                                                                                                                                                 |
|  49   |         NumAssets         |  uint64  | v3 | Number of Assets                                                                                                                                                             |
|  51   |      NumApplications      |  uint64  | v3 | Number of Applications                                                                                                                                                       |
|  52   |       GlobalNumUint       |  uint64  | v3 | Number of global state integers in ApplicationCall                                                                                                                           |
|  53   |    GlobalNumByteSlice     |  uint64  | v3 | Number of global state byteslices in ApplicationCall                                                                                                                         |
|  54   |       LocalNumUint        |  uint64  | v3 | Number of local state integers in ApplicationCall                                                                                                                            |
|  55   |     LocalNumByteSlice     |  uint64  | v3 | Number of local state byteslices in ApplicationCall                                                                                                                          |
|  56   |     ExtraProgramPages     |  uint64  | v4 | Number of additional pages for each of the application's approval and clear state programs. An ExtraProgramPages of 1 means 2048 more total bytes, or 1024 for each program. |
|  57   |     Nonparticipation      |   bool   | v5 | Marks an account nonparticipating for rewards                                                                                                                                |
|  59   |          NumLogs          |  uint64  | v5 | Number of Logs (only with `itxn` in v5). Application mode only                                                                                                               |
|  60   |      CreatedAssetID       |  uint64  | v5 | Asset ID allocated by the creation of an ASA (only with `itxn` in v5). Application mode only                                                                                 |
|  61   |   CreatedApplicationID    |  uint64  | v5 | ApplicationID allocated by the creation of an application (only with `itxn` in v5). Application mode only                                                                    |
|  62   |          LastLog          |  []byte  | v6 | The last message emitted. Empty bytes if none were emitted. Application mode only                                                                                            |
|  63   |       StateProofPK        |  []byte  | v6 | 64 byte state proof public key                                                                                                                                               |
|  65   |  NumApprovalProgramPages  |  uint64  | v7 | Number of Approval Program pages                                                                                                                                             |
|  67   | NumClearStateProgramPages |  uint64  | v7 | Number of ClearState Program pages                                                                                                                                           |

### Array Fields

| INDEX |          NAME          |  TYPE   | IN | DESCRIPTION                                                                                 |
|:-----:|:----------------------:|:-------:|:--:|:--------------------------------------------------------------------------------------------|
|  26   |    ApplicationArgs     | []byte  | v2 | Arguments passed to the application in the ApplicationCall transaction                      |
|  28   |        Accounts        | address | v2 | Accounts listed in the ApplicationCall transaction                                          |
|  48   |         Assets         | uint64  | v3 | Foreign Assets listed in the ApplicationCall transaction                                    |
|  50   |      Applications      | uint64  | v3 | Foreign Apps listed in the ApplicationCall transaction                                      |
|  58   |          Logs          | []byte  | v5 | Log messages emitted by an application call (only with `itxn` in v5). Application mode only |
|  64   |  ApprovalProgramPages  | []byte  | v7 | Approval Program as an array of pages                                                       |
|  66   | ClearStateProgramPages | []byte  | v7 | ClearState Program as an array of pages                                                     |

Additional details in the [opcodes document](TEAL_opcodes.md#txn) on the `txn` op.

## Global Fields

Global fields are fields that are common to all the transactions in the group. In particular it includes consensus parameters.

| INDEX |           NAME            |   TYPE   | IN  | DESCRIPTION                                                                                                                                          |
|:-----:|:-------------------------:|:--------:|:---:|:-----------------------------------------------------------------------------------------------------------------------------------------------------|
|   0   |         MinTxnFee         |  uint64  |     | microalgos                                                                                                                                           |
|   1   |        MinBalance         |  uint64  |     | microalgos                                                                                                                                           |
|   2   |        MaxTxnLife         |  uint64  |     | rounds                                                                                                                                               |
|   3   |        ZeroAddress        | address  |     | 32 byte address of all zero bytes                                                                                                                    |
|   4   |         GroupSize         |  uint64  |     | Number of transactions in this atomic transaction group. At least 1                                                                                  |
|   5   |      LogicSigVersion      |  uint64  | v2  | Maximum supported version                                                                                                                            |
|   6   |           Round           |  uint64  | v2  | Current round number. Application mode only.                                                                                                         |
|   7   |      LatestTimestamp      |  uint64  | v2  | Last confirmed block UNIX timestamp. Fails if negative. Application mode only.                                                                       |
|   8   |   CurrentApplicationID    |  uint64  | v2  | ID of current application executing. Application mode only.                                                                                          |
|   9   |      CreatorAddress       | address  | v3  | Address of the creator of the current application. Application mode only.                                                                            |
|  10   | CurrentApplicationAddress | address  | v5  | Address that the current application controls. Application mode only.                                                                                |
|  11   |          GroupID          | [32]byte | v5  | ID of the transaction group. 32 zero bytes if the transaction is not part of a group.                                                                |
|  12   |       OpcodeBudget        |  uint64  | v6  | The remaining cost that can be spent by opcodes in this program.                                                                                     |
|  13   |    CallerApplicationID    |  uint64  | v6  | The application ID of the application that called this application. 0 if this application is at the top-level. Application mode only.                |
|  14   | CallerApplicationAddress  | address  | v6  | The application address of the application that called this application. ZeroAddress if this application is at the top-level. Application mode only. |
|  15   |   AssetCreateMinBalance   |  uint64  | v10 | The additional minimum balance required to create (and opt-in to) an asset.                                                                          |
|  16   |   AssetOptInMinBalance    |  uint64  | v10 | The additional minimum balance required to opt-in to an asset.                                                                                       |
|  17   |        GenesisHash        | [32]byte | v10 | The Genesis Hash for the network.                                                                                                                    |
|  18   |      PayoutsEnabled       |   bool   | v11 | Whether block proposal payouts are enabled.                                                                                                          |
|  19   |    PayoutsGoOnlineFee     |  uint64  | v11 | The fee required in a keyreg transaction to make an account incentive eligible.                                                                      |
|  20   |      PayoutsPercent       |  uint64  | v11 | The percentage of transaction fees in a block that can be paid to the block proposer.                                                                |
|  21   |     PayoutsMinBalance     |  uint64  | v11 | The minimum balance an account must have in the agreement round to receive block payouts in the proposal round.                                      |
|  22   |     PayoutsMaxBalance     |  uint64  | v11 | The maximum balance an account can have in the agreement round to receive block payouts in the proposal round.                                       |

## Asset Fields

Asset fields include `AssetHolding` and `AssetParam` fields that are used in the `asset_holding_get` and `asset_params_get` opcodes.

| INDEX |     NAME     |  TYPE  | DESCRIPTION                                   |
|:-----:|:------------:|:------:|:----------------------------------------------|
|   0   | AssetBalance | uint64 | Amount of the asset unit held by this account |
|   1   | AssetFrozen  |  bool  | Is the asset frozen or not                    |

| INDEX |        NAME        |   TYPE   | IN | DESCRIPTION                              |
|:-----:|:------------------:|:--------:|:--:|:-----------------------------------------|
|   0   |     AssetTotal     |  uint64  |    | Total number of units of this asset      |
|   1   |   AssetDecimals    |  uint64  |    | See AssetParams.Decimals                 |
|   2   | AssetDefaultFrozen |   bool   |    | Frozen by default or not                 |
|   3   |   AssetUnitName    |  []byte  |    | Asset unit name                          |
|   4   |     AssetName      |  []byte  |    | Asset name                               |
|   5   |      AssetURL      |  []byte  |    | URL with additional info about the asset |
|   6   | AssetMetadataHash  | [32]byte |    | Arbitrary commitment                     |
|   7   |    AssetManager    | address  |    | Manager address                          |
|   8   |    AssetReserve    | address  |    | Reserve address                          |
|   9   |    AssetFreeze     | address  |    | Freeze address                           |
|  10   |   AssetClawback    | address  |    | Clawback address                         |
|  11   |    AssetCreator    | address  | v5 | Creator address                          |

## Application Fields

Application fields used in the `app_params_get` opcode.

| INDEX |         NAME          |  TYPE   | DESCRIPTION                                         |
|:-----:|:---------------------:|:-------:|:----------------------------------------------------|
|   0   |  AppApprovalProgram   | []byte  | Bytecode of Approval Program                        |
|   1   | AppClearStateProgram  | []byte  | Bytecode of Clear State Program                     |
|   2   |   AppGlobalNumUint    | uint64  | Number of uint64 values allowed in Global State     |
|   3   | AppGlobalNumByteSlice | uint64  | Number of byte array values allowed in Global State |
|   4   |    AppLocalNumUint    | uint64  | Number of uint64 values allowed in Local State      |
|   5   | AppLocalNumByteSlice  | uint64  | Number of byte array values allowed in Local State  |
|   6   | AppExtraProgramPages  | uint64  | Number of Extra Program Pages of code space         |
|   7   |      AppCreator       | address | Creator address                                     |
|   8   |      AppAddress       | address | Address for which this application has authority    |

## Account Fields

Account fields used in the `acct_params_get` opcode.

| INDEX |          NAME          |  TYPE   | IN  | DESCRIPTION                                                                                 |
|:-----:|:----------------------:|:-------:|:---:|:--------------------------------------------------------------------------------------------|
|   0   |      AcctBalance       | uint64  |     | Account balance in microalgos                                                               |
|   1   |     AcctMinBalance     | uint64  |     | Minimum required balance for account, in microalgos                                         |
|   2   |      AcctAuthAddr      | address |     | Address the account is rekeyed to.                                                          |
|   3   |    AcctTotalNumUint    | uint64  | v8  | The total number of uint64 values allocated by this account in Global and Local States.     |
|   4   | AcctTotalNumByteSlice  | uint64  | v8  | The total number of byte array values allocated by this account in Global and Local States. |
|   5   | AcctTotalExtraAppPages | uint64  | v8  | The number of extra app code pages used by this account.                                    |
|   6   |  AcctTotalAppsCreated  | uint64  | v8  | The number of existing apps created by this account.                                        |
|   7   |  AcctTotalAppsOptedIn  | uint64  | v8  | The number of apps this account is opted into.                                              |
|   8   | AcctTotalAssetsCreated | uint64  | v8  | The number of existing ASAs created by this account.                                        |
|   9   |    AcctTotalAssets     | uint64  | v8  | The numbers of ASAs held by this account (including ASAs this account created).             |
|  10   |     AcctTotalBoxes     | uint64  | v8  | The number of existing boxes created by this account's app.                                 |
|  11   |   AcctTotalBoxBytes    | uint64  | v8  | The total number of bytes used by this account's app's box keys and values.                 |
|  12   | AcctIncentiveEligible  |  bool   | v11 | Has this account opted into block payouts                                                   |
|  13   |    AcctLastProposed    | uint64  | v11 | The round number of the last block this account proposed.                                   |
|  14   |   AcctLastHeartbeat    | uint64  | v11 | The round number of the last block this account sent a heartbeat.                           |
