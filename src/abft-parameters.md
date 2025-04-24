$$
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
$$

# Parameters

The Algorand protocol is parameterized by the following constants:

**TIME CONSTANTS**

These values represent durations of _time_.

| SYMBOL                 | DESCRIPTION                                                                                        |
|------------------------|----------------------------------------------------------------------------------------------------|
| \\( \lambda \\)        | Time for small message (e.g., a vote) propagation in ideal network conditions                      |
| \\( \lambda_{0min} \\) | Minimum amount of time for small message propagation in good network conditions, for \\( p = 0 \\) |
| \\( \lambda_{0max} \\) | Maximum amount of time for small message propagation in good network conditions, for \\( p = 0 \\) |
| \\( \lambda_f \\)      | Frequency at which the protocol _fast recovery_ steps are repeated                                 |
| \\( \Lambda \\)        | Time for big message (e.g., a block) propagation in ideal network conditions                       |
| \\( \Lambda_0 \\)      | Time for big message propagation in good network conditions, for \\(p = 0\\)                       |

**ROUNDS CONSTANTS**

These are positive integers that represent an amount of protocol _rounds_.

| SYMBOL           | DESCRIPTION                 |
|------------------|-----------------------------|
| \\( \delta_s \\) | The "seed lookback"         |
| \\( \delta_r \\) | The "seed refresh interval" |

For convenience, we define:

- \\( \delta_b = 2\delta_s\delta_r \\) (the "balance lookback").

## Timeouts

We define \\( \FilterTimeout(p) \\) on a _period_ \\( p \\) as follows:

- If \\( p = 0 \\) and a sufficient history of lowest credential arrival times is
available, the \\( \FilterTimeout(p) \\) is calculated dynamically based on the
lower 95th percentile of the observed lowest credentials per round arrival time:

  - \\( \lambda_{0min} \leq \FilterTimeout(p) \leq \lambda_{0max} \\)

> Refer to the [non-normative](abft-overview.md#dynamic-filter-timeout) section
> for details about the implementation of the dynamic filtering mechanism.

- If \\( p \ne 0 \\):

  - \\( \FilterTimeout(p) = 4 \\) seconds (which coincides with \\( 2\lambda \\)).

> This value is currently hardcoded in the reference implementation. However, it
> should be equal to \\(2\lambda\\).

We define \\( \DeadlineTimeout(p) \\) on _period_ \\( p \\) as follows:

- If \\( p = 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda_0 \\)

- If \\( p \ne 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda + \lambda \\)

> ⚙️ **IMPLEMENTATION**
>
> \\( \DeadlineTimeout \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/types.go#L67).

## Values

| PARAMETER                                                                                                                                                   | VALUE | UNIT    |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|-------|---------|
| [\\( \delta_s \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L969)                          | 2     | rounds  |
| [\\( \delta_r \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L983)                          | 80    | rounds  |
| [\\( \lambda \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L1616)                          | 2     | seconds |
| [\\( \lambda_{0min} \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/agreement/dynamicFilterTimeoutParams.go#L34) | 2.5   | seconds |
| [\\( \lambda_{0max} \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L1486)                   | 3     | seconds |
| [\\( \lambda_f \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L967)                         | 300   | seconds |
| [\\( \Lambda \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L1617)                          | 15    | seconds |
| [\\( \Lambda_0 \\)](https://github.com/algorand/go-algorand/blob/5c49e9a54dfea12c6cee561b8611d2027c401163/config/consensus.go#L1501)                        | 4     | seconds |
