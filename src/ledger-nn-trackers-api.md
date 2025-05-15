# Trackers API

Each _Tracker_ exposes tracker-specific APIs to access the state it maintains.

{{#include ./.include/styles.md:impl}}
> Tracker [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/ledger/tracker.go#L156-L169).

Trackers can access the Ledger through a restricted API, defined by `ledgerForTracker`,
allowing them to access the Ledger’s SQLite database, to query for blocks, etc.

Conversely, the Ledger accesses Trackers through the `ledgerTracker` interface:

- `loadFromDisk(ledgerForTracker)`\
Initializes the state of the Tracker. The Tracker can use the `ledgerForTracker`
argument to load persistent state (e.g., for the accounts database). The Tracker
can also query for recent blocks if its state depends only on recent blocks (e.g.,
the one that tracks recently committed transactions).

- `newBlock(rnd, delta)`\
Notifies the Tracker about a new block being added to the Ledger. `delta` provides
the state changes caused by this block (see [block evaluation section](./ledger-nn-block-commitment-and-evaluation.md)).

- `committedUpTo(rnd)`\
Informs the Tracker that all blocks up to and including `rnd` are written to persistent 
storage. This call is crucial for stateful trackers, as it ensures correct state
recovery and enables responses to queries about older blocks if recent uncommitted
ones are lost after a crash.

- `close()`\
Frees up any resources held by this Tracker.

The reference implementation serializes all updates to the Trackers with a _reader-writer
lock_.