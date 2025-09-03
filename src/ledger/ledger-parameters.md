$$
\newcommand \BonusBaseAmount {B_{b,\mathrm{base}}}
\newcommand \BonusBaseRound {B_{b,\mathrm{start}}}
\newcommand \BonusDecayInterval {B_{b,\mathrm{decay}}}
\newcommand \MaxTimestampIncrement {\Delta t_{\max}}
\newcommand \MaxTxnBytesPerBlock {B_{\max}}
\newcommand \MaxVersionStringLen {V_{\max}}
\newcommand \Heartbeat {\mathrm{hb}}
\newcommand \Fee {\mathrm{fee}}
\newcommand \PayoutsChallengeBits {\Heartbeat_\mathrm{bits}}
\newcommand \PayoutsChallengeGracePeriod {\Heartbeat_\mathrm{grace}}
\newcommand \PayoutsChallengeInterval {\Heartbeat_r}
\newcommand \PayoutsGoOnlineFee {B_{p,\Fee}}
\newcommand \AccountMinBalance {A_{b,\min}}
\newcommand \DefaultUpgradeWaitRounds {\delta_x}
\newcommand \MaxUpgradeWaitRounds {\delta_{x_{\max}}}
\newcommand \MinUpgradeWaitRounds {\delta_{x_{\min}}}
\newcommand \UpgradeThreshold {\tau}
\newcommand \UpgradeVoteRounds {\delta_d}
\newcommand \RewardUnit {U_r}
\newcommand \RewardsRateRefreshInterval {\omega_r}
\newcommand \StateProof {\mathrm{SP}}
\newcommand \StateProofInterval {\delta_\StateProof}
\newcommand \StateProofVotersLookback {\delta_{\StateProof,b}}
\newcommand \StateProofTopVoters {N_\StateProof}
\newcommand \StateProofStrengthTarget {KQ_\StateProof}
\newcommand \StateProofMaxRecoveryIntervals {I_\StateProof}
\newcommand \StateProofWeightThreshold {f_\StateProof}
\newcommand \MinTxnFee {T_{\Fee,\min}}
\newcommand \MaxTxnLife {T_{\Delta r,\max}}
\newcommand \MaxTxnNoteBytes {T_{m,\max}}
\newcommand \MaxTxGroupSize {GT_{\max}}
\newcommand \MaxKeyregValidPeriod {K_{\Delta r,\max}}
\newcommand \MaxTxTail {\mathrm{TxTail}_{\max}}
$$

