$$
\newcommand \MaxTxTail {\mathrm{TxTail}_{\max}}
\newcommand \App {\mathrm{App}}
\newcommand \Box {\mathrm{Box}}
$$

# States

A _Ledger_ (\\( L \\)) is a sequence of states which comprise the common information
established by some instantiation of the Algorand protocol.

A Ledger is identified by a string called the _genesis identifier_, as well as a
_genesis hash_ that cryptographically commits to the starting state of the Ledger.

Each state consists of the following components:

- The _round_ of the state, which indexes into the Ledger's sequence of states.

- The _genesis identifier_ and _genesis hash_, which identify the Ledger to which
the state belongs.

- The current _protocol version_ and the _upgrade state_.

- A _timestamp_, which is informational and identifies when the state was first proposed.

- A _seed_, which is a source of randomness used to [establish consensus on the
next state](../abft/abft-messages-seed.md).

- The current _reward state_, which describes the policy at which incentives are
distributed to participants.

- The current _account state_, which holds account balances and [participation keys](../keys/keys-participation.md)
for all stakeholding addresses.

  - One component of this state is the _transaction tail_, which caches the _transaction
  sets_ (see below) in the last \\( \MaxTxTail \\) blocks.

- The current _box state_, which holds mappings from (\\( \App_{ID} \\), \\( \Box_{ID} \\))
tuples to box contents of arbitrary bytes.
