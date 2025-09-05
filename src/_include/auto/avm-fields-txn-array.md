| INDEX |          NAME          |  TYPE   | IN | DESCRIPTION                                                                                 |
|:-----:|:----------------------:|:-------:|:--:|:--------------------------------------------------------------------------------------------|
|  26   |    ApplicationArgs     | []byte  | v2 | Arguments passed to the application in the ApplicationCall transaction                      |
|  28   |        Accounts        | address | v2 | Accounts listed in the ApplicationCall transaction                                          |
|  48   |         Assets         | uint64  | v3 | Foreign Assets listed in the ApplicationCall transaction                                    |
|  50   |      Applications      | uint64  | v3 | Foreign Apps listed in the ApplicationCall transaction                                      |
|  58   |          Logs          | []byte  | v5 | Log messages emitted by an application call (only with `itxn` in v5). Application mode only |
|  64   |  ApprovalProgramPages  | []byte  | v7 | Approval Program as an array of pages                                                       |
|  66   | ClearStateProgramPages | []byte  | v7 | ClearState Program as an array of pages                                                     |
