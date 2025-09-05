$$
\newcommand \SoftVote {\mathrm{SoftVote}}
\newcommand \CredentialHistory {\mathbf{C}}
\newcommand \CredentialHistorySize {|\CredentialHistory|}
\newcommand \CredentialIdx {i^\ast}
\newcommand \Timeout {T_\SoftVote}
\newcommand \TimeoutGracePeriod {T_\epsilon}
\newcommand \lambdaMin {\lambda_\text{0min}}
\newcommand \lambdaMax {\lambda_\text{0max}}
\newcommand \deltaL {\delta_\text{lag}}
$$

# Dynamic Filter Timeout

An adaptive algorithm computes the _dynamic filter timeout_ (i.e., the timeout to
trigger a call to \\( \SoftVote \\)).

In regular conditions, the _filtering timeout_ \\( \Timeout \\) tends to the minimum
\\( \lambdaMin \\).

Whenever network conditions force the round advancement to stall, \\( \Timeout \\)
will diverge towards the maximum of \\( \lambdaMax \\).

> See the formal definition of the filtering timeout parameters in the [ABFT
> normative section](./abft-parameters.md).

> ⚙️ **IMPLEMENTATION**
>
> Dynamic filter timeout [to reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/player.go#L318).

## Algorithm

Let \\( \CredentialHistory \\) be a circular array of size \\( \CredentialHistorySize \\),
whose elements are rounds' _minimum credential arrival time_, defined as the time
(elapsed since the start of \\( r \\)) at which the highest priority _proposal vote_
was observed for that round.

> See the formal definition of the lowest credential priority function in the
> [ABFT normative section](./abft-player-state.md#special-values).

We now define the _credential round lag_, as:

$$
\deltaL = \min \left\\{ \left\lfloor \frac{2\lambda}{\lambdaMin} \right\rfloor, 8 \right\\}
$$

to be the rounds’ lookback[^1] for \\( \CredentialHistory \\).

The node tracks in \\( \CredentialHistory \\) the minimum credential arrival time
for a certain number of rounds before \\( r - \deltaL \\).

Every time a round \\( r \\) is “successfully” completed[^2], the node looks up
the arrival time of the relevant credential for the round \\( r - \deltaL \\), and
pushes it into \\( \CredentialHistory \\). If the circular array is full, the oldest
entry is deleted).

It is worth noting that only rounds completed in the first attempt (\\( p = 0 \\))
are considered and relevant for \\( \CredentialHistory \\). If the round is completed
in later periods (\\( p > 0 \\)), that round is skipped and \\( \CredentialHistory \\)
remains unchanged.

{{#include ../_include/styles.md:impl}}
> Update credential arrival history [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/player.go#L293).

When computing the dynamic filter timeout, if a sufficient history of credentials
is available (i.e., the node stored \\( \CredentialHistorySize \\) past credential
arrival times), the array holding this history is _sorted_ in ascending order.

Then \\( \CredentialIdx \\)-th element is selected as the _filtering timeout_ value[^3].

Finally, a \\( \TimeoutGracePeriod \\) extra time is added to the selected entry,
for the final filter timeout to be returned as

$$
\Timeout = \CredentialHistory[\CredentialIdx] + \TimeoutGracePeriod
$$

Note that the filter timeout \\( \lambdaMin \leq \Timeout \leq \lambdaMax \\) is
clamped on the minimum and maximum bounds defined in the [ABFT normative section](./abft-parameters.md).

{{#include ../_include/styles.md:impl}}
> \\( \CredentialIdx \\)-th element selection [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/credentialArrivalHistory.go#L69).

## Parameters

|              NAME              | VALUE (seconds) | DESCRIPTION                                                                                                                                 |
|:------------------------------:|:---------------:|---------------------------------------------------------------------------------------------------------------------------------------------|
| \\( \CredentialHistorySize \\) |   \\( 40 \\)    | Size of the credential arrival time history circular array \\( \CredentialHistory \\).                                                      |
|     \\( \CredentialIdx \\)     |   \\( 37 \\)    | Entry of the (sorted) array \\( \CredentialHistory \\). Set to represent the 95th percentile (according to \\( \CredentialHistorySize \\)). |
|  \\( \TimeoutGracePeriod \\)   |  \\( 0.05 \\)   | Filter extra time, atop the one calculated from \\( \CredentialHistory \\).                                                                 |

---

[^1]: With current values for \\( \lambda  \\) and \\( \lambdaMin \\),
\\( \deltaL = 2 \\).

[^2]: A round is “successfully” completed if a _certification bundle_ is observed
and the proposal is already available, or if the proposal for an already present
_certification bundle_ is received.

[^3]: With the current parametrization, this corresponds to the 95th percentile of
the accumulated arrival times history.
