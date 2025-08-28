|     OPCODE     | DESCRIPTION                                                                                                                                                   |
|:--------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  `itxn_begin`  | begin preparation of a new inner transaction in a new transaction group                                                                                       |
|  `itxn_next`   | begin preparation of a new inner transaction in the same transaction group                                                                                    |
| `itxn_field f` | set field F of the current inner transaction to A                                                                                                             |
| `itxn_submit`  | execute the current inner transaction group. Fail if executing this group would exceed the inner transaction limit, or if any transaction in the group fails. |
|    `itxn f`    | field F of the last inner transaction                                                                                                                         |
|  `itxna f i`   | Ith value of the array field F of the last inner transaction                                                                                                  |
|   `itxnas f`   | Ath value of the array field F of the last inner transaction                                                                                                  |
|  `gitxn t f`   | field F of the Tth transaction in the last inner group submitted                                                                                              |
| `gitxna t f i` | Ith value of the array field F from the Tth transaction in the last inner group submitted                                                                     |
| `gitxnas t f`  | Ath value of the array field F from the Tth transaction in the last inner group submitted                                                                     |