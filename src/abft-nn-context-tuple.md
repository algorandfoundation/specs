# Context Tuple

The Algorand Agreement protocol may be modeled as a state machine.

Analogous to execution coordinates, three integers taken together provide enough
context on which stage of the protocol the state machine is currently processing.
This triplet is referred to throughout this document as the _context tuple_.

The _context tuple_ supplies the necessary information to determine the exact phase
of the Agreement Protocol being executed, or, in simpler terms, “where we are” in
the broader process.

> For details on the formal implications of these values in the overall protocol,
> refer to the Algorand Byzantine Fault Tolerance [normative section](./abft-parameters.md).

The components of the _context tuple_ are:

1. **Round (\\( r \\))**:

   - An unsigned 64-bit integer representing the ledger’s current size and the committed
   block’s round number.
   - Fundamentally, it serves as a monotonically increasing index into the blockchain,
   reflecting the progression of confirmed blocks.
   - Rounds’ progression is driven by _message events_.

1. **Period (\\( p \\))**:

   - An unsigned 64-bit integer indicating the current “run” (consensus attempt)
   of the same round.
   - Under ideal conditions \\( p = 0 \\), and remains so throughout the entire
   process from block proposal to block commitment.
   - If \\( p \neq 0 \\), the network is recovering from a failed attempt to commit
   a block within the current round. In such cases, all or some Agreement stages
   may be re-executed.
   - During recovery, [specific routines](#recovery-stages) monitor the network’s
   ability to reach consensus again. These routines may reuse information from previous
   failed attempts to speed up the block commitment once normal operation resumes.
   - Periods’ progression is driven by _message events_.

1. **Step (\\( s \\))**:
   - An unsigned 8-bit integer representing an enumeration of the possible Agreement
   Protocol stages. See the [normative section](./abft-parameters.md) for a formal
   definition of this enumeration.
   - Steps are bounded (`uint8_max = 255`) and follow the protocol’s predefined
   progression through its stages.
   - Steps’ progression is driven by _time events_.