$$
\newcommand \DefaultUpgradeWaitRounds {\delta_x}
\newcommand \UpgradeThreshold {\tau}
\newcommand \UpgradeVoteRounds {\delta_d}
$$

# Protocol Updates

The Algorand Foundation governs the development and maintenance of the Algorand protocol.

Protocol updates **SHALL** be executed through the following process:

## 1. Specification Publication

The Algorand Foundation **SHALL** publish the _official_ protocol specification in
the [public specifications' repository](https://github.com/algorandfoundation/specs).

## 2. Protocol Version Identification

Each _protocol version_ **SHALL** be uniquely identified by the URL of the corresponding
`git` release commit. This URL **MUST** include the cryptographic hash of the commit.

## 3. On-Chain Approval

A protocol update **SHALL** become effective only if it is approved on-chain by a
supermajority of block proposers. Each block proposer signals support for a protocol
update by including the _identifier_ of the proposed protocol version as the next
protocol version.

## 4. Acceptance Criteria

A protocol update **SHALL** be accepted if, for an interval of \\( \UpgradeVoteRounds \\)
consecutive rounds, at least \\( \UpgradeThreshold \\) of the finalized blocks reference
the same next protocol version.

## 5. Upgrade Grace Period

Upon acceptance, node operators **SHALL** be granted an additional \\( \DefaultUpgradeWaitRounds \\)
rounds to update their node software in accordance with the new specification.

## 6. Activation

Upon completion of the grace period, the updated protocol specification **SHALL**
take effect. From that point forward, blocks **MUST** be produced exclusively under
the updated protocol rules.

---

> [!NOTE]
> The values of the upgrade parameters are defined in the [Ledger Parameters Specification](./ledger/ledger-parameters.md#protocol-upgrade).

## Non-Normative Voting Walkthrough

> [!NOTE]
> This section illustrates the protocol-update process described above. It does
> not add to or modify the normative requirements.

### Initiating a Proposal

In the reference implementation, the proposer logic initiates an upgrade vote
when no other proposal is active by selecting an entry from the current
protocol's approved-upgrade configuration. The proposing block includes that
protocol version and its configured upgrade delay, and also signals approval
for the proposal.

While a proposal is active, a proposer that supports the proposed version
signals approval in its block. The proposal remains open for
\( \UpgradeVoteRounds \) rounds, counted from the proposal round. Approvals are
counted only before the voting deadline.

### Example Timelines

Let \( p \) be the proposal round, \( d \) the selected upgrade delay, and
\( a \) the number of approvals collected during the voting interval.

| Scenario | Voting interval | Result at round \( p + \UpgradeVoteRounds \) | Subsequent action |
|----------|-----------------|------------------------------------------------|-------------------|
| Successful vote | Rounds \( p \) through \( p + \UpgradeVoteRounds - 1 \) | \( a \geq \UpgradeThreshold \) | The grace period continues until round \( p + \UpgradeVoteRounds + d \), when the new protocol becomes active. |
| Failed vote | Rounds \( p \) through \( p + \UpgradeVoteRounds - 1 \) | \( a < \UpgradeThreshold \) | The proposal is cleared at the voting deadline; no protocol change is scheduled. |
| Retry after failure | A prior proposal was cleared at its deadline | No active proposal remains | A proposer can initiate a new proposal in the following round, subject to the current protocol's approved-upgrade configuration. |
