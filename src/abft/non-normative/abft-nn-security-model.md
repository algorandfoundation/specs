$$
\newcommand \StakeOn {\mathrm{StakeOnline}}
\newcommand \VRF {\mathrm{VRF}}
$$

# Security Model

The parameter selection of Algorand blockchain is based on a combination
of assumptions:

1. Majority of online honest stake,

1. Security of cryptographic primitives,

1. Upper bound on message latency.

## Honest Majority Assumption

Let’s define \\( \StakeOn_{r-322} \\) as the total "online" stake at round \\( r-322 \\).

For every round, at least \\( 80\\% \\) of \\( \StakeOn_{r-322} \\) is _honest_ in round \\( r \\).
(Larger committee sizes would be required if we assume a smaller honest majority ratio.)

## Cryptographic Assumptions

Algorand uses a digital signature scheme for message authentication. It uses a
\\( \VRF \\) and a hash function, modeled as random oracles in the context of the
consensus protocol analysis.

We allow an adversary to perform up to \\( 2^{128} \\) hash operations over the
system’s lifetime. This is an extraordinarily large number! With these many hash
operations, the adversary can find collisions in SHA-256 function, or mine \\( 25 \\)
billion years’ worth of Bitcoin blocks at today’s hash rate[^1].

## Security Against Dynamic Corruption

In the Algorand protocol, users change their ephemeral participation keys used for
every round. That is, after users sign their message for round \\( r \\), they delete
the ephemeral key used for signing, and fresh ephemeral keys will be used in future
rounds.

This allows Algorand to be secure against dynamic corruptions, where an adversary
may corrupt a user after seeing her propagate a message through the network.
(Recall that since users use their \\( \VRF \\)s to perform cryptographic self-selection,
an adversary does not even know whom to corrupt prior to round \\( r \\)).

Moreover, even if in the future an adversary corrupts all committee members for
a round \\( r \\), as the users holding the supermajority of stakes were honest
in round \\( r \\) and erased their ephemeral keys, no two distinct valid blocks
can be produced for the same round.

## Network Model

Algorand guarantees liveness assuming a maximum propagation delay on messages sent
through the network (see protocol parameters [normative section](../abft-parameters.md)).

Algorand guarantees safety ("no forks") even in the case of network partitions.
When a network partition heals, liveness recovers in linear time against an adversary
capable of dynamic corruptions, and in constant time otherwise. Refer to the protocol
run [non-normative section](./abft-nn-protocol-run-examples.md) for network partitioning
examples.

---

[^1]: \\( \sim900 \text{ [EH/s]} \\) in May 2025.
