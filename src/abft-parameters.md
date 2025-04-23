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

  - \\( \lambda_{0min} \leq \FilterTimeout(p) \leq 2\lambda_{0max} \\)

> Refer to the [non-normative](abft-overview.md#dynamic-filter-timeout) section
> for details about the implementation of the dynamic filtering mechanism.

- If \\( p \ne 0 \\):

  - \\( \FilterTimeout(p) = 4 \\) seconds (which coincides with \\( 2\lambda \\))

> This value is currently hardcoded in the reference implementation. However, it
> should be equal to \\(2\lambda\\).

We define \\( \DeadlineTimeout(p) \\) on _period_ \\( p \\) as follows:

- If \\( p = 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda_0 \\)

- If \\( p \ne 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda + \lambda \\)

## Values

| PARAMETER              | VALUE | UNIT    |
|------------------------|-------|---------|
| \\( \delta_s \\)       | 2     | rounds  |
| \\( \delta_r \\)       | 80    | rounds  |
| \\( \lambda \\)        | 2     | seconds |
| \\( \lambda_{0min} \\) | 2.5   | seconds |
| \\( \lambda_{0max} \\) | 1.75  | seconds |
| \\( \lambda_f \\)      | 300   | seconds |
| \\( \Lambda \\)        | 15    | seconds |
| \\( \Lambda_0 \\)      | 4     | seconds |
