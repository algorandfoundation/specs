|         OPCODE          | DESCRIPTION                                                                                                                                       |
|:-----------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------|
|        `sha256`         | SHA256 hash of value A, yields [32]byte                                                                                                           |
|       `keccak256`       | Keccak256 hash of value A, yields [32]byte                                                                                                        |
|      `sha512_256`       | SHA512_256 hash of value A, yields [32]byte                                                                                                       |
|       `sha3_256`        | SHA3_256 hash of value A, yields [32]byte                                                                                                         |
|     `falcon_verify`     | for (data A, compressed-format signature B, pubkey C) verify the signature of data against the pubkey => {0 or 1}                                 |
|     `ed25519verify`     | for (data A, signature B, pubkey C) verify the signature of ("ProgData" \|\| program_hash \|\| data) against the pubkey => {0 or 1}               |
|  `ed25519verify_bare`   | for (data A, signature B, pubkey C) verify the signature of the data against the pubkey => {0 or 1}                                               |
|    `ecdsa_verify v`     | for (data A, signature B, C and pubkey D, E) verify the signature of the data against the pubkey => {0 or 1}                                      |
|  `ecdsa_pk_recover v`   | for (data A, recovery id B, signature C, D) recover a public key                                                                                  |
| `ecdsa_pk_decompress v` | decompress pubkey A into components X, Y                                                                                                          |
|     `vrf_verify s`      | Verify the proof B of message A against pubkey C. Returns vrf output and verification flag.                                                       |
|       `ec_add g`        | for curve points A and B, return the curve point A + B                                                                                            |
|    `ec_scalar_mul g`    | for curve point A and scalar B, return the curve point BA, the point A multiplied by the scalar B.                                                |
|  `ec_pairing_check g`   | 1 if the product of the pairing of each point in A with its respective point in B is equal to the identity element of the target group Gt, else 0 |
| `ec_multi_scalar_mul g` | for curve points A and scalars B, return curve point B0A0 + B1A1 + B2A2 + ... + BnAn                                                              |
|  `ec_subgroup_check g`  | 1 if A is in the main prime-order subgroup of G (including the point at infinity) else 0. Program fails if A is not in G at all.                  |
|      `ec_map_to g`      | maps field element A to group G                                                                                                                   |
|        `mimc c`         | MiMC hash of scalars A, using curve and parameters specified by configuration C                                                                   |
