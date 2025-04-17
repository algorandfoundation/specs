# Messages

Players communicate with each other by exchanging _messages_.

A message is an opaque object containing arbitrary data, save for the fields defined
below.

> For a detailed overview of message composition, whether consensus or other types,
> see the [Algorand Network Overview](./network-overview.md).

## Elementary Data Types

A _period_ \\(p\\) is a 64-bit integer.

A _step_ \\(s\\) is an 8-bit integer.

Steps are named for clarity and are defined as follows:

| STEP          | ENUMERATIVE |
|---------------|-------------|
| \\(Propose\\) | \\(0\\)     |
| \\(Soft\\)    | \\(1\\)     |
| \\(Cert\\)    | \\(2\\)     |
| \\(Late\\)    | \\(253\\)   |
| \\(Redo\\)    | \\(254\\)   |
| \\(Down\\)    | \\(255\\)   |
| \\(Next_s\\)  | \\(s + 3\\) |

The following functions are defined on \\(s\\):

- _Committee Size_: \\(CommitteeSize(s)\\) is a 64-bit integer defined as follows:

  \\[
  CommitteeSize(s) =
  \begin{cases}
  20 & : s = Propose \\\\\\
  2990 & : s = Soft \\\\\\
  1500 & : s = Cert \\\\\\
  500 & : s = Late \\\\\\
  2400 & : s = Redo \\\\\\
  6000 & : s = Down \\\\\\
   5000 & : \text{otherwise}
  \end{cases}
  \\]

- _Committee Threshold_: \\(CommitteeThreshold(s)\\) is a 64-bit integer defined
as follows:

  \\[
  CommitteeThreshold(s) =
  \begin{cases} 
  0 & : s = Propose \\\\\\
  2267 & : s = Soft \\\\\\
  1112 & : s = Cert \\\\\\
  320 & : s = Late \\\\\\
  1768 & : s = Redo \\\\\\
  4560 & : s = Down \\\\\\
  3838 & : \text{otherwise}
  \end{cases}
  \\]

A _proposal-value_ is a tuple \\(v = (I, p, Digest(e), Hash(Encoding(e)))\\) where:

- \\(I\\) is an address (the "original proposer"),
- \\(p\\) is a period (the "original period"),
- \\(Hash\\) is some cryptographic hash function.

The special proposal-value where all fields are the zero-string is called the _bottom
proposal_ \\(\bot\\).

## Seed

Informally, the protocol interleaves \\(\delta_s\\) seeds in an alternating
sequence. Each seed is derived from a seed \\(\delta_s\\) rounds in the past through
either a hash function or through a VRF, keyed on the entry
proposer. Additionally, every \\(\delta_s\delta_r\\) rounds, the digest of a previous entry
(specifically, from round \\(r-\delta_s\delta_r\\)) is hashed into the result. The seed
proof is the corresponding VRF proof, or 0 if the VRF was not used.

> This section makes use of the \\(VRF.Prove(.)\\), \\(VRF.ProofToHash(.)\\) and
> \\(VRF.Verify(.)\\) cryptographic low-leve functions defined in the reference
> implementation's Algorand Sodium Fork. They respectively output a \\(VRF\\) proof
> and a \\(VRF\\) hash for a given input, and perform verification of a \\(VRF\\)
> run. For details on the input structure and inner workings, please refer to the
> Appendix A in the [Algorand Crypto Specification](./crypto.md).

More formally, suppose \\(I\\) is a correct proposer in round \\(r\\) and period
\\(p\\).

Let

- \\((pk, B, r_{fv}, r_{lv}) = Record(L, r - \delta_b, I)\\),
- \\(sk\\) be the secret key corresponding to \\(pk\\),
- \\(\alpha\\) be a 256-bit integer.

Then \\(I\\) computes the seed proof \\(y\\) for a new entry as follows:

- If \\(p = 0\\):
  - \\(y = VRF.Prove(Seed(L, r-\delta_s), sk)\\),
  - \\(\alpha = Hash(I || VRF.ProofToHash(y))\\).

- If \\(p \ne 0\\):
  - \\(y = 0\\),
  - \\(\alpha = Hash(Seed(L, r-\delta_s))\\).

Now \\(I\\) computes the seed \\(Q\\) as follows:

\\[
Q =
\begin{cases}
  Hash(\alpha || DigestLookup(L, r-\delta_s\delta_r)) & : (r \bmod \delta_s\delta_r) < \delta_s \\\\\\
  Hash(\alpha) & : \text{otherwise}
\end{cases}
\\]

The seed is valid if the following verification procedure succeeds:

1. Let \\((\pk, B, r_{fv}, r_{lv}) = Record(L, r-\delta_b, I)\\); let \\(q_0 = Seed(L, r-\delta_s)\\).

2. If \\(p = 0\\), check \\(VRF.Verify(y, q_0, pk)\\), immediately returning
   failure if verification fails. Let
   \\(q_1 = Hash(I||VRF.ProofToHash(y))\\) and continue to step 4.

3. If \\(p \ne 0\\), let \\(q_1 = \Hash(q_0)\\). Continue.

4. If \\(r \equiv (r \bmod \delta_s) \mod \delta_r\delta_s\\), then check
   \\(Q = Hash(q_1||DigestLookup(L, r-\delta_s\delta_r))\\). Otherwise,
   check \\(Q = q_1\\).

> Round \\(r\\) leader selection and committee selection both use the seed from
\\(r-\delta_s\\) and the balances / public keys from \\(r-\delta_b\\).

> For re-proposals, the period \\(p\\) used in this section is the _original_
period, not the reproposal period.

> For a detailed overview of the seed computation algorithm and some explanatory
> examples, refer to the non-normative [Algorand ABFT Overview](./abft-overview.md).