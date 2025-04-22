$$
\newcommand \Propose {\mathit{propose}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
\newcommand \Next {\mathit{next}}
\newcommand \CommitteeSize {\mathrm{CommitteeSize}}
\newcommand \CommitteeThreshold {\mathrm{CommitteeThreshold}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \Digest {\mathrm{Digest}}
\newcommand \Encoding {\mathrm{Encoding}}
\newcommand \Hash {\mathrm{Hash}}
$$

# Elementary Data Types

A _period_ \\( p \\) is a 64-bit integer.

A _step_ \\( s \\) is an 8-bit integer.

Steps are named for clarity and are defined as follows:

| STEP             | ENUMERATIVE   |
|------------------|---------------|
| \\( \Propose \\) | \\( 0 \\)     |
| \\( \Soft \\)    | \\( 1 \\)     |
| \\( \Cert \\)    | \\( 2 \\)     |
| \\( \Late \\)    | \\( 253 \\)   |
| \\( \Redo \\)    | \\( 254 \\)   |
| \\( \Down \\)    | \\( 255 \\)   |
| \\( \Next_s \\)  | \\( s + 3 \\) |

The following functions are defined on \\( s \\):

- \\( \CommitteeSize(s) \\) is a 64-bit integer defined as follows:

$$
\CommitteeSize(s) = \left\\{
\begin{array}{rl}
     20 & : s = \Propose \\\\
   2990 & : s = \Soft \\\\
   1500 & : s = \Cert \\\\
    500 & : s = \Late \\\\
   2400 & : s = \Redo \\\\
   6000 & : s = \Down \\\\
   5000 & : \text{otherwise}
\end{array}
\right.
$$

- \\( \CommitteeThreshold(s) \\) is a 64-bit integer defined as follows:

$$
\CommitteeThreshold(s) = \left\\{
\begin{array}{rl}
     0 & : s = \Propose \\\\
  2267 & : s = \Soft \\\\
  1112 & : s = \Cert \\\\
   320 & : s = \Late \\\\
  1768 & : s = \Redo \\\\
  4560 & : s = \Down \\\\
  3838 & : \text{otherwise}
\end{array}
\right.
$$

A _proposal-value_ is a tuple \\( v = (I, p, \Digest(e), \Hash(\Encoding(e))) \\)
where:

- \\( I \\) is an address (the "original proposer"),

- \\( p \\) is a period (the "original period"),

- \\( \Hash \\) is some cryptographic hash function.

The special proposal-value where all fields are the zero-string is called the _bottom
proposal_ \\( \bot \\).