$$
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \Propose {\mathit{propose}}
\newcommand \CommitteeThreshold {\mathrm{CommitteeThreshold}}
\newcommand \abs[1] {\lvert #1 \rvert}
$$

# Bundles

Let \\( V \\) be any set of votes and equivocation votes.

We say that \\( V \\) _is a bundle for \\( v \\) in round \\( r \\), period \\( p \\),
and step_ \\( s \\) (or a _bundle for \\( v \\) at_ \\( (r, p, s) \\)), denoted
\\( \Bundle(r, p, s, v) \\).

{{#include ../_include/styles.md:impl}}
> Bundle [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/bundle.go#L46).

Moreover, let \\( L \\) be a ledger where \\( \abs{L} \geq \delta_b \\).

We say that this bundle is _valid with respect to_ \\( L \\) (or simply _valid_ if
\\( L \\) is unambiguous) if the following conditions are true:

{{#include ../_include/styles.md:impl}}
> The reference implementation makes use of an asynchronous [Bundle verifying function](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/bundle.go#L147).

> See the non-normative [Algorand ABFT Overview](./abft-overview.md) for further
> details.

- Every element \\( a_i \in V \\) is valid with respect to \\( L \\).

- For any two elements \\( a_i, a_j \in V \\), \\( I_i \neq I_j \\).

- For any element \\( a_i \in V \\), \\( r_i = r, p_i = p, s_i = s \\).

- For any element \\( a_i \in V \\), either \\( a_i \\) is a vote and \\( v_i = v \\),
or \\( a_i \\) is an equivocation vote.

- Let \\( w_i \\) be the weight of the signature in \\( a_i \\). Then
\\( \sum_i w_i \geq \CommitteeThreshold(s) \\).