$$
\newcommand \MinBalance {b_{\min}}
\newcommand \Asset {\mathrm{Asa}}
\newcommand \MaxAssetDecimals {\Asset_{d,\max}}
\newcommand \MaxAssetNameBytes {\Asset_{n,\max}}
\newcommand \MaxAssetUnitNameBytes {\Asset_{u,\max}}
\newcommand \MaxAssetURLBytes {\Asset_{r,\max}}
\newcommand \LogicSig {\mathrm{LSig}}
\newcommand \LogicSigMaxCost {\LogicSig_{c,\max}}
\newcommand \LogicSigMaxSize {\LogicSig_{\max}}
\newcommand \LogicSigVersion {\LogicSig_{V}}
\newcommand \MaxProposedExpiredOnlineAccounts {B_{N_\mathrm{e},\max}}
\newcommand \PayoutMaxMarkAbsent {B_{N_\mathrm{a},\max}}
\newcommand \PayoutsMaxBalance {A_{r,\max}}
\newcommand \PayoutsMinBalance {A_{r,\min}}
\newcommand \PayoutsPercent {B_{p,\\%}}
\newcommand \App {\mathrm{App}}
\newcommand \AppFlatOptInMinBalance {\App_{\mathrm{optin},\MinBalance}}
\newcommand \AppFlatParamsMinBalance {\App_{\mathrm{create},\MinBalance}}
\newcommand \Box {\mathrm{Box}}
\newcommand \BoxByteMinBalance {\Box_{\mathrm{byte},\MinBalance}}
\newcommand \BoxFlatMinBalance {\Box_{\mathrm{flat},\MinBalance}}
\newcommand \BytesPerBoxReference {\Box_{\mathrm{IO}}}
\newcommand \MaxBoxSize {\Box_{\max}}
\newcommand \MaxAppArgs {\App_{\mathrm{arg},\max}}
\newcommand \MaxAppBoxReferences {\App_{\Box,\max}}
\newcommand \MaxAppBytesValueLen {\App_{\mathrm{v},\max}}
\newcommand \MaxAppKeyLen {\App_{\mathrm{k},\max}}
\newcommand \MaxAppProgramCost {\App_{c,\max}}
\newcommand \MaxAppProgramLen {\App_{\mathrm{prog},\max}}
\newcommand \MaxAppSumKeyValueLens {\App_{\mathrm{kv},\max}}
\newcommand \MaxAppTotalArgLen {\App_{\mathrm{ay},\max}}
\newcommand \MaxAppTotalProgramLen {\App_{\mathrm{prog},t,\max}}
\newcommand \MaxAppTotalTxnReferences {\App_{r,\max}}
\newcommand \MaxAppTxnAccounts {\App_{\mathrm{acc},\max}}
\newcommand \MaxAppTxnForeignApps {\App_{\mathrm{app},\max}}
\newcommand \MaxAppTxnForeignAssets {\App_{\mathrm{asa},\max}}
\newcommand \MaxAppAccess {\App_{\mathrm{access},\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
\newcommand \MaxGlobalSchemaEntries {\App_{\mathrm{GS},\max}}
\newcommand \MaxLocalSchemaEntries {\App_{\mathrm{LS},\max}}
\newcommand \MaxInnerTransactions {\App_\mathrm{itxn}}
\newcommand \SchemaBytesMinBalance {\App_{\mathrm{b},\MinBalance}}
\newcommand \SchemaMinBalancePerEntry {\App_{\mathrm{s},\MinBalance}}
\newcommand \SchemaUintMinBalance {\App_{\mathrm{u},\MinBalance}}
$$

$$
\newcommand \Account {\mathrm{Acc}}
\newcommand \MaxAssetsPerAccount {\Account_{\Asset,\max}}
\newcommand \MaxAppsCreated {\Account_{\App,\max}}
\newcommand \MaxAppsOptedIn {\Account_{\App,optin,\max}}
\newcommand \MaximumMinimumBalance {\mathrm{MBR}_{\max}}
\newcommand \DefaultKeyDilution {\mathrm{KeyDilution}}
$$

# Parameters

The Algorand _Ledger_ is parameterized by the values in the following tables.

> For each parameter, the tables provide the reference implementation name and the
> last update version, to facilitate the match of the specifications and the implementation.

## Block

|                 Parameter                 |     Current Value     |  Unit   | Description                                                           | Reference Implementation Name      | Last Update Version |
|:-----------------------------------------:|:---------------------:|:-------:|-----------------------------------------------------------------------|------------------------------------|:-------------------:|
|       \\( \MaxTxnBytesPerBlock \\)        | \\( 5{,}242{,}880 \\) |  bytes  | Maximum number of transaction bytes in a block                        | `MaxTxnBytesPerBlock`              |         v33         |
|      \\( \MaxTimestampIncrement \\)       |      \\( 25 \\)       | seconds | Maximum difference between successive timestamps                      | `MaxTimestampIncrement`            |         v7          |
|       \\( \MaxVersionStringLen \\)        |      \\( 128 \\)      |  bytes  | Maximum length of protocol version strings                            | `MaxVersionStringLen`              |         v12         |
| \\( \MaxProposedExpiredOnlineAccounts \\) |      \\( 32 \\)       |         | Maximum number of _expired participation accounts_ in block header    | `MaxProposedExpiredOnlineAccounts` |         v31         |
|       \\( \PayoutMaxMarkAbsent \\)        |      \\( 32 \\)       |         | Maximum number of _suspended participation accounts_ in block header  | `Payout.MaxMarkAbsent`             |         v40         |

## Block Rewards

|              Parameter               |           Current Value            |  Unit  | Description                                                                                                                         | Reference Implementation Name  | Last Update Version |
|:------------------------------------:|:----------------------------------:|:------:|-------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|:-------------------:|
|       \\( \BonusBaseAmount \\)       |       \\( 10{,}000{,}000 \\)       | μALGO  | Bonus to be paid when block rewards first applies                                                                                   | `Bonus.BaseAmount`             |         v40         |
|       \\( \BonusBaseRound \\)        |                                    | round  | Earliest round block rewards can apply                                                                                              | `Bonus.BaseRound`              |         v40         |
|     \\( \BonusDecayInterval \\)      |       \\( 1{,}000{,}000 \\)        | rounds | Time in rounds between 1% decays of the block rewards bonus component                                                               | `Bonus.DecayInterval`          |         v40         |
|    \\( \PayoutsChallengeBits \\)     |             \\( 5 \\)              |  bits  | Frequency of online account challenges, about \\( \PayoutsChallengeInterval \times 2^{\PayoutsChallengeBits} \\) rounds             | `Payouts.ChallengeBits`        |         v40         |
| \\( \PayoutsChallengeGracePeriod \\) |            \\( 200 \\)             | rounds | Active challenge round lookback for the response interval \\( [r-2\PayoutsChallengeGracePeriod, r-\PayoutsChallengeGracePeriod] \\) | `Payouts.ChallengeGracePeriod` |         v40         |
|  \\( \PayoutsChallengeInterval \\)   |          \\( 1{,}000 \\)           | rounds | Online account challenges interval, it defines the challenges frequency                                                             | `Payouts.ChallengeInterval`    |         v40         |
|     \\( \PayoutsGoOnlineFee \\)      |       \\( 2{,}000{,}000 \\)        | μALGO  | Minimum `keyreg` transaction fee to be eligible for block rewards                                                                   | `Payouts.GoOnlineFee`          |         v40         |
|      \\( \PayoutsMaxBalance \\)      | \\( 70{,}000{,}000{,}000{,}000 \\) | μALGO  | Maximum balance an account can have to be eligible for block rewards                                                                | `Payouts.MaxBalance`           |         v40         |
|      \\( \PayoutsMinBalance \\)      |    \\( 30{,}000{,}000{,}000 \\)    | μALGO  | Minimum balance an account must have to be eligible for block rewards                                                               | `Payouts.MinBalance`           |         v40         |
|       \\( \PayoutsPercent \\)        |             \\( 50 \\)             |   %    | Percent of fees paid in a block that go to the proposer instead of the FeeSink                                                      | `Payouts.Percent`              |         v40         |
|         \\( \RewardUnit \\)          |       \\( 1{,}000{,}000 \\)        | μALGO  | Size of an earning unit                                                                                                             | `RewardUnit`                   |         v7          |
| \\( \RewardsRateRefreshInterval \\)  |         \\( 500{,}000 \\)          | rounds | Rate at which the reward rate is refreshed                                                                                          | `RewardsRateRefreshInterval`   |         v7          |

## Protocol Upgrade

|             Parameter             |   Current Value   |  Unit  | Description                                               | Reference Implementation Name | Last Update Version |
|:---------------------------------:|:-----------------:|:------:|-----------------------------------------------------------|-------------------------------|:-------------------:|
| \\( \DefaultUpgradeWaitRounds \\) | \\( 140{,}000 \\) | rounds | Default number of rounds needed to prepare for an upgrade | `DefaultUpgradeWaitRounds`    |         v20         |
|   \\( \MaxUpgradeWaitRounds \\)   | \\( 250{,}000 \\) | rounds | Maximum number of rounds needed to prepare for an upgrade | `MaxUpgradeWaitRounds`        |         v39         |
|  \\( \\MinUpgradeWaitRounds \\)   | \\( 10{,}000 \\)  | rounds | Minimum number of rounds needed to prepare for an upgrade | `MinUpgradeWaitRounds`        |         v22         |
|     \\( \UpgradeThreshold \\)     |  \\( 9{,}000 \\)  |        | Number of votes needed to execute an upgrade              | `UpgradeThreshold`            |         v7          |
|    \\( \UpgradeVoteRounds \\)     | \\( 10{,}000 \\)  | rounds | Number of rounds over which an upgrade proposal is open   | `UpgradeVoteRounds`           |         v7          |

## State Proof

|                Parameter                |            Current Value             |  Unit  | Description                                                                                         | Reference Implementation Name    | Last Update Version |
|:---------------------------------------:|:------------------------------------:|:------:|-----------------------------------------------------------------------------------------------------|----------------------------------|:-------------------:|
|       \\( \StateProofInterval \\)       |             \\( 256 \\)              | rounds | Number of rounds between state proofs                                                               | `StateProofInterval`             |         v34         |
| \\( \StateProofMaxRecoveryIntervals \\) |              \\( 10 \\)              |        | Number of state proof intervals that the network will try to catch-up with                          | `StateProofMaxRecoveryIntervals` |         v34         |
|    \\( \StateProofStrengthTarget \\)    |             \\( 256 \\)              |  bits  | Security parameter for State Proof[^1]                                                              | `StateProofStrengthTarget`       |         v34         |
|      \\( \StateProofTopVoters \\)       |           \\( 1{,}024 \\)            |        | Maximum number of online accounts included in the vector commitment of state proofs participants    | `StateProofTopVoters`            |         v34         |
|    \\( \StateProofVotersLookback \\)    |              \\( 16 \\)              | rounds | Delay in rounds for online participant information committed to in the block header for State Proof | `StateProofVotersLookback`       |         v34         |
|   \\( \StateProofWeightThreshold \\)    | \\( 2^{32} \times \frac{30}{100} \\) |        | Fraction of participants proven to have signed by a State Proof                                     | `StateProofWeightThreshold`      |         v34         |

## Transaction

|           Parameter           |     Current Value      |  Unit  | Description                                                                                            | Reference Implementation Name | Last Update Version |
|:-----------------------------:|:----------------------:|:------:|--------------------------------------------------------------------------------------------------------|-------------------------------|:-------------------:|
|      \\( \MaxTxTail \\)       |    \\( 1{,}000 \\)     |        | Length of the _Transaction Tail_                                                                       |                               |                     |
| \\( \MaxKeyregValidPeriod \\) | \\( 16{,}777{,}215 \\) | rounds | Maximum voting range in a `keyreg` transaction, defined as \\( (256 \times 2^{16})-1 \\)               | `MaxKeyregValidPeriod`        |         v31         |
|    \\( \MaxTxGroupSize \\)    |       \\( 16 \\)       |  txn   | Maximum number of transactions allowed in a group                                                      | `MaxTxGroupSize `             |         v18         |
|      \\( \MaxTxnLife \\)      |     \\( 1,000 \\)      | rounds | Maximum difference between last valid and first valid round, defines transaction lifespan in the pool  | `MaxTxnLife`                  |         v7          |
|      \\( \MinTxnFee \\)       |    \\( 1{,}000 \\)     | μALGO  | Minimum processing fee for any transaction                                                             | `MinTxnFee`                   |         v7          |
|   \\( \MaxTxnNoteBytes \\)    |    \\( 1{,}024 \\)     | bytes  | Maximum length of a transaction note field                                                             | `MaxTxnNoteBytes`             |         v7          |

## Account

|           Parameter            |     Current Value     |  Unit  | Description                                                                                     | Reference Implementation Name | Last Update Version |
|:------------------------------:|:---------------------:|:------:|-------------------------------------------------------------------------------------------------|-------------------------------|:-------------------:|
|  \\( \DefaultKeyDilution \\)   |   \\( 10{,}000 \\)    | rounds | Granularity of top-level ephemeral keys, equal to the number of second-level keys in each batch | `DefaultKeyDilution`          |         v7          |
|      \\( \MinBalance \\)       |   \\( 100{,}000 \\)   | μALGO  | Minimum balance requirement (MBR) for an account                                                | `MinBalance`                  |         v9          |
|  \\( \MaxAssetsPerAccount \\)  | \\( 0 \\) (unlimited) |        | Maximum number of assets per account                                                            | `MaxAssetsPerAccount`         |         v32         |
|    \\( \MaxAppsCreated \\)     | \\( 0 \\) (unlimited) |        | Maximum number of application created per account                                               | `MaxAppsCreated`              |         v32         |
|    \\( \MaxAppsOptedIn \\)     | \\( 0 \\) (unlimited) |        | Maximum number of application opted-in per account                                              | `MaxAppsOptedIn`              |         v32         |
| \\( \MaximumMinimumBalance \\) | \\( 0 \\) (unlimited) | μALGO  | Maximum MBR of an account                                                                       | `MaximumMinimumBalance`       |         v32         |

## Asset

|           Parameter            | Current Value | Unit  | Description                                   | Reference Implementation Name | Last Update Version |
|:------------------------------:|:-------------:|:-----:|-----------------------------------------------|-------------------------------|:-------------------:|
|   \\( \MaxAssetDecimals \\)    |  \\( 19 \\)   |       | Maximum decimal precision of the asset supply | `MaxAssetDecimals`            |         v20         |
|   \\( \MaxAssetNameBytes \\)   |  \\( 32 \\)   | bytes | Maximum length of asset name                  | `MaxAssetNameBytes`           |         v18         |
| \\( \MaxAssetUnitNameBytes \\) |   \\( 8 \\)   | bytes | Maximum length of asset unit (symbol)         | `MaxAssetUnitNameBytes`       |         v18         |
|   \\( \MaxAssetURLBytes \\)    |  \\( 96 \\)   | bytes | Maximum length of asset URL                   | `MaxAssetURLBytes`            |         v28         |

## LogicSig

|        Parameter         |  Current Value   |  Unit   | Description                                                | Reference Implementation Name | Last Update Version |
|:------------------------:|:----------------:|:-------:|------------------------------------------------------------|-------------------------------|:-------------------:|
| \\( \LogicSigMaxCost \\) | \\( 20{,}000 \\) | opcodes | Maximum opcode cost for LSig                               | `LogicSigMaxCost`             |         v18         |
| \\( \LogicSigMaxSize \\) | \\( 1{,}000 \\)  |  bytes  | Maximum combined length of LSig program and LSig arguments | `LogicSigMaxSize`             |         v18         |

## Application

|             Parameter             |   Current Value   |     Unit     | Description                                                             | Reference Implementation Name | Last Update Version |
|:---------------------------------:|:-----------------:|:------------:|-------------------------------------------------------------------------|-------------------------------|:-------------------:|
|  \\( \AppFlatOptInMinBalance \\)  | \\( 100{,}000 \\) |    μALGO     | MBR for opting in to a single application                               | `AppFlatOptInMinBalance`      |         v24         |
| \\( \AppFlatParamsMinBalance \\)  | \\( 100{,}000 \\) |    μALGO     | MBR for creating a single application                                   | `AppFlatParamsMinBalance`     |         v24         |
|    \\( \BoxByteMinBalance \\)     |    \\( 400 \\)    | μALGO / byte | MBR per byte of box storage                                             | `BoxByteMinBalance`           |         v36         |
|    \\( \BoxFlatMinBalance \\)     |  \\( 2{,}500 \\)  |    μALGO     | MBR per box created                                                     | `BoxFlatMinBalance`           |         v36         |
|   \\( \BytesPerBoxReference \\)   |  \\( 2{,}048\\)   |    bytes     | Box read and write payload per reference                                | `BytesPerBoxReference`        |         v41         |
|        \\( \MaxBoxSize \\)        | \\( 32{,}768 \\)  |    bytes     | Maximum size of a box                                                   | `MaxBoxSize`                  |         v36         |
|        \\( \MaxAppArgs \\)        |    \\( 16 \\)     |              | Maximum number of arguments for an `appl` transaction                   | `MaxAppArgs`                  |         v24         |
|   \\( \MaxAppBoxReferences \\)    |     \\( 8 \\)     |              | Maximum number of box references for an `appl` transaction              | `MaxAppBoxReferences`         |         v36         |
|   \\( \MaxAppBytesValueLen \\)    |    \\( 128 \\)    |    bytes     | Maximum length of a bytes value used in an application’s state          | `MaxAppBytesValueLen`         |         v28         |
|       \\( \MaxAppKeyLen \\)       |    \\( 64 \\)     |    bytes     | Maximum length of a key used in an application’s state                  | `MaxAppKeyLen`                |         v24         |
|    \\( \MaxAppProgramCost \\)     |    \\( 700 \\)    |   opcodes    | Maximum cost of application Approval or ClearState application program  | `MaxAppProgramCost`           |         v24         |
|     \\( \MaxAppProgramLen \\)     |  \\( 2{,}048 \\)  |    bytes     | Maximum length of application Approval or ClearState program page       | `MaxAppProgramLen`            |         v28         |
|  \\( \MaxAppSumKeyValueLens \\)   |    \\( 128 \\)    |    bytes     | Maximum sum of the lengths of the key and value of one app state entry  | `MaxAppSumKeyValueLens`       |         v28         |
|    \\( \MaxAppTotalArgLen \\)     |  \\( 2{,}048 \\)  |    bytes     | Maximum sum of the lengths of argument for an `appl` transaction        | `MaxAppTotalArgLen`           |         v24         |
|  \\( \MaxAppTotalProgramLen \\)   |  \\( 2{,}048 \\)  |    bytes     | Maximum combined length of application Approval and ClearState programs | `MaxAppTotalProgramLen`       |         v24         |
| \\( \MaxAppTotalTxnReferences \\) |     \\( 8 \\)     |              | Maximum number of references for an `appl` transaction                  | `MaxAppTotalTxnReferences`    |         v24         |
|    \\( \MaxAppTxnAccounts \\)     |     \\( 8 \\)     |              | Maximum number of account references for an `appl` transaction          | `MaxAppTxnAccounts`           |         v41         |
|   \\( \MaxAppTxnForeignApps \\)   |     \\( 8 \\)     |              | Maximum number of application references for an `appl` transaction      | `MaxAppTxnForeignApps`        |         v28         |
|  \\( \MaxAppTxnForeignAssets \\)  |     \\( 8 \\)     |              | Maximum number of asset references for an `appl` transaction            | `MaxAppTxnForeignAssets`      |         v28         |
|       \\( \MaxAppAccess \\)       |    \\( 16 \\)     |              | Maximum number of resources access list for an `appl` transaction       | `MaxAppAccess`                |         v41         |
| \\( \MaxExtraAppProgramPages \\)  |     \\( 3 \\)     |              | Maximum extra length for application program in pages                   | `MaxExtraAppProgramPages`     |         v28         |
|  \\( \MaxGlobalSchemaEntries \\)  |    \\( 64 \\)     |              | Maximum number of key/value pairs of application global state           | `MaxGlobalSchemaEntries`      |         v24         |
|  \\( \MaxLocalSchemaEntries \\)   |    \\( 16 \\)     |              | Maximum number of key/value pairs of application local state            | `MaxLocalSchemaEntries`       |         v24         |
|   \\( \MaxInnerTransactions \\)   |    \\( 16 \\)     |     txn      | Maximum number of inner transactions for an `appl` transaction          | `MaxInnerTransactions`        |         v30         |
|  \\( \SchemaBytesMinBalance \\)   | \\( 25{,}000 \\)  |    μALGO     | Additional MBR for `[]bytes` values in application state                | `SchemaBytesMinBalance`       |         v24         |
| \\( \SchemaMinBalancePerEntry \\) | \\( 25{,}000 \\)  |    μALGO     | MBR for key-value pair in application state                             | `SchemaMinBalancePerEntry`    |         v24         |
|   \\( \SchemaUintMinBalance \\)   |  \\( 35{,}00 \\)  |    μALGO     | Additional MBR for `uint64` values in application state                 | `SchemaUintMinBalance`        |         v24         |

---

[^1]: \\( \StateProofStrengthTarget = 256 \\) is the value set for State Proofs of
type \\(0 \\). Other types of State Proofs might be added in the future.
\\( \StateProofStrengthTarget = \mathrm{target_{PQ}} \\) is set to achieve _post-quantum
security_ for State Proof. For further details, refer to the State Proofs
[normative specification](../crypto/crypto-state-proofs.md).