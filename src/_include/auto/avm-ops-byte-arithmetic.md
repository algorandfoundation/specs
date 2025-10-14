| OPCODE  | DESCRIPTION                                                                                                      |
|:-------:|:-----------------------------------------------------------------------------------------------------------------|
|  `b+`   | A plus B. A and B are interpreted as big-endian unsigned integers                                                |
|  `b-`   | A minus B. A and B are interpreted as big-endian unsigned integers. Fail on underflow.                           |
|  `b/`   | A divided by B (truncated division). A and B are interpreted as big-endian unsigned integers. Fail if B is zero. |
|  `b*`   | A times B. A and B are interpreted as big-endian unsigned integers.                                              |
|  `b<`   | 1 if A is less than B, else 0. A and B are interpreted as big-endian unsigned integers                           |
|  `b>`   | 1 if A is greater than B, else 0. A and B are interpreted as big-endian unsigned integers                        |
|  `b<=`  | 1 if A is less than or equal to B, else 0. A and B are interpreted as big-endian unsigned integers               |
|  `b>=`  | 1 if A is greater than or equal to B, else 0. A and B are interpreted as big-endian unsigned integers            |
|  `b==`  | 1 if A is equal to B, else 0. A and B are interpreted as big-endian unsigned integers                            |
|  `b!=`  | 0 if A is equal to B, else 1. A and B are interpreted as big-endian unsigned integers                            |
|  `b%`   | A modulo B. A and B are interpreted as big-endian unsigned integers. Fail if B is zero.                          |
| `bsqrt` | The largest integer I such that I^2 <= A. A and I are interpreted as big-endian unsigned integers                |
