| ACTION | VALUE | DESCRIPTION |
| :----: | :---: | :---------- |
| `NoOp` | `0` | _Only_ execute the Approval Program associated with the _application ID_, with no additional effects. |
| `OptIn` | `1` | _Before_ executing the Approval Program, allocate _local state_ for this _application ID_ into the _sender_'s account data. |
| `CloseOut` | `2` | _After_ executing the Approval Program, clear any _local state_ for this _application ID_ out of the _sender_'s account data. |
| `ClearState` | `3` | _Do not_ execute the Approval Program, and instead execute the Clear State Program (which may not reject this transaction). Additionally, clear any _local state_ for the _application ID_ out of the _sender_’s account data (as in `CloseOutOC`). |
| `UpdateApplication` | `4` | _After_ executing the Approval Program, _replace_ the Approval Program and Clear State Program associated with the _application ID_ with the programs specified in this transaction. |
| `DeleteApplication` | `5` | _After_ executing the Approval Program, _delete_ the parameters of with the _application ID_ from the account data of the application’s creator. |
