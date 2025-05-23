# Appendix A

## Copy On Write implementation strategy

```text
  ___________________
< cow = Copy On Write >
  -------------------
         \   ^__^
          \  (oo)\_______
             (__)\       )\/\
                 ||----w |
                 ||     ||
```

_Copy-On-Write_ (COW) is an optimization strategy designed to manage data structure
modifications efficiently. The fundamental principle behind COW is to defer the
copying of an object until it is actually modified, allowing multiple processes
or components to safely share a single instance of the object for as long as it
remains unchanged. A separate copy is created only when a write operation occurs,
ensuring both memory efficiency and data consistency.

The COW structure is part of the [Block Evaluator](ledger-nn-block-commitment.md).

In the `go-algorand` reference implementation, the `roundCowState` structure applies
the _Copy-On-Write_ (COW) strategy to manage the [State Delta](ledger-nn-state-delta.md).
It ensures that state copies are only created when modifications are necessary,
enabling efficient memory usage and optimized performance during state transitions
across blockchain rounds.

{{#include ../.include/styles.md:impl}}
> Copy on write [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/ledger/eval/cow.go).