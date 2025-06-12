# Domain Separation

Before an object is input to some cryptographic function, it is prepended with a
multi-character domain-separating prefix.

All domain separators must be “prefix-free” (that is, they must not be concatenated).

The list below specifies each `prefix`:

- For cryptographic primitives:
  - `OT1` and `OT2`: The first and second layers of keys used for [ephemeral signatures](#ephemeral-key-signature).
  - `MA`: An internal node in a [Merkle tree](#merkle-tree).
  - `MB`: A bottom leaf in a [vector commitment](#vector-commitment).
  - `KP`: Is a public key used by the [Merkle Signature Scheme](merklesignaturescheme)
  - `spc`: A coin used as part of the state proofs construction.
  - `spp`: Participant’s information (state proof public key and weight) used for state proofs.
  - `sps`: A signature from a specific participant used for state proofs.

- In the [Algorand Ledger](ledger-spec):
  - `BH`: A _Block Header_.
  - `BR`: A _Balance Record_.
  - `GE`: A _Genesis_ configuration.
  - `spm`: A _State Proof_ message.
  - `STIB`: A _SignedTxnInBlock_ that appears as part of the leaf in the Merkle
  tree of transactions.
  - `TL`: A leaf in the Merkle tree of transactions.
  - `TX`: A _Transaction_.
  - `SpecialAddr`: A prefix used to generate designated addresses for specific functions,
  such as sending state proof transactions.

- In the [Algorand Byzantine Fault Tolerance protocol](abft-spec):
  - `AS`: An _Agreement Selector_, which is also a [VRF](VRF) input.
  - `CR`: A _Credential_.
  - `SD`: A _Seed_.
  - `PL`: A _Payload_.
  - `PS`: A _Proposer Seed_.
  - `VO`: A _Vote_.

- In other places:
  - `arc`: ARCs-related hashes <https://github.com/algorandfoundation/ARCs>. The
  prefix for ARC-XXXX should start with `arcXXXX` (where `XXXX` is the 0-padded
  number of the ARC). For example, ARC-0003 can use any prefix starting with `arc0003`.
  - `MX`: An arbitrary message used to prove ownership of a cryptographic secret.
  - `NPR`: A message that proves a peer’s stake in an Algorand networking implementation.
  - `TE`: An arbitrary message reserved for testing purposes.
  - `Program`: A TEAL bytecode program.
  - `ProgData`: Data that is signed within TEAL bytecode programs.

> Auctions are deprecated; however, their prefixes are still reserved in code:
> - `aB`: A _Bid_.
> - `aD`: A _Deposit_.
> - `aO`: An _Outcome_.
> - `aP`: Auction parameters.
> - `aS`: A _Settlement_.