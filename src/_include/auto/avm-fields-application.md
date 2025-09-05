| INDEX |         NAME          |  TYPE   | IN  | DESCRIPTION                                                                     |
|:-----:|:---------------------:|:-------:|:---:|:--------------------------------------------------------------------------------|
|   0   |  AppApprovalProgram   | []byte  |     | Bytecode of Approval Program                                                    |
|   1   | AppClearStateProgram  | []byte  |     | Bytecode of Clear State Program                                                 |
|   2   |   AppGlobalNumUint    | uint64  |     | Number of uint64 values allowed in Global State                                 |
|   3   | AppGlobalNumByteSlice | uint64  |     | Number of byte array values allowed in Global State                             |
|   4   |    AppLocalNumUint    | uint64  |     | Number of uint64 values allowed in Local State                                  |
|   5   | AppLocalNumByteSlice  | uint64  |     | Number of byte array values allowed in Local State                              |
|   6   | AppExtraProgramPages  | uint64  |     | Number of Extra Program Pages of code space                                     |
|   7   |      AppCreator       | address |     | Creator address                                                                 |
|   8   |      AppAddress       | address |     | Address for which this application has authority                                |
|   9   |      AppVersion       | uint64  | v12 | Version of the app, incremented each time the approval or clear program changes |
