|         OPCODE         | DESCRIPTION                                                                                                                          |
|:----------------------:|:-------------------------------------------------------------------------------------------------------------------------------------|
|  `intcblock uint ...`  | prepare block of uint64 constants for use by intc                                                                                    |
|        `intc i`        | Ith constant from intcblock                                                                                                          |
|        `intc_0`        | constant 0 from intcblock                                                                                                            |
|        `intc_1`        | constant 1 from intcblock                                                                                                            |
|        `intc_2`        | constant 2 from intcblock                                                                                                            |
|        `intc_3`        | constant 3 from intcblock                                                                                                            |
|     `pushint uint`     | immediate UINT                                                                                                                       |
|  `pushints uint ...`   | push sequence of immediate uints to stack in the order they appear (first uint being deepest)                                        |
| `bytecblock bytes ...` | prepare block of byte-array constants for use by bytec                                                                               |
|       `bytec i`        | Ith constant from bytecblock                                                                                                         |
|       `bytec_0`        | constant 0 from bytecblock                                                                                                           |
|       `bytec_1`        | constant 1 from bytecblock                                                                                                           |
|       `bytec_2`        | constant 2 from bytecblock                                                                                                           |
|       `bytec_3`        | constant 3 from bytecblock                                                                                                           |
|   `pushbytes bytes`    | immediate BYTES                                                                                                                      |
| `pushbytess bytes ...` | push sequences of immediate byte arrays to stack (first byte array being deepest)                                                    |
|        `bzero`         | zero filled byte-array of length A                                                                                                   |
|        `arg n`         | Nth LogicSig argument                                                                                                                |
|        `arg_0`         | LogicSig argument 0                                                                                                                  |
|        `arg_1`         | LogicSig argument 1                                                                                                                  |
|        `arg_2`         | LogicSig argument 2                                                                                                                  |
|        `arg_3`         | LogicSig argument 3                                                                                                                  |
|         `args`         | Ath LogicSig argument                                                                                                                |
|        `txn f`         | field F of current transaction                                                                                                       |
|       `gtxn t f`       | field F of the Tth transaction in the current group                                                                                  |
|       `txna f i`       | Ith value of the array field F of the current transaction `txna` can be called using `txn` with 2 immediates.                        |
|       `txnas f`        | Ath value of the array field F of the current transaction                                                                            |
|     `gtxna t f i`      | Ith value of the array field F from the Tth transaction in the current group `gtxna` can be called using `gtxn` with 3 immediates.   |
|      `gtxnas t f`      | Ath value of the array field F from the Tth transaction in the current group                                                         |
|       `gtxns f`        | field F of the Ath transaction in the current group                                                                                  |
|      `gtxnsa f i`      | Ith value of the array field F from the Ath transaction in the current group `gtxnsa` can be called using `gtxns` with 2 immediates. |
|      `gtxnsas f`       | Bth value of the array field F from the Ath transaction in the current group                                                         |
|       `global f`       | global field F                                                                                                                       |
|        `load i`        | Ith scratch space value. All scratch spaces are 0 at program start.                                                                  |
|        `loads`         | Ath scratch space value.  All scratch spaces are 0 at program start.                                                                 |
|       `store i`        | store A to the Ith scratch space                                                                                                     |
|        `stores`        | store B to the Ath scratch space                                                                                                     |
|      `gload t i`       | Ith scratch space value of the Tth transaction in the current group                                                                  |
|       `gloads i`       | Ith scratch space value of the Ath transaction in the current group                                                                  |
|       `gloadss`        | Bth scratch space value of the Ath transaction in the current group                                                                  |
|        `gaid t`        | ID of the asset or application created in the Tth transaction of the current group                                                   |
|        `gaids`         | ID of the asset or application created in the Ath transaction of the current group                                                   |
