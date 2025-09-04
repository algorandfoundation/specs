# Voting and Participation Keys

A protocol _player_ (as defined in the [ABFT specification](../abft/abft-overview.md))
is any actor that participates in the Algorand agreement protocol.

This section specifies the key infrastructure required for an active _player_ to
take part in the protocol.

To participate in the agreement, a _player_ must control an account (that is, a
_root key_ pair), and must generate a set of _participation keys_ associated with
it.

To declare their intent to join the agreement protocol, players _register_ their
_participation keys_.

After some protocol rounds since the _participation keys_ registration on the Ledger
(known as _balance lookback period_ \\( \delta_b \\), defined in the [ABFT specification](../abft/abft-parameters.md)),
the player becomes an _active participant_ in the agreement protocol. From that round,
the account may be selected to propose blocks or to vote during the agreement protocol
stages, until the expiration of the _participation keys_ registration.

> For further details about the structure of a _participation keys_ registration
> (`keyreg`) transaction, refer to the Ledger [specification](../ledger/ledger-overview.md).
