# Ed25519

Algorand uses the [Ed25519](https://tools.ietf.org/html/rfc8032) digital signature
scheme to sign data.

Algorand changes the Ed25519 verification algorithm in the following way (using
notation from [Ed25519](https://tools.ietf.org/html/rfc8032) specification):

- Reject if `R` or `A` (PK) are equal to one of the following (non-canonical encoding,
this check is actually required by [Ed25519](https://tools.ietf.org/html/rfc8032),
but not all libraries implement it):

  - `0100000000000000000000000000000000000000000000000000000000000080`
  - `ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
  - `EEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F`
  - `EEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
  - `EDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
  - `EDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F`
  - a point which holds `(x,y) where: 2**255 -19 <= y <= 2**255`. Where we remind
  that `y` is defined as the encoding of the point with the _right-most bit cleared_.

- Reject if `A` (PK) is equal to one of the following (small order points):

  - `0100000000000000000000000000000000000000000000000000000000000000`
  - `ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F`
  - `0000000000000000000000000000000000000000000000000000000000000080`
  - `0000000000000000000000000000000000000000000000000000000000000000`
  - `C7176A703D4DD84FBA3C0B760D10670F2A2053FA2C39CCC64EC7FD7792AC037A`
  - `C7176A703D4DD84FBA3C0B760D10670F2A2053FA2C39CCC64EC7FD7792AC03FA`
  - `26E8958FC2B227B045C3F489F2EF98F0D5DFAC05D3C63339B13802886D53FC05`
  - `26E8958FC2B227B045C3F489F2EF98F0D5DFAC05D3C63339B13802886D53FC85`

- Reject _non-canonical_ `S` (this check is actually required by [Ed25519](https://tools.ietf.org/html/rfc8032),
but not all libraries implement it):

  - `0 <= S < L`, where `L = 2^252+27742317777372353535851937790883648493`.

- Use the _cofactor equation_ (this is the default verification equation in [Ed25519](https://tools.ietf.org/html/rfc8032)):

  - `[8][S]B = [8]R + [8][K]A'`
