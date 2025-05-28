# Seed

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
> Appendix A in the [Algorand Crypto Specification](../crypto/crypto.md).

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

1. Let \\((pk, B, r_{fv}, r_{lv}) = Record(L, r-\delta_b, I)\\); let \\(q_0 = Seed(L, r-\delta_s)\\).

2. If \\(p = 0\\), check \\(VRF.Verify(y, q_0, pk)\\), immediately returning
   failure if verification fails. Let
   \\(q_1 = Hash(I||VRF.ProofToHash(y))\\) and continue to step 4.

3. If \\(p \ne 0\\), let \\(q_1 = Hash(q_0)\\). Continue.

4. If \\(r \equiv (r \bmod \delta_s) \mod \delta_r\delta_s\\), then check
   \\(Q = Hash(q_1||DigestLookup(L, r-\delta_s\delta_r))\\). Otherwise,
   check \\(Q = q_1\\).

> Round \\(r\\) leader selection and committee selection both use the seed from
\\(r-\delta_s\\) and the balances / public keys from \\(r-\delta_b\\).

> For re-proposals, the period \\(p\\) used in this section is the _original_
period, not the reproposal period.

> For a detailed overview of the seed computation algorithm and some explanatory
> examples, refer to the non-normative [Algorand ABFT Overview](./abft-overview.md).