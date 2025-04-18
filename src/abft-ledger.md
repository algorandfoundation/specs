# The Ledger of Entries

An _entry_ is a pair \\(e = (o, Q)\\) where \\(o\\) is some opaque object, and
\\(Q\\) is a 256-bit integer called a _seed_.

For a detailed definition of this object, see the [Algorand Ledger Specification](./ledger.md).

The following functions are defined on \\(e\\):

- _Encoding_: \\(Encoding(e) = x\\) where \\(x\\) is a variable-length bitstring.

- _Summarizing_: \\(Digest(e) = h\\) where \\(h\\) is a 256-bit integer. \\(h\\)
should be a cryptographic commitment to the contents of \\(e\\).

A _ledger_ is a sequence of entries \\(L = (e_1, e_2, \ldots, e_n)\\).

A _round_ \\(r\\) is some 64-bit index into this sequence.

The following functions are defined on \\(L\\):

- _Validating_: \\(ValidEntry(L, o) = 1\\) if and only if \\(o\\) is _valid_ with
respect to \\(L\\). This validity property is opaque.

- _Seed Lookup_: If \\(e_r = (o_r, Q_r)\\), then \\(Seed(L, r) = Q_r\\).

- _Record Lookup_: \\(Record(L, r, I_k) = (pk_{k,r}, B_{k,r}, r_{fv}, r_{lv})\\)
for some address \\(I_k\\), some public key \\(pk_{k,r}\\), and some 64-bit integer
\\(B_{k,r}\\). \\(r_{fv}\\) and \\(r_{lv}\\) define the first valid and last valid
rounds for this participating account.

- _Digest Lookup_: \\(DigestLookup(L, r) = Digest(e_r)\\).

- _Total Stake Lookup_: We use \\(\mathcal{K_{r_b,r_v}}\\) to represent all players
with participation keys at \\(r_b\\) that are eligible to vote at \\(r_v\\). Let
\\(\mathcal{K_{r_b,r_v}}\\) be the set of all \\(k\\) for which \\((pk_{k,r_b},
B_{k,r_b}, r_{fv}, r_{lv}) = Record(L, r_b, I_k)\\) and \\(r_{fv} \leq r_v \leq
r_{lv}\\) holds. Then \\(Stake(L, r_b, r_v) = \sum_{k \in \mathcal{K_{r_b,r_v}}}
B_{k,r_b}\\).

A ledger may support an opaque _entry generation_ procedure:

\\[
o := Entry(L, Q)
\\]

which produces an object \\(o\\) for which \\(ValidEntry(L, o) = 1\\).

> For implementation details on this procedure, see the _block assembly_ section
> in the [Algorand Ledger Overview](./ledger-overview.md).