| OPCODE | DESCRIPTION |
| :-: | :---------- |
| `+` | A plus B. Fail on overflow. |
| `-` | A minus B. Fail if B > A. |
| `/` | A divided by B (truncated division). Fail if B == 0. |
| `*` | A times B. Fail on overflow. |
| `<` | A less than B => {0 or 1} |
| `>` | A greater than B => {0 or 1} |
| `<=` | A less than or equal to B => {0 or 1} |
| `>=` | A greater than or equal to B => {0 or 1} |
| `&&` | A is not zero and B is not zero => {0 or 1} |
| `\|\|` | A is not zero or B is not zero => {0 or 1} |
| `shl` | A times 2^B, modulo 2^64 |
| `shr` | A divided by 2^B |
| `sqrt` | The largest integer I such that I^2 <= A |
| `bitlen` | The highest set bit in A. If A is a byte-array, it is interpreted as a big-endian unsigned integer. bitlen of 0 is 0, bitlen of 8 is 4 |
| `exp` | A raised to the Bth power. Fail if A == B == 0 and on overflow |
| `==` | A is equal to B => {0 or 1} |
| `!=` | A is not equal to B => {0 or 1} |
| `!` | A == 0 yields 1; else 0 |
| `itob` | converts uint64 A to big-endian byte array, always of length 8 |
| `btoi` | converts big-endian byte array A to uint64. Fails if len(A) > 8. Padded by leading 0s if len(A) < 8. |
| `%` | A modulo B. Fail if B == 0. |
| `\|` | A bitwise-or B |
| `&` | A bitwise-and B |
| `^` | A bitwise-xor B |
| `~` | bitwise invert value A |
| `mulw` | A times B as a 128-bit result in two uint64s. X is the high 64 bits, Y is the low |
| `addw` | A plus B as a 128-bit result. X is the carry-bit, Y is the low-order 64 bits. |
| `divw` | A,B / C. Fail if C == 0 or if result overflows. |
| `divmodw` | W,X = (A,B / C,D); Y,Z = (A,B modulo C,D) |
| `expw` | A raised to the Bth power as a 128-bit result in two uint64s. X is the high 64 bits, Y is the low. Fail if A == B == 0 or if the results exceeds 2^128-1 |
