$$
\newcommand \pk {\mathrm{pk}}
\newcommand \fv {\text{first}}
\newcommand \lv {\text{last}}
\newcommand \Sign {\mathrm{Sign}}
\newcommand \ValidEntry {\mathrm{ValidEntry}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Digest {\mathrm{Digest}}
\newcommand \Encoding {\mathrm{Encoding}}
\newcommand \Record {\mathrm{Record}}
\newcommand \Verify {\mathrm{Verify}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \abs[1] {\lvert #1 \rvert}
$$

# Proposals

Let \\( e = (o, s) \\) be an entry and \\( y \\) be the output of a \\( \Sign \\)
procedure.

The pair \\( (e, y) \\) is a _proposal_ or a _proposal payload_.

Moreover, let

- \\( L \\) be a ledger where \\( \abs{L} \geq \delta_b \\),

- \\( v = (I, p, h, x) \\) be some proposal-value.

We say that this proposal is _a valid proposal matching \\( v \\) with respect to
\\( L \\)_ (or simply that this proposal _matches \\( v \\)_ if \\( L \\) is unambiguous)
if the following conditions are true:

- \\( \ValidEntry(L, e) = 1 \\),

- \\( h = \Digest(e) \\),

- \\( x = \Hash(\Encoding(e)) \\),

- The seed \\( s \\) and seed proof are valid as specified in the following section,

- Let \\( (\pk, B, r_\fv, r_\lv) = \Record(L, r - \delta_b, I) \\),
  - If \\( p = 0 \\), then \\( \Verify(y, Q_0, Q_0, \pk, 0, 0, 0, 0, 0) \neq 0 \\),

- Let \\( (\pk, B, r_\fv, r_\lv) = \Record(L, r - \delta_b, I) \\).
Then \\( r_\fv \leq r \leq r_\lv \\).

If \\( e \\) matches \\( v \\), we write \\( e = \Proposal(v) \\).
