$$
\newcommand \Proven {\mathrm{Proven}}
\newcommand \Signed {\mathrm{Signed}}
\newcommand \Leaf {\mathrm{Leaf}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \W {\mathrm{Weight}}
\newcommand \KLT {\mathrm{KeyLifeTime}}
\newcommand \SP {\mathrm{StateProof}}
\newcommand \pk {\mathrm{pk}}
\newcommand \StateProofPK {\SP_\pk}
\newcommand \SerializedMerkleSignature {\mathrm{SerializedMerkleSignature}}
\newcommand \Hin {\mathrm{Hin}}
\newcommand \Ver {\mathrm{Version}}
\newcommand \Cmt {\mathrm{Commitment}}
\newcommand \Participant {\mathrm{Participant}}
\newcommand \Sig {\mathrm{Signature}}
\newcommand \Msg {\mathrm{Message}}
\newcommand \SHAKE {\mathrm{SHAKE256}}
\newcommand \IntToInd {\mathrm{IntToInd}}
\newcommand \Coin {\mathrm{coin}}
\newcommand \Reveals {\mathit{Reveals}}
\newcommand \NRev {\mathit{Num}\Reveals}
\newcommand \MaxRev {\mathit{Max}\Reveals}
\newcommand \target {\mathrm{target}}
\newcommand \ceil {\mathrm{ceil}}
\newcommand \floor {\mathrm{floor}}
$$

# State Proofs

State Proofs (a.k.a. _Compact Certificates_) allow external parties to efficiently
validate Algorand blocks.

The [technical report](https://eprint.iacr.org/archive/2020/1568/20210330:194331)
provides the overall approach of State Proofs; this section describes the specific
details of how State Proofs are realized in Algorand.

As a brief summary of the technical report, State Proofs operate in three steps:

1. The first step is to commit to a set of participants eligible to produce signatures,
along with a weight for each participant. In Algorand's case, these end up being
the online accounts, and the weights are the account μALGO balances.

1. The second step is for each participant to sign the same message, and broadcast
this signature to others. In Algorand's case, the message would contain a commitment
on blocks in a specific period.

1. The third step is for Relay Nodes to collect these signatures from a significant
fraction of participants (by weight) and generate a State Proof. Given enough signatures,
a Relay Node can form a State Proof, which effectively consists of a small number
of signatures, pseudo-randomly chosen out of all the signatures.

The resulting State Proof proves that at least some \\( \Proven\W \\) of participants
have signed the message. The actual weight of all participants who have signed the
message must be greater than \\( \Proven\W \\).

## Participant Commitment

The State Proof scheme requires a commitment to a dense array of participants, in
some well-defined order. Algorand uses [Vector Commitment](./crypto-vector-commitment.md)
to guarantee this property.

Leaf hashing is done in the following manner:

$$
\Leaf = \Hash(\texttt{spp} || \W || \KLT || \StateProofPK), \\\\
$$

for each online participant.

Where:

- \\( \W \\) is a 64-bit, little-endian integer representing the participant’s
balance in μALGO,

- \\( \KLT \\) is a 64-bit, little-endian constant integer with value of \\( 256 \\),

- \\( \StateProofPK \\) is a 512-bit string representing the participant’s Merkle
signature scheme commitment.

## Signature Format

Similarly to the participant commitment, the State Proof scheme requires a commitment
to a signature array.

Leaf hashing is done in the following manner:

$$
\Leaf = \Hash(\texttt{sps} || L || \SerializedMerkleSignature), \\\\
$$

for each online participant.

Where:

- \\( L \\) is a 64-bit, little-endian integer representing the participant’s \\( L \\)
value as described in the [technical report](https://eprint.iacr.org/archive/2020/1568/20210330:194331).

- \\( \SerializedMerkleSignature \\) representing a Merkle Signature of the participant
[merkle signature binary representation](https://github.com/algorandfoundation/specs/blob/master/dev/partkey.md#signatures)

When a signature is missing in the signature array, i.e., the prover didn’t receive
a signature for this slot, the slot would be decoded as an empty string. As a result,
the vector commitment leaf of this slot would be the hash value of the constant
[domain separator](./crypto-domain-separators.md) `MB` (the bottom leaf).

## Choice of Revealed Signatures

As described in the [technical report](https://eprint.iacr.org/archive/2020/1568/20210330:194331)
section IV.A, a State Proof contains a pseudorandomly chosen set of signatures. The
choice is made using a coin.

In Algorand's implementation, the coin derivation is made in the following manner:

$$
\Hin = (\texttt{spc} || \Ver || \\\\
\Participant\Cmt || \ln(\Proven\W) || \\\\
\Sig\Cmt || \Signed\W || \\\\
\SP\Msg\Hash)
$$

Where:

- \\( \Ver \\) is an 8-bit constant with value of \\( 0 \\),

- \\( \Participant\Cmt \\) is a 512-bit string representing the vector commitment
root on the participant array'

- \\( \ln(\Proven\W) \\) an 8-bit string representing the _natural logarithm_
value of \\( \Proven\W \\) with 16 bits of precision, as described in [SNARK-Friendly
Weight Threshold Verification](https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/weight-thresh.pdf),

- \\( \Sig\Cmt \\) is a 512-bit string representing the vector commitment root on
the signature array,

- \\( \Signed\W \\) is a 64-bit, little-endian integer representing
the State Proof signed weight,

- \\( \SP\Msg\Hash \\) is a 256-bit string representing the message that the State
Proof would verify (it would be the hash result of the State Proof message).

For short, we refer below to the revealed signatures simply as _“reveals”_.

We compute:

$$
R = \SHAKE(\Hin)
$$

Then, for every reveal, we:

- Extract a 64-bit string from \\( R \\),

- Use rejection sampling and extract an additional 64-bit string from \\( R \\)
if needed.

This would guarantee a uniform random coin in \\( [0, \Signed\W) \\).

## State Proof Format

A State Proof consists of seven fields:

- The Vector Commitment root to the array of signatures, under the msgpack key `c`.

- The total weight of all signers whose signatures appear in the array of signatures,
under the msgpack key `w`.

- The Vector commitment proof for the signatures revealed above, under the msgpack
key `S`.

- The Vector commitment proof for the participants revealed above, under the msgpack
key `P`.

- The FALCON signature salt version, under the msgpack key `v`, is the expected salt
version of every signature in the state proof.

- The set of revealed signatures, chosen as described in section IV.A of the [technical
report](https://eprint.iacr.org/archive/2020/1568/20210330:194331), under the msgpack
key `r`. This set is stored as a msgpack map. The key of the map is the position
in the array of the participant whose signature is being revealed. The value in
the map is a msgpack struct with the following fields:

  - The participant information, encoded as described [above](#participant-commitment),
  under the msgpack key `p`.

  - The signature information, encoded as described [above](#signature-format),
  under the msgpack key `s`.

- A sequence of positions, under the msgpack key `pr`. The sequence defines the order
of the participant whose signature is being revealed. Example:

$$
\mathit{PositionsToReveal} = [\IntToInd(\Coin_0), \ldots , \IntToInd(\Coin_{\NRev-1})]
$$

Where \\( \IntToInd \\) and \\( \NRev \\) are defined in the [technical report](https://eprint.iacr.org/archive/2020/1568/20210330:194331),
section **IV**.

Note that, although the State Proof contains a commitment to the signatures, it does
not contain a commitment to the participants.

The set of participants must already be known to verify a State Proof. In practice,
a commitment to the participants is stored in the _Block Header_ of an earlier block,
and in the State Proof message proven by the previous State Proof.

## State Proof Validity

A State Proof is valid for the message hash, with respect to a commitment to the
array of participants, if:

- The depth of the vector commitment for the signature and the participant information
should be less than or equal to \\( 20 \\),

- All FALCON signatures should have the same salt version, and it should be equal
to the salt version specified in the State Proof,

- The number of reveals in the State Proof should be less than or equal to \\( 640 \\),

- Using the trusted \\( \Proven\W \\) (supplied by the verifier), the State Proof
should pass the [SNARK-Friendly Weight Threshold Verification](https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/weight-thresh.pdf)
check.

- All of the participant and signature information that appears in the reveals is
validated by the Vector Commitment proofs for the participants (against the commitment
to participants, supplied by the verifier) and signatures (against the commitment
in the state proof itself), respectively.

- All the signatures are valid signatures for the message hash.

- For every \\( i \in \\{0, \ldots , \NRev-1\\} \\) there is a reveal in map denoted
by \\( r_{i} \\), where \\( r_{i} \gets T[\mathit{PositionsToReveal}[i]] \\) and
\\( r_{i}.Sig.L \leq \Coin_i < r_{i}.Sig.L + r_{i}.Part.\W \\).

\\( T \\) is defined in the [technical report](https://eprint.iacr.org/archive/2020/1568/20210330:194331),
section **IV**.

## Setting Security Strength

- \\( \target_C \\): _“classical”_ security strength. This is set to \\( k + q \\)
(where \\( k + q \\) are defined in section **IV.A** of the [technical report](https://eprint.iacr.org/archive/2020/1568/20210330:194331)).
The goal is to have \\( <= 1/2^k \\) probability of breaking the State Proof by
an attacker that makes up to \\( 2^q \\) hash evaluations/queries. We use \\( \target_C = 192 \\),
which corresponds to, for example, \\( (k = 128, q = 64) \\), or \\( (k = 96, q = 96) \\).

- \\( \target_{PQ} \\): _“post-quantum”_ security strength. This is set to \\( k + 2q \\),
because at a cost of about \\( 2^q \\), a quantum attacker can search among up to \\( 2^{2q} \\)
hash evaluations (this is a highly attacker-favorable estimate). We use \\( \target_{PQ} = 256 \\),
which corresponds to, for example, \\( (k = 128, q = 64) \\), or \\( (k = 96, q = 80) \\).

## Bounding The Number of Reveals

In order for the SNARK prover for State Proofs to be efficient enough, we must impose
an upper-bound \\( \MaxRev_C \\) on the number of “reveals” the State Proof can contain,
while still reaching its target security strength \\( \target_C = 192 \\). Concretely,
we currently wish to set \\( \MaxRev_C = 480 \\).

Similarly, the _quantum-secure_ verifier aims for a larger security strength of
\\( \target_{PQ} = 256 \\), and we can also impose an upper-bound \\( \MaxRev_{PQ} \\)
on the number of reveals it can handle. (Recall that a smaller number of reveals
means that \\( \frac{\Signed\W}{\Proven\W} \\) must be larger to reach particular
security strength, so we cannot set \\( \MaxRev_C \\) or \\( \MaxRev_{PQ} \\) too
low.)

To generate a SNARK proof, we need to be able to “downgrade” a valid State Proof
with \\( \target_{PQ} \\) strength into one with merely \\( \target_C \\) strength,
by truncating some of the reveals to stay within the bounds.

First, let us prove that a valid State Proof with \(( NRev_{PQ} \\) number of reveals
that satisfies Equation (5) in [SNARK-Friendly Weight Threshold Verification](https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/weight-thresh.pdf)
for a given \\( \target_C \\) can be “downgrade” to have:

$$
\NRev_C = \ceil\left( \NRev_{PQ} \times \frac{\target_{C}}{\target_{PQ}} \right)
$$

We remark that values \\( d, b, T, Y, D \\) (in [SNARK-Friendly Weight Threshold Verification](https://github.com/algorandfoundation/specs/blob/master/dev/cryptographic-specs/weight-thresh.pdf))
only depend on \\( \Signed\W \\), but not the number of reveals nor the target.

Hence, we just need to prove that:

$$
\NRev_C >= \target_C \times T \times \frac{Y}{D}
$$

Which implies it is sufficient to prove:

$$
\NRev_{PQ} \times \frac{\target_C}{\target_{PQ}} >= \target_C \times T \times \frac{Y}{D}
$$

Since \\( \target_C > 0 \\) and \\( \target_{PQ} > 0 \\), we just need to prove
that:

$$
\NRev_{PQ} >= \target_{PQ} \times T \times \frac{Y}{D}.
$$

This last inequality holds since the State Proof satisfies Equation (5).

For a given \\( \MaxRev_C \\) and the desired security strengths, we need to calculate
a suitable \\( \target_{PQ} \\) bound so that the following property holds:

Since the “downgraded" State Proof has:

$$
\NRev_C = \ceil\left( \NRev_{PQ} \times \frac{\target_C}{\target_{PQ}} \right),
$$

And \\( \NRev_{PQ} <= \MaxRev_{PQ} \\), and \\( \NRev_C <= \MaxRev_C \\) we get:

$$
\MaxRev_C <= \ceil\left( \MaxRev_{PQ} \times \frac{\target_C}{\target_{PQ}} \right)
$$

And we can set

$$
\MaxRev_C <= \ceil\left( \MaxRev_{PQ} \times \frac{\target_C}{\target_{PQ}} \right)
$$

Since reveals do not bottleneck the _quantum-secure_ verifier, we can take:

$$
\MaxRev_{PQ} <= \floor\left( \MaxRev_C \times \frac{\target_{PQ}}{\target_C} \right)
$$

To be an equality, i.e., \\( \MaxRev_{PQ} = \floor(\ldots) \\).

Therefore, we must set \\( \MaxRev_{PQ} = 640 \\).
