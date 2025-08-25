$$
\newcommand \pk {\mathrm{pk}}
\newcommand \sk {\mathrm{sk}}
\newcommand \fv {\text{first}}
\newcommand \lv {\text{last}}
\newcommand \Sign {\mathrm{Sign}}
\newcommand \Verify {\mathrm{Verify}}
\newcommand \Rand {\mathrm{Rand}}
$$

# Identity, Authorization, and Authentication

A _player_ is uniquely identified by a 256-bit string \\( I \\) called an
_address_.

Each player owns exactly one _participation keypair_. A participation
keypair consists of a _public key_ \\( \pk \\) and a _secret key_ \\( \sk \\).

A keypair is defined in the [specification
of participation keys in Algorand](partkey-spec). Each participation
keypair is valid for a range of protocol rounds \\( [r_\fv, r_\lv] \\).

Let \\( m \\), \\( m' \\) be arbitrary sequences of bits.

Let \\( B_k \\), \\( \bar{B} \\) be 64-bit integers representing balances in μALGO
with rewards applied.

Let \\( \tau \\), \\( \bar{\tau} \\) be 32-bit integers, and \\( Q \\) be a 256-bit
string.

Let \\( (\pk_k, \sk_k) \\) be some valid keypair.

A secret key supports a _signing_ procedure

$$
y := \Sign(m, m', sk_k, B_k, \bar{B}, Q, \tau, \bar{\tau})
$$

Where \\( y \\) is opaque and cryptographically resistant to tampering, where defined.

Signing is not defined on many inputs: for any given input, signing may fail to
produce an output.

The following functions are defined on \\( y \\):

- _Verifying_: \\( \Verify(y, m, m', \pk_k, B_k, \bar{B}, Q, \tau, \bar{\tau}) = w \\)
where \\( w \\) is a 64-bit integer called the _weight_ of \\( y \\). \\( w \neq 0 \\)
if and only if \\( y \\) was produced by signing by \\( \sk_k \\) (up to cryptographic
security). \\( w \\) is uniquely determined given fixed values of \\( m', \pk_k, B_k,
\bar{B}, Q, \tau, \bar{\tau} \\).

- _Comparing_: Fixing the inputs \\( m', \bar{B}, Q, \tau, \bar{\tau} \\) to a signing 
operation, there exists a total ordering on the outputs \\( y \\). In other words,
if \\( f(\sk, B) = \Sign(m, m', \sk, B, \bar{B}, Q, \tau, \bar{\tau}) = y \\), and
\\( S = \\{(\sk_0, B_0), (\sk_1, B_1), \ldots, (\sk_n, B_n)\\} \\), then
\\( \\{f(x) | x \in S\\} \\) is a totally ordered set. We write that
\\( y_1 < y_2 \\) if \\( y_1 \\) comes before \\( y_2 \\) in this ordering.

- _Generating Randomness_: Let \\( y \\) be a valid output of a signing operation
with \\( \sk_k \\). Then \\( R = \Rand(y, \pk_k) \\) is defined to be a pseudorandom
256-bit integer (up to cryptographic security). \\( R \\) is uniquely determined
given fixed values of \\( m', \pk_k, B_k, \bar{B}, Q, \tau, \bar{\tau} \\).

The signing procedure is allowed to produce a nondeterministic output,
but the functions above must be well-defined with respect to a given
input to the signing procedure (e.g., a procedure that implements
\\( \Verify(\Sign(\ldots)) \\) always returns the same value).