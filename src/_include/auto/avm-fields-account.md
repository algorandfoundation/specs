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
