# Summary

- [Algorand Specifications]()

---

# Introduction

- [Reading Guidelines](./reading-guidelines.md)

# Algorand BFT Protocol

- [Overview]()
- [Normative]()
  - [Notation](./abft-notation.md)
  - [Parameters](./abft-parameters.md)
  - [Ledger](./abft-ledger.md)
  - [Messages](./abft-messages.md)
    - [Data Types](./abft-messages-data-types.md)
    - [Votes](./abft-messages-votes.md)
    - [Bundles](./abft-messages-bundles.md)
    - [Proposals](./abft-messages-proposals.md)
    - [Seed](./abft-messages-seed.md)
- [Non-Normative](./abft-nn.md)
  - [General Concepts](./abft-nn-general-concepts.md)
  - [Context Tuple](./abft-nn-context-tuple.md)
  - [Security Model](./abft-nn-security-model.md)
  - [Seed Calculation](./abft-nn-seed-calculation.md)
  - [Agreement Stages](./abft-nn-agreement-stages.md)
    - [Dynamic Filter Timeout](./abft-nn-dynamic-filter-timeout.md)
    - [Block Proposal](./abft-nn-block-proposal.md)
    - [Soft Vote](./abft-nn-soft-vote.md)
    - [Vote Handler](./abft-nn-vote-handler.md)
    - [Proposal Handler](./abft-nn-proposal-handler.md)
    - [Bundle Handler](./abft-nn-bundle-handler.md)
    - [Commitment](./abft-nn-commitment.md)
  - [Recovery Stages](./abft-nn-recovery-stages.md)
    - [Resynchronization Attempt](./abft-nn-resync-attempt.md)
    - [Recovery](./abft-nn-recovery.md)
    - [Fast Recovery](./abft-nn-fast-recovery.md)
  - [Examples of Protocol Runs](./abft-nn-protocol-run-examples.md)
    - [Vanilla Run](./abft-nn-vanilla-run.md)
    - [Jalapeño Run](./abft-nn-jalapeno-run.md)
    - [Habanero Run](./abft-nn-habanero-run.md)

# Algorand Ledger

- [Overview]()
- [Normative]()
- [Non-Normative](./ledger-nn.md)
  - [Blocks](./ledger-nn-blocks.md)
    - [Block Header](./ledger-nn-block-header.md)
    - [Genesis Block](./ledger-nn-genesis-block.md)
    - [Block Verification](./ledger-nn-block-verification.md)
  - [Transactions]()
    - [Transaction Type Examples]()
  - [Trackers]()
    - [Trackers API]()
  - [Protocol Rewards]()
    - [Staking Rewards]()
  - [Transaction Tail]()
  - [Transaction Pool]()
    - [Parameters]()
    - [Fee Prioritization]()
    - [Update]()
    - [Ingestion]()
    - [Block Assembly]()
  - [Block Commitment]()
    - [State Deltas]()
  - [Appendix A](./ledger-nn-appendix-a.md)

# Algorand Virtual Machine

- [Overview]()
- [Normative]()
- [Non-Normative]()

# Algorand Keys

- [Overview]()
- [Normative]()
- [Non-Normative]()

# Algorand Cryptographic Primitives

- [Overview]()
- [Normative]()
- [Non-Normative]()

# Algorand Network

- [Overview](./network-overview.md)
- [Non-Normative](./network-nn.md)
  - [Notation](./network-nn-notation.md)
  - [Parameters](./network-nn-parameters.md)
  - [Message Handlers](./network-nn-message-handlers.md)
  - [Addressing](./network-nn-addressing.md)
  - [Network Identity](./network-nn-identity.md)
  - [Peer Management]()
  - [Network Definitions]()
    - [Relay Network]()
    - [P2P Network]()
    - [Hybrid Network]()
  - [Appendix A - External Libraries](./network-nn-appendix-a.md)
  - [Appendix B - Packets Examples](./network-nn-appendix-b.md)

---

[Contribution Guidelines](./contribution-guidelines.md)
[License]()
