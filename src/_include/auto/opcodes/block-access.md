| OPCODE | DESCRIPTION |
| :-: | :---------- |
| `online_stake` | the total online stake as of the balance round: 320 rounds before the current round |
| `log` | write A to log state of the current application |
| `block f` | field F of block A. Fail unless A falls between txn.LastValid-1002 and txn.FirstValid (exclusive) |
