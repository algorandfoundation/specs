# Trackers API

Each _Tracker_ exposes tracker-specific APIs to access the state it maintains.

{{#include ../../_include/styles.md:impl}}
> Tracker [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/ledger/tracker.go#L156-L169).

Trackers can access the Ledger via a restricted interface called `ledgerForTracker`,
which grants access to the Ledger’s SQLite database, recent blocks, and other read-only
functionality.

In the other direction, the Ledger communicates with Trackers using the `ledgerTracker`
interface, which includes the following key methods:

- `loadFromDisk(ledgerForTracker)`\
Initializes the state of the Tracker. The Tracker can use the `ledgerForTracker`
argument to:
  - Load persistent state (e.g., for the accounts database),
  - Query recent blocks, if its state depends only on recent history (e.g., the one
  that tracks recently committed transactions).

- `newBlock(rnd, delta)`\
Notifies the Tracker of a newly added block at round `rnd`. The accompanying `delta`
parameter contains the state changes introduced by this block (see [block evaluation
section](./ledger-nn-block-commitment.md)).

- `committedUpTo(rnd)`\
Informs the Tracker that all blocks up to and including `rnd` are written to persistent
storage. This call is crucial for stateful trackers, as it ensures correct state
recovery and enables responses to queries about older blocks if recent uncommitted
ones are lost after a crash.

- `close()`\
Releases any resources or memory held by the Tracker.

The reference implementation ensures that all updates to Trackers are _thread-safe_
using a _reader-writer lock_.
