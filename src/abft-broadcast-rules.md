Broadcast Rules
===============

Upon observing messages or receiving timeout events, the player state
machine emits network outputs, which are externally visible. The
player may also append an entry to the ledger.

A correct player emits only valid votes.  Suppose the player is
identified with the address $I$ and possesses the secret key $\sk$,
and the agreement is occurring on the ledger $L$.  Then the player
constructs a vote $\Vote(I, r, p, s, v)$ by doing the following:

 - Let $(\pk, B, r_\fv, r_\lv) = \Record(L, r - \delta_b, I)$,
   $\Bbar = \Stake(L, r - \delta_b)$, $Q = \Seed(L, r - \delta_s)$,
   $\tau = \CommitteeThreshold(s)$, $\taubar = \CommitteeSize(s).$

 - Encode $x := (I, r, p, s, v), x' := (I, r, p, s).$

 - Try to set $y := \Sign(x, x', \sk, B, \Bbar, Q, \tau, \taubar).$

If the signing procedure succeeds, the player broadcasts
$\Vote(I, r, p, s, v) = (I, r, p, s, v, y)$. Otherwise, the player
does not broadcast anything.

For certain broadcast vote-messages specified here, a node is
forbidden to _equivocate_ (i.e., produce a pair of votes which contain
the same round, period, and step but which vote for different proposal
values). These messages are marked with an asterisk (*) below. To
prevent accidental equivocation after a power failure, nodes should
checkpoint their state to crash-safe storage before sending these
messages.