$$
\newcommand \VRF {\mathrm{VRF}}
\newcommand \Prove {\mathrm{Prove}}
\newcommand \ProofToHash {\mathrm{ProofToHash}}
\newcommand \Secrets {\mathrm{Secrets}}
\newcommand \Rerand {\mathrm{Rerand}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \else {\textbf{else}}
\newcommand \endif {\textbf{end if}}
\newcommand \return {\textbf{return }}
$$

# Seed Calculation

The cryptographic seed is a source of randomness for many internal operations inside
the protocol.

A formal definition of the _seed_ can be found in the [normative specification](./abft-messages-seed.md).

This section provides an engineering and implementation-oriented way of conceptualizing
the seed computation, to ease its understanding.

> The following algorithm makes heavy use of \\( \VRF \\) specific functions. For
> more information on their definition and internal work, refer to the
> [Algorand Cryptographic Primitive Specification](crypto.md#verifiable-random-function).

## Notation

For the seed calculation algorithm, consider the following notation:

| SYMBOL                    | DESCRIPTION                                      |
|---------------------------|--------------------------------------------------|
| \\( I \\)                 | Player address                                   |
| \\( L \\)                 | Ledger (blocks and present sate)                 |
| \\( r \\)                 | Current protocol round                           |
| \\( p \\)                 | Current protocol period                          |
| \\( \delta_s \\)          | Seed lookback (rounds)                           |
| \\( \delta_r \\)          | Seed refresh interval (rounds)                   |
| \\( L[r - n] \\)          | Block \\( r - n \\) of the ledger                |
| \\( L[r - n]_Q \\)        | Seed of the block \\( r - n \\) of the ledger    |
| \\( H(x) \\)              | Hash of \\( x \\)                                |
| \\( \VRF \\)              | Verifiable Random Function                       |
| \\( \VRF.\Prove \\)       | Computes the proof \\( y \\) of the \\( \VRF \\) |
| \\( \VRF.\ProofToHash \\) | Computes the hash of \\( y \\)                   |
| \\( Q \\)                 | Randomness seed                                  |

## Algorithm

For the seed calculation algorithm, consider the following pseudocode:

---

\\( \textbf{Algorithm 1} \text{: Compute Seed and Proof} \\)

$$
\begin{aligned}
&\text{1: } \function \mathrm{ComputeSeedAndProof}(I) \\\\
&\text{2: } \qquad \if p = 0 \then \\\\
&\text{3: } \qquad \quad y \gets \VRF.\Prove(\Secrets(I)_{\text{VRFkey}}, L[r - \delta_s]_Q) \\\\
&\text{4: } \qquad \quad \alpha \gets H(I || \VRF.\ProofToHash(y)) \\\\
&\text{5: } \qquad \else \\\\
&\text{6: } \qquad \quad y \gets 0 \\\\
&\text{6: } \qquad \quad \alpha \gets H(L[r - \delta_s]_Q) \\\\
&\text{7: } \qquad \endif \\\\
&\text{9: } \qquad \if r \bmod (\delta_s\delta_r) < \delta_s \then \\\\
&\text{10:} \qquad \quad Q \gets H(\alpha || H(L[r - \delta_s \delta_r])) \\\\
&\text{11:} \qquad \else \\\\
&\text{12:} \qquad \quad Q \gets H(\alpha) \\\\
&\text{13:} \qquad \endif \\\\
&\text{14:} \qquad \return (Q, y) \\\\
&\text{15: } \endfunction
\end{aligned}
$$

---

> ⚙️ **IMPLEMENTATION**
>
> Seed computation [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/proposal.go#L155).

The function takes as input the _address_ \\( I \\) of an _online player_ who will
be computing the seed \\( Q \\).

Note that the player needs to have registered participation keys on the node computing
the seed, so as for the \\( \Secrets(I) \\) call (**Algorithm 1**, line 3) to retrieve
available \\( \VRF \\) secrets generated during that registration process.

> For more information on the types of keys a player has to use, refer to the
> [Algorand Participation Key Specification](./partkey.md#vrf-selection-keys).

The function computes the cryptographic seed appended to the _block candidate_
for round \\( r \\), which will be used (if said block candidate is committed) as
a source of randomness for the \\( \VRF \\) in a future round.

The seed is computed according to whether the function is called in the first period
of the round, \\( p = 0 \\), or not.

The function also computes the proof \\( y \\), bundled up with the block inside
a proposal structure (for broadcasting), and used by nodes receiving the proposal
as part of the proposal validation process.

## Example

The following is an example of seed computation in three adjacent blocks, chosen
to show both branches of the **Algorithm 1** execution, according to
\\( r \bmod \delta_s\delta_r \\) condition, also known as _re-randomization_.

Noting that:

- \\( \delta_s = 2 \\),
- \\( \delta_r = 80 \\).

We define \\( \Rerand(r) = r \bmod \delta_s\delta_r \\).

When \\( \Rerand(r) < \delta_s \\) we say we are _re-randomizing_ the seed \\( Q \\)
for the round \\( r \\).

> 📎 **EXAMPLE**
>
> Take the process for a player with _address_ \\( I \\) at the first consensus
> attempt of the round (\\( p = 0 \\)).
>
> - Let's consider round \\( r_a = 48182880 \\), as
>
> $$
> \Rerand(r_a) = 48182880 \bmod 160 = 0 < \delta_s
> $$
>
> The computation is:
>
> 1. Get the seed \\( Q \\) for round \\( r_a - \delta_s = (48182880 - 2) = 48182878 \\),
> 2. Construct a \\( \VRF \\) proof \\( y \\) with that seed,
> 3. Convert the \\( \VRF \\) proof \\( y \\) to a \\( \VRF \\) proof hash (named \\( \VRF_h \\)),
> 4. Hash the object \\( \\{I || \VRF_h\\} \\) (named \\( \alpha \\)),
> 5. Lookup the block digest of the old round \\( r_a - \delta_s\delta_r = 48182880 - 160 = 48182720 \\) (named \\( H_\text{old}\\)),
> 6. Calculate the final seed by hashing the object \\( \\{\alpha, H_\text{old} \\} \\).
>
> - This process will be the same for \\( r_b = 48182881 \\) as
>
> $$
> \Rerand(r_b) = 48182881 \bmod 160 = 1 < \delta_s
> $$
> 
> - For the round \\( r_c = 48182882 \\), since
>
> $$
> Rerand(r_c) = 48182882 \bmod 160 = 2 \ge \delta_s
> $$
>
> The computation is:
>
> 1. Get the seed \\( Q \\) for round \\( r_c - \delta_s = (48182882 - 2) = 48182880 \\),
> 2. Construct a \\( \VRF \\) proof \\( y \\) with that seed,
> 3. Convert the \\( \VRF \\) proof \\( y \\) to a \\( \VRF \\) proof hash (named \\( \VRF_h \\)),
> 4. Hash the object \\( \\{I || \VRF_h\\} \\) (named \\( \alpha \\)),
> 5. Calculate the final seed by hashing \\( \alpha \\).
>
> - This process will be the same for rounds \\( 48182883, \ldots, 48183039 \\) as
>
> $$
> \Rerand(48182883, \ldots, 48183039) > \delta_s.
> $$
>
> If during the execution of consensus for a given round, a period \\( p > 0 \\)
> is observed (i.e., the protocol is performing a new consensus attempt for the same
> round), steps 2-3-4 change calculating \\( \alpha \\) by hashing the seed of a
> round \\( r - \delta_s \\) (instead of the object \\( \\{I || \VRF_h\\}\\ \\)).
> This condition occurs when another proposal for the same round has to be created.
> In this case, to avoid the possibility of seed manipulation by malicious proposers,
> their input is excluded from the computation (as the process uses a seed that is
> \\( \delta_s \\) rounds in the past, outside potential attacker’s influence).