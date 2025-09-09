$$
\newcommand \DefaultUpgradeWaitRounds {\delta_x}
\newcommand \UpgradeThreshold {\tau}
\newcommand \UpgradeVoteRounds {\delta_d}
$$

# Protocol Updates

The Algorand Foundation governs the development of the Algorand protocol. 

Updates to the Algorand protocol are executed through the following process: 

1. The Algorand Foundation announces and posts an official protocol specification
in the [public specifications repository](https://github.com/algorandfoundation/specs).

1. The URL of the repository `git` release commit is used as a _protocol version
identifier_. This URL must contain a hash corresponding to the `git` release commit.

1. To become effective, any protocol update must be approved _on-chain_ by a super
majority of block proposers. Each block proposer "supports" a protocol update proposal
by including its identifier as the next protocol version.

1. A protocol update is _accepted_ if for an interval of \\( \UpgradeVoteRounds \\)
rounds, at least \\( \UpgradeThreshold \\) of the finalized blocks support the same
next protocol version.

1. After the end of the \\( \UpgradeThreshold \\) rounds voting interval, node runners
are given another \\( \DefaultUpgradeWaitRounds \\) rounds to update their node software.

1. The new specification then takes effect and, from that point on, blocks are produced
based on the updated protocol rules.

> For the values of the upgrade parameters, refer to the [Ledger parameters specification](./ledger/ledger-parameters.md#protocol-upgrade).