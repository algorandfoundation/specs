# Flow Control

|       OPCODE        | DESCRIPTION                                                                                                                                  |
|:-------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------|
|        `err`        | Fail immediately.                                                                                                                            |
|    `bnz target`     | branch to TARGET if value A is not zero                                                                                                      |
|     `bz target`     | branch to TARGET if value A is zero                                                                                                          |
|     `b target`      | branch unconditionally to TARGET                                                                                                             |
|      `return`       | use A as success value; end                                                                                                                  |
|        `pop`        | discard A                                                                                                                                    |
|      `popn n`       | remove N values from the top of the stack                                                                                                    |
|        `dup`        | duplicate A                                                                                                                                  |
|       `dup2`        | duplicate A and B                                                                                                                            |
|      `dupn n`       | duplicate A, N times                                                                                                                         |
|       `dig n`       | Nth value from the top of the stack. dig 0 is equivalent to dup                                                                              |
|      `bury n`       | replace the Nth value from the top of the stack with A. bury 0 fails.                                                                        |
|      `cover n`      | remove top of stack, and place it deeper in the stack such that N elements are above it. Fails if stack depth <= N.                          |
|     `uncover n`     | remove the value at depth N in the stack and shift above items down so the Nth deep value is on top of the stack. Fails if stack depth <= N. |
|    `frame_dig i`    | Nth (signed) value from the frame pointer.                                                                                                   |
|   `frame_bury i`    | replace the Nth (signed) value from the frame pointer in the stack with A                                                                    |
|       `swap`        | swaps A and B on stack                                                                                                                       |
|      `select`       | selects one of two values based on top-of-stack: B if C != 0, else A                                                                         |
|      `assert`       | immediately fail unless A is a non-zero number                                                                                               |
|  `callsub target`   | branch unconditionally to TARGET, saving the next instruction on the call stack                                                              |
|     `proto a r`     | Prepare top call frame for a retsub that will assume A args and R return values.                                                             |
|      `retsub`       | pop the top instruction from the call stack and branch to it                                                                                 |
| `switch target ...` | branch to the Ath label. Continue at following instruction if index A exceeds the number of labels.                                          |
| `match target ...`  | given match cases from A[1] to A[N], branch to the Ith label where A[I] = B. Continue to the following instruction if no matches are found.  |
