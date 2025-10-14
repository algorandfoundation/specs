# What AVM Programs Cannot Do

Design and implementation limitations to be aware of with various Versions.

- Logic Signatures cannot lookup balances of ALGO or other assets. Standard transaction
accounting will apply after the Logic Signature has authorized a transaction. A transaction
could still be invalid by other accounting rules just as a standard signed transaction
could be invalid (e.g., I can't give away money I don't have).

- Programs cannot access information in previous blocks.

- Programs cannot access information in other transactions in the current block,
unless they are a part of the same transaction group.

- Logic Signatures cannot know exactly what round the current transaction will commit
in (but it is somewhere in between transaction _first_ and _last valid round_).

- Programs cannot know exactly what _time_ its transaction is committed.

- Programs cannot loop prior to Version 4. In Versoin 3 and prior, the branch instructions
`bnz` ("branch if not zero"), `bz` ("branch if zero") and `b` ("branch") can only
branch forward.

- Until Version 4, the AVM had no notion of subroutines (and therefore no recursion).
As of Version 4, they are available through the opcodes `callsub` and `retsub`.

- Programs cannot make _indirect jumps_. `b`, `bz`, `bnz`, and `callsub` jump to
an immediately specified address, and `retsub` jumps to the address currently on
the top of the call Stack, which is manipulated only by previous calls to `callsub`
and `retsub`.
