| OPCODE | DESCRIPTION |
| :-: | :---------- |
| `app_opted_in` | 1 if account A is opted in to application B, else 0 |
| `app_local_get` | local state of the key B in the current application in account A |
| `app_local_get_ex` | X is the local state of application B, key C in account A. Y is 1 if key existed, else 0 |
| `app_global_get` | global state of the key A in the current application |
| `app_global_get_ex` | X is the global state of application A, key B. Y is 1 if key existed, else 0 |
| `app_local_put` | write C to key B in account A's local state of the current application |
| `app_global_put` | write B to key A in the global state of the current application |
| `app_local_del` | delete key B from account A's local state of the current application |
| `app_global_del` | delete key A from the global state of the current application |
| `app_params_get f` | X is field F from app A. Y is 1 if A exists, else 0 |
