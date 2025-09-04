# Context Tuple

The Algorand Agreement protocol may be modeled as a state machine. The state machine’s
progress is driven mainly by two types of events:

- **Time Events**: triggered by the node’s local clock. The Agreement Protocol
defines the duration of the timeouts for each protocol stage.

- **Threshold Events**: triggered by the votes expressed by randomly elected committees
and counted by the node. The Agreement Protocol defines the number of votes for each
protocol stage.

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

   - A round defines the top-level cycle of the Algorand Agreement protocol.
   - Completing a round adds a block to the ledger (i.e., the blockchain).
   - A round is composed of one or more _periods_.
   - Rounds are identified by a monotonically increasing unsigned 64-bit integer
   representing the ledger’s current size and the committed block’s round number.
   - Fundamentally, it serves as an increasing index into the blockchain, reflecting
   the progression of confirmed blocks.
   - Rounds’ progression is driven by _threshold events_.

1. **Period (\\( p \\))**:

   - A period is a cycle within a _round_.
   - One or more periods will be processed until the parent round completes by reaching
   consensus and producing a block
   - A period is composed of multiple _steps_.
   - Within a round, periods are identified by a monotonically increasing unsigned
   64-bit integer (starting with 0), indicating the current “run” (consensus attempt)
   of the same round.
   - Under ideal conditions \\( p = 0 \\), and remains so throughout the entire
   process from block proposal to block commitment.
   - If \\( p \neq 0 \\), the network is recovering from a failed attempt to commit
   a block within the current round. In such cases, all or some Agreement stages
   may be re-executed.
   - During recovery, [specific routines](#recovery-stages) monitor the network’s
   ability to reach consensus again. These routines may reuse information from previous
   failed attempts to speed up the block commitment once normal operation resumes.
   - Periods’ progression is driven by _threshold events_.

1. **Step (\\( s \\))**:

   - Steps are discrete units of logic that define each Algorand Agreement state machine’s states.
   - There are 5 separate steps. Each Step helps move closer to reaching consensus
   for the next block among the Algorand participants.
   - Some steps require a period of time to pass before moving to the next step.
   - Steps 4 and 5 will repeat with increasing timeouts until a consensus is reached
   for the current period.
   - Within a period, steps are identified by an unsigned 8-bit integer representing
   an enumeration of the possible Agreement Protocol stages. See the [normative section](./abft-parameters.md)
   for a formal definition of this enumeration.
   - Steps are bounded (`uint8_max = 255`) and follow the protocol’s predefined
   progression through its stages.
   - Steps’ progression is driven by _time events_.
