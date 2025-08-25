# Byte Array Manipulation

|      OPCODE       | DESCRIPTION                                                                                                                                                                               |
|:-----------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     `getbit`      | Bth bit of (byte-array or integer) A. If B is greater than or equal to the bit length of the value (8*byte length), the program fails                                                     |
|     `setbit`      | Copy of (byte-array or integer) A, with the Bth bit set to (0 or 1) C. If B is greater than or equal to the bit length of the value (8*byte length), the program fails                    |
|     `getbyte`     | Bth byte of A, as an integer. If B is greater than or equal to the array length, the program fails                                                                                        |
|     `setbyte`     | Copy of A with the Bth byte set to small integer (between 0..255) C. If B is greater than or equal to the array length, the program fails                                                 |
|     `concat`      | Join A and B                                                                                                                                                                              |
|       `len`       | Yields length of byte value A                                                                                                                                                             |
|  `substring s e`  | A range of bytes from A starting at S up to but not including E. If E < S, or either is larger than the array length, the program fails                                                   |
|   `substring3`    | A range of bytes from A starting at B up to but not including C. If C < B, or either is larger than the array length, the program fails                                                   |
|   `extract s l`   | A range of bytes from A starting at S up to but not including S+L. If L is 0, then extract to the end of the string. If S or S+L is larger than the array length, the program fails       |
|    `extract3`     | A range of bytes from A starting at B up to but not including B+C. If B+C is larger than the array length, the program fails `extract3` can be called using `extract` with no immediates. |
| `extract_uint16`  | A uint16 formed from a range of big-endian bytes from A starting at B up to but not including B+2. If B+2 is larger than the array length, the program fails                              |
| `extract_uint32`  | A uint32 formed from a range of big-endian bytes from A starting at B up to but not including B+4. If B+4 is larger than the array length, the program fails                              |
| `extract_uint64`  | A uint64 formed from a range of big-endian bytes from A starting at B up to but not including B+8. If B+8 is larger than the array length, the program fails                              |
|   `replace2 s`    | Copy of A with the bytes starting at S replaced by the bytes of B. Fails if S+len(B) exceeds len(A) `replace2` can be called using `replace` with 1 immediate.                            |
|    `replace3`     | Copy of A with the bytes starting at B replaced by the bytes of C. Fails if B+len(C) exceeds len(A) `replace3` can be called using `replace` with no immediates.                          |
| `base64_decode e` | decode A which was base64-encoded using _encoding_ E. Fail if A is not base64 encoded with encoding E                                                                                     |
|   `json_ref r`    | key B's value, of type R, from a [valid](jsonspec.md) UTF-8 encoded json object A                                                                                                         |

The following opcodes take byte-array values that are interpreted as
big-endian unsigned integers.  For mathematical operators, the
returned values are the shortest byte-array that can represent the
returned value.  For example, the zero value is the empty
byte-array. For comparison operators, the returned value is a uint64.

Input lengths are limited to a maximum length of 64 bytes,
representing a 512 bit unsigned integer. Output lengths are not
explicitly restricted, though only `b*` and `b+` can produce a larger
output than their inputs, so there is an implicit length limit of 128
bytes on outputs.

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

These opcodes operate on the bits of byte-array values.  The shorter
input array is interpreted as though left padded with zeros until it is the
same length as the other input.  The returned values are the same
length as the longer input.  Therefore, unlike array arithmetic,
these results may contain leading zero bytes.

| OPCODE | DESCRIPTION                                                                     |
|:------:|:--------------------------------------------------------------------------------|
| `b\|`  | A bitwise-or B. A and B are zero-left extended to the greater of their lengths  |
|  `b&`  | A bitwise-and B. A and B are zero-left extended to the greater of their lengths |
|  `b^`  | A bitwise-xor B. A and B are zero-left extended to the greater of their lengths |
|  `b~`  | A with all bits inverted                                                        |