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
\newcommand \MaxAbsoluteTxnNoteBytes {T_{m,\mathrm{abs}}}
\newcommand \PerByteTxnSurcharge {T_{\Fee,b}}
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
\newcommand \MaxAbsoluteLogicSigProgramSize {\LogicSig_{\mathrm{abs}}}
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
\newcommand \MaxAbsoluteTotalArgLen {\App_{\mathrm{ay},\mathrm{abs}}}
\newcommand \MaxAppTotalProgramLen {\App_{\mathrm{prog},t,\max}}
\newcommand \MaxAppTotalTxnReferences {\App_{r,\max}}
\newcommand \MaxAppTxnAccounts {\App_{\mathrm{acc},\max}}
\newcommand \MaxAppTxnForeignApps {\App_{\mathrm{app},\max}}
\newcommand \MaxAppTxnForeignAssets {\App_{\mathrm{asa},\max}}
\newcommand \MaxAppAccess {\App_{\mathrm{access},\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
\newcommand \MaxAbsoluteExtraProgramPages {\App_{\mathrm{page},\mathrm{abs}}}
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

> For each parameter, the tables provide the reference implementation name, to
> facilitate the match of the specifications and the implementation.

## Block

|                 Parameter                 |     Current Value     |  Unit   | Description                                                           | Reference Implementation Name      |
|:-----------------------------------------:|:---------------------:|:-------:|-----------------------------------------------------------------------|------------------------------------|
|       \\( \MaxTxnBytesPerBlock \\)        | \\( 5{,}242{,}880 \\) |  bytes  | Maximum number of transaction bytes in a block                        | `MaxTxnBytesPerBlock`              |
|      \\( \MaxTimestampIncrement \\)       |      \\( 25 \\)       | seconds | Maximum difference between successive timestamps                      | `MaxTimestampIncrement`            |
|       \\( \MaxVersionStringLen \\)        |      \\( 128 \\)      |  bytes  | Maximum length of protocol version strings                            | `MaxVersionStringLen`              |
| \\( \MaxProposedExpiredOnlineAccounts \\) |      \\( 32 \\)       |         | Maximum number of _expired participation accounts_ in block header    | `MaxProposedExpiredOnlineAccounts` |
|       \\( \PayoutMaxMarkAbsent \\)        |      \\( 32 \\)       |         | Maximum number of _suspended participation accounts_ in block header  | `Payout.MaxMarkAbsent`             |

## Block Rewards

|              Parameter               |           Current Value            |  Unit  | Description                                                                                                                         | Reference Implementation Name  |
|:------------------------------------:|:----------------------------------:|:------:|-------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
|       \\( \BonusBaseAmount \\)       |       \\( 10{,}000{,}000 \\)       | μALGO  | Bonus to be paid when block rewards first applies                                                                                   | `Bonus.BaseAmount`             |
|       \\( \BonusBaseRound \\)        |                                    | round  | Earliest round block rewards can apply                                                                                              | `Bonus.BaseRound`              |
|     \\( \BonusDecayInterval \\)      |       \\( 1{,}000{,}000 \\)        | rounds | Time in rounds between 1% decays of the block rewards bonus component                                                               | `Bonus.DecayInterval`          |
|    \\( \PayoutsChallengeBits \\)     |             \\( 5 \\)              |  bits  | Frequency of online account challenges, about \\( \PayoutsChallengeInterval \times 2^{\PayoutsChallengeBits} \\) rounds             | `Payouts.ChallengeBits`        |
| \\( \PayoutsChallengeGracePeriod \\) |            \\( 200 \\)             | rounds | Active challenge round lookback for the response interval \\( [r-2\PayoutsChallengeGracePeriod, r-\PayoutsChallengeGracePeriod] \\) | `Payouts.ChallengeGracePeriod` |
|  \\( \PayoutsChallengeInterval \\)   |          \\( 1{,}000 \\)           | rounds | Online account challenges interval, it defines the challenges frequency                                                             | `Payouts.ChallengeInterval`    |
|     \\( \PayoutsGoOnlineFee \\)      |       \\( 2{,}000{,}000 \\)        | μALGO  | Minimum `keyreg` transaction fee to be eligible for block rewards                                                                   | `Payouts.GoOnlineFee`          |
|      \\( \PayoutsMaxBalance \\)      | \\( 70{,}000{,}000{,}000{,}000 \\) | μALGO  | Maximum balance an account can have to be eligible for block rewards                                                                | `Payouts.MaxBalance`           |
|      \\( \PayoutsMinBalance \\)      |    \\( 30{,}000{,}000{,}000 \\)    | μALGO  | Minimum balance an account must have to be eligible for block rewards                                                               | `Payouts.MinBalance`           |
|       \\( \PayoutsPercent \\)        |             \\( 50 \\)             |   %    | Percent of fees paid in a block that go to the proposer instead of the FeeSink                                                      | `Payouts.Percent`              |
|         \\( \RewardUnit \\)          |       \\( 1{,}000{,}000 \\)        | μALGO  | Size of an earning unit                                                                                                             | `RewardUnit`                   |
| \\( \RewardsRateRefreshInterval \\)  |         \\( 500{,}000 \\)          | rounds | Rate at which the reward rate is refreshed                                                                                          | `RewardsRateRefreshInterval`   |

## Protocol Upgrade

|             Parameter             |   Current Value   |  Unit  | Description                                               | Reference Implementation Name |
|:---------------------------------:|:-----------------:|:------:|-----------------------------------------------------------|-------------------------------|
| \\( \DefaultUpgradeWaitRounds \\) | \\( 140{,}000 \\) | rounds | Default number of rounds needed to prepare for an upgrade | `DefaultUpgradeWaitRounds`    |
|   \\( \MaxUpgradeWaitRounds \\)   | \\( 250{,}000 \\) | rounds | Maximum number of rounds needed to prepare for an upgrade | `MaxUpgradeWaitRounds`        |
|  \\( \\MinUpgradeWaitRounds \\)   | \\( 10{,}000 \\)  | rounds | Minimum number of rounds needed to prepare for an upgrade | `MinUpgradeWaitRounds`        |
|     \\( \UpgradeThreshold \\)     |  \\( 9{,}000 \\)  |        | Number of votes needed to execute an upgrade              | `UpgradeThreshold`            |
|    \\( \UpgradeVoteRounds \\)     | \\( 10{,}000 \\)  | rounds | Number of rounds over which an upgrade proposal is open   | `UpgradeVoteRounds`           |

## State Proof

|                Parameter                |            Current Value             |  Unit  | Description                                                                                         | Reference Implementation Name    |
|:---------------------------------------:|:------------------------------------:|:------:|-----------------------------------------------------------------------------------------------------|----------------------------------|
|       \\( \StateProofInterval \\)       |             \\( 256 \\)              | rounds | Number of rounds between state proofs                                                               | `StateProofInterval`             |
| \\( \StateProofMaxRecoveryIntervals \\) |              \\( 10 \\)              |        | Number of state proof intervals that the network will try to catch-up with                          | `StateProofMaxRecoveryIntervals` |
|    \\( \StateProofStrengthTarget \\)    |             \\( 256 \\)              |  bits  | Security parameter for State Proof[^1]                                                              | `StateProofStrengthTarget`       |
|      \\( \StateProofTopVoters \\)       |           \\( 1{,}024 \\)            |        | Maximum number of online accounts included in the vector commitment of state proofs participants    | `StateProofTopVoters`            |
|    \\( \StateProofVotersLookback \\)    |              \\( 16 \\)              | rounds | Delay in rounds for online participant information committed to in the block header for State Proof | `StateProofVotersLookback`       |
|   \\( \StateProofWeightThreshold \\)    | \\( 2^{32} \times \frac{30}{100} \\) |        | Fraction of participants proven to have signed by a State Proof                                     | `StateProofWeightThreshold`      |

## Transaction

|            Parameter             |     Current Value      |                  Unit                   | Description                                                                                                      | Reference Implementation Name |
|:--------------------------------:|:----------------------:|:---------------------------------------:|------------------------------------------------------------------------------------------------------------------|-------------------------------|
|        \\( \MaxTxTail \\)        |    \\( 1{,}000 \\)     |                                         | Length of the _Transaction Tail_                                                                                 |                               |
|  \\( \MaxKeyregValidPeriod \\)   | \\( 16{,}777{,}215 \\) |                 rounds                  | Maximum voting range in a `keyreg` transaction, defined as \\( (256 \times 2^{16})-1 \\)                         | `MaxKeyregValidPeriod`        |
|     \\( \MaxTxGroupSize \\)      |       \\( 16 \\)       |                   txn                   | Maximum number of transactions allowed in a group                                                                | `MaxTxGroupSize`              |
|       \\( \MaxTxnLife \\)        |     \\( 1,000 \\)      |                 rounds                  | Maximum difference between last valid and first valid round, defines transaction lifespan in the pool            | `MaxTxnLife`                  |
|        \\( \MinTxnFee \\)        |    \\( 1{,}000 \\)     |                  μALGO                  | Minimum processing fee for any transaction                                                                       | `MinTxnFee`                   |
|     \\( \MaxTxnNoteBytes \\)     |    \\( 1{,}024 \\)     |                  bytes                  | Maximum length of a transaction note field without a fee surcharge                                               | `MaxTxnNoteBytes`             |
| \\( \MaxAbsoluteTxnNoteBytes \\) |    \\( 4{,}096 \\)     |                  bytes                  | Absolute maximum length of a transaction note field; bytes beyond \\( \MaxTxnNoteBytes \\) incur a fee surcharge | `MaxAbsoluteTxnNoteBytes`     |
|   \\( \PerByteTxnSurcharge \\)   |      \\( 100 \\)       | millionths of \\( \MinTxnFee \\) / byte | Fee surcharge per byte by which a transaction field exceeds its basic size limit                                 | `PerByteTxnSurcharge`         |

## Account

|           Parameter            |     Current Value     |  Unit  | Description                                                                                     | Reference Implementation Name |
|:------------------------------:|:---------------------:|:------:|-------------------------------------------------------------------------------------------------|-------------------------------|
|  \\( \DefaultKeyDilution \\)   |   \\( 10{,}000 \\)    | rounds | Granularity of top-level ephemeral keys, equal to the number of second-level keys in each batch | `DefaultKeyDilution`          |
|      \\( \MinBalance \\)       |   \\( 100{,}000 \\)   | μALGO  | Minimum balance requirement (MBR) for an account                                                | `MinBalance`                  |
|  \\( \MaxAssetsPerAccount \\)  | \\( 0 \\) (unlimited) |        | Maximum number of assets per account                                                            | `MaxAssetsPerAccount`         |
|    \\( \MaxAppsCreated \\)     | \\( 0 \\) (unlimited) |        | Maximum number of application created per account                                               | `MaxAppsCreated`              |
|    \\( \MaxAppsOptedIn \\)     | \\( 0 \\) (unlimited) |        | Maximum number of application opted-in per account                                              | `MaxAppsOptedIn`              |
| \\( \MaximumMinimumBalance \\) | \\( 0 \\) (unlimited) | μALGO  | Maximum MBR of an account                                                                       | `MaximumMinimumBalance`       |

## Asset

|           Parameter            | Current Value | Unit  | Description                                   | Reference Implementation Name |
|:------------------------------:|:-------------:|:-----:|-----------------------------------------------|-------------------------------|
|   \\( \MaxAssetDecimals \\)    |  \\( 19 \\)   |       | Maximum decimal precision of the asset supply | `MaxAssetDecimals`            |
|   \\( \MaxAssetNameBytes \\)   |  \\( 32 \\)   | bytes | Maximum length of asset name                  | `MaxAssetNameBytes`           |
| \\( \MaxAssetUnitNameBytes \\) |   \\( 8 \\)   | bytes | Maximum length of asset unit (symbol)         | `MaxAssetUnitNameBytes`       |
|   \\( \MaxAssetURLBytes \\)    |  \\( 96 \\)   | bytes | Maximum length of asset URL                   | `MaxAssetURLBytes`            |

## LogicSig

|                Parameter                |  Current Value   |  Unit   | Description                                                                                                                                                     | Reference Implementation Name    |
|:---------------------------------------:|:----------------:|:-------:|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|
|        \\( \LogicSigMaxCost \\)         | \\( 20{,}000 \\) | opcodes | Maximum opcode cost for LSig                                                                                                                                    | `LogicSigMaxCost`                |
|        \\( \LogicSigMaxSize \\)         | \\( 1{,}000 \\)  |  bytes  | Maximum combined length of LSig program and LSig arguments                                                                                                      | `LogicSigMaxSize`                |
| \\( \MaxAbsoluteLogicSigProgramSize \\) | \\( 16{,}000 \\) |  bytes  | Absolute maximum length of a single LSig program; program bytes beyond \\( \LogicSigMaxSize \\) per transaction (pooled across the group) incur a fee surcharge | `MaxAbsoluteLogicSigProgramSize` |

## Application

|               Parameter               |   Current Value   |     Unit     | Description                                                                                                                       | Reference Implementation Name  |
|:-------------------------------------:|:-----------------:|:------------:|-----------------------------------------------------------------------------------------------------------------------------------|--------------------------------|
|    \\( \AppFlatOptInMinBalance \\)    | \\( 100{,}000 \\) |    μALGO     | MBR for opting in to a single application                                                                                         | `AppFlatOptInMinBalance`       |
|   \\( \AppFlatParamsMinBalance \\)    | \\( 100{,}000 \\) |    μALGO     | MBR for creating a single application                                                                                             | `AppFlatParamsMinBalance`      |
|      \\( \BoxByteMinBalance \\)       |    \\( 400 \\)    | μALGO / byte | MBR per byte of box storage                                                                                                       | `BoxByteMinBalance`            |
|      \\( \BoxFlatMinBalance \\)       |  \\( 2{,}500 \\)  |    μALGO     | MBR per box created                                                                                                               | `BoxFlatMinBalance`            |
|     \\( \BytesPerBoxReference \\)     |  \\( 2{,}048\\)   |    bytes     | Box read and write payload per reference                                                                                          | `BytesPerBoxReference`         |
|          \\( \MaxBoxSize \\)          | \\( 32{,}768 \\)  |    bytes     | Maximum size of a box                                                                                                             | `MaxBoxSize`                   |
|          \\( \MaxAppArgs \\)          |    \\( 16 \\)     |              | Maximum number of arguments for an `appl` transaction                                                                             | `MaxAppArgs`                   |
|     \\( \MaxAppBoxReferences \\)      |     \\( 8 \\)     |              | Maximum number of box references for an `appl` transaction                                                                        | `MaxAppBoxReferences`          |
|     \\( \MaxAppBytesValueLen \\)      |    \\( 128 \\)    |    bytes     | Maximum length of a bytes value used in an application’s state                                                                    | `MaxAppBytesValueLen`          |
|         \\( \MaxAppKeyLen \\)         |    \\( 64 \\)     |    bytes     | Maximum length of a key used in an application’s state                                                                            | `MaxAppKeyLen`                 |
|      \\( \MaxAppProgramCost \\)       |    \\( 700 \\)    |   opcodes    | Maximum cost of application Approval or ClearState application program                                                            | `MaxAppProgramCost`            |
|       \\( \MaxAppProgramLen \\)       |  \\( 2{,}048 \\)  |    bytes     | Maximum length of application Approval or ClearState program page                                                                 | `MaxAppProgramLen`             |
|    \\( \MaxAppSumKeyValueLens \\)     |    \\( 128 \\)    |    bytes     | Maximum sum of the lengths of the key and value of one app state entry                                                            | `MaxAppSumKeyValueLens`        |
|      \\( \MaxAppTotalArgLen \\)       |  \\( 2{,}048 \\)  |    bytes     | Maximum sum of the lengths of argument for an `appl` transaction                                                                  | `MaxAppTotalArgLen`            |
|    \\( \MaxAbsoluteTotalArgLen \\)    | \\( 16{,}384 \\)  |    bytes     | Absolute maximum sum of argument lengths for an `appl` transaction; bytes beyond \\( \MaxAppTotalArgLen \\) incur a fee surcharge | `MaxAbsoluteTotalArgLen`       |
|    \\( \MaxAppTotalProgramLen \\)     |  \\( 2{,}048 \\)  |    bytes     | Maximum combined length of application Approval and ClearState programs                                                           | `MaxAppTotalProgramLen`        |
|   \\( \MaxAppTotalTxnReferences \\)   |     \\( 8 \\)     |              | Maximum number of references for an `appl` transaction                                                                            | `MaxAppTotalTxnReferences`     |
|      \\( \MaxAppTxnAccounts \\)       |     \\( 8 \\)     |              | Maximum number of account references for an `appl` transaction                                                                    | `MaxAppTxnAccounts`            |
|     \\( \MaxAppTxnForeignApps \\)     |     \\( 8 \\)     |              | Maximum number of application references for an `appl` transaction                                                                | `MaxAppTxnForeignApps`         |
|    \\( \MaxAppTxnForeignAssets \\)    |     \\( 8 \\)     |              | Maximum number of asset references for an `appl` transaction                                                                      | `MaxAppTxnForeignAssets`       |
|         \\( \MaxAppAccess \\)         |    \\( 16 \\)     |              | Maximum number of resources access list for an `appl` transaction                                                                 | `MaxAppAccess`                 |
|   \\( \MaxExtraAppProgramPages \\)    |     \\( 3 \\)     |              | Maximum extra length for application program in pages without a fee surcharge                                                     | `MaxExtraAppProgramPages`      |
| \\( \MaxAbsoluteExtraProgramPages \\) |     \\( 7 \\)     |              | Absolute maximum extra length for application program in pages; program bytes beyond the basic size incur a fee surcharge         | `MaxAbsoluteExtraProgramPages` |
|    \\( \MaxGlobalSchemaEntries \\)    |    \\( 64 \\)     |              | Maximum number of key/value pairs of application global state                                                                     | `MaxGlobalSchemaEntries`       |
|    \\( \MaxLocalSchemaEntries \\)     |    \\( 16 \\)     |              | Maximum number of key/value pairs of application local state                                                                      | `MaxLocalSchemaEntries`        |
|     \\( \MaxInnerTransactions \\)     |    \\( 16 \\)     |     txn      | Maximum number of inner transactions for an `appl` transaction                                                                    | `MaxInnerTransactions`         |
|    \\( \SchemaBytesMinBalance \\)     | \\( 25{,}000 \\)  |    μALGO     | Additional MBR for `[]bytes` values in application state                                                                          | `SchemaBytesMinBalance`        |
|   \\( \SchemaMinBalancePerEntry \\)   | \\( 25{,}000 \\)  |    μALGO     | MBR for key-value pair in application state                                                                                       | `SchemaMinBalancePerEntry`     |
|     \\( \SchemaUintMinBalance \\)     |  \\( 35{,}00 \\)  |    μALGO     | Additional MBR for `uint64` values in application state                                                                           | `SchemaUintMinBalance`         |

---

[^1]: \\( \StateProofStrengthTarget = 256 \\) is the value set for State Proofs of
type \\(0 \\). Other types of State Proofs might be added in the future.
\\( \StateProofStrengthTarget = \mathrm{target_{PQ}} \\) is set to achieve _post-quantum
security_ for State Proof. For further details, refer to the State Proofs
[normative specification](../crypto/crypto-state-proofs.md).
