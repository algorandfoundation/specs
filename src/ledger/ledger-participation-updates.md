# Consensus Participation Updates

Participation updates contain two lists of account addresses for which changes are
made to their consensus participation status.

The first list contains accounts that have been deemed to be _expired_. An account
is said to be expired when the last valid vote round in its [participation key](../keys/keys-participation.md)
is strictly less than the current round that is being processed. Once included in
this list, an account will be marked _offline_ as part of applying the block changes
to the Ledger.

The second list contains accounts that have been deemed to be _suspended_. An account
is said to be suspended according to the rules specified above for _suspended participation
accounts_ list. Once included in this list, an account will be marked _offline_,
but its voting keys will be retained in the account state, as part of applying
the block changes to the Ledger. The `IncentiveEligible` flag of the account will
be set to false.
