$$
\newcommand \pk {\mathrm{pk}}
\newcommand \sk {\mathrm{sk}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \fv {\text{first}}
\newcommand \Record {\mathrm{Record}}
\newcommand \lv {\text{last}}
\newcommand \Stake {\mathrm{Stake}}
\newcommand \Seed {\mathrm{Seed}}
\newcommand \CommitteeThreshold {\mathrm{CommitteeThreshold}}
\newcommand \CommitteeSize {\mathrm{CommitteeSize}}
\newcommand \Sign {\mathrm{Sign}}
$$

# Broadcast Rules

Upon observing messages or receiving timeout events, the player state
machine emits network outputs, which are externally visible. The
player may also append an entry to the ledger.

A correct player emits only valid votes. Suppose the player is
identified with the address \\( I \\) and possesses the secret key \\( \sk \\),
and the agreement is occurring on the ledger \\(L\\). Then the player
constructs a vote \\( \Vote(I, r, p, s, v) \\) by doing the following:

- Let
  - \\(( \pk, B, r_\fv, r_\lv) = \Record(L, r - \delta_b, I) \\),
  - \\( \bar{B} = \Stake(L, r - \delta_b) \\),
  - \\( Q = \Seed(L, r - \delta_s) \\),
  - \\( \tau = \CommitteeThreshold(s) \\),
  - \\( \bar{\tau} = \CommitteeSize(s) \\).

- Encode \\( x := (I, r, p, s, v), x' := (I, r, p, s) \\).

- Try to set \\( y := \Sign(x, x', \sk, B, \bar{B}, Q, \tau, \bar{\tau}) \\).

If the signing procedure succeeds, the player broadcasts
\\( Vote(I, r, p, s, v) = (I, r, p, s, v, y) \\). Otherwise, the player
does not broadcast anything.

For certain broadcast vote-messages specified here, a node is
forbidden to _equivocate_ (i.e., produce a pair of votes which contain
the same round, period, and step but which vote for different proposal
values). These messages are marked with an asterisk (*) below. To
prevent accidental equivocation after a power failure, nodes **SHOULD**
checkpoint their state to crash-safe storage before sending these
messages.

> For further details on these checkpoint strategies, refer to the
> [non-normative Ledger specification](../ledger/non-normative/ledger-nn.md). For an in-depth
> review of broadcasting functionalities, refer to the [non-normative Network specification](../network/network-overview.md).
