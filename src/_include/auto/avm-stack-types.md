| NAME | BOUND | AVM TYPE |
| :--- | :---- | :------: |
| `[]byte` | \\( len(x) \leq 4096 \\) | `[]byte` |
| `address` | \\( len(x) = 32 \\) | `[]byte` |
| `any` |  | `any` |
| `bigint` | \\( len(x) \leq 64 \\) | `[]byte` |
| `bool` | \\( x \leq 1 \\) | `uint64` |
| `boxName` | \\( 1 \leq len(x) \leq 64 \\) | `[]byte` |
| `method` | \\( len(x) = 4 \\) | `[]byte` |
| `none` |  | `none` |
| `stateKey` | \\( len(x) \leq 64 \\) | `[]byte` |
| `uint64` | \\( x \leq 18446744073709551615 \\) | `uint64` |

