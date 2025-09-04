$$
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
$$

# Parameters

The Algorand protocol is parameterized by the following constants:

## Time Constants

These values represent durations of _time_.

|         SYMBOL         | VALUE (seconds) | DESCRIPTION                                                                                        |
|:----------------------:|:---------------:|:---------------------------------------------------------------------------------------------------|
|    \\( \lambda \\)     |  \\( 2.00 \\)   | Time for small message (e.g., a vote) propagation in ideal network conditions                      |
| \\( \lambda_{0min} \\) |  \\( 0.25 \\)   | Minimum amount of time for small message propagation in good network conditions, for \\( p = 0 \\) |
| \\( \lambda_{0max} \\) |  \\( 1.50 \\)   | Maximum amount of time for small message propagation in good network conditions, for \\( p = 0 \\) |
|   \\( \lambda_f \\)    | \\( 300.00 \\)  | Frequency at which the protocol _fast recovery_ steps are repeated                                 |
|    \\( \Lambda \\)     |  \\( 17.00 \\)  | Time for big message (e.g., a block) propagation in ideal network conditions                       |
|   \\( \Lambda_0 \\)    |  \\( 4.00 \\)   | Time for big message propagation in good network conditions, for \\(p = 0\\)                       |

## Round Constants

These are positive integers that represent an amount of protocol _rounds_.

|      SYMBOL      | VALUE (rounds) | DESCRIPTION                 |
|:----------------:|:--------------:|:----------------------------|
| \\( \delta_s \\) |   \\( 2 \\)    | The "seed lookback"         |
| \\( \delta_r \\) |   \\( 80 \\)   | The "seed refresh interval" |

For convenience, we define:

- \\( \delta_b = 2\delta_s\delta_r \\) (the "balance lookback").

## Timeouts

We define \\( \FilterTimeout(p) \\) on a _period_ \\( p \\) as follows:

- If \\( p = 0 \\) the \\( \FilterTimeout(p) \\) is calculated dynamically based on the
lower 95th percentile of the observed lowest credentials per round arrival time:

  - \\( 2\lambda_{0min} \leq \FilterTimeout(p) \leq 2\lambda_{0max} \\)

> Refer to the [non-normative](abft-overview.md#dynamic-filter-timeout) section
> for details about the implementation of the dynamic filtering mechanism.

- If \\( p \ne 0 \\):

  - \\( \FilterTimeout(p) = 2\lambda \\).

We define \\( \DeadlineTimeout(p) \\) on _period_ \\( p \\) as follows:

- If \\( p = 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda_0 \\)

- If \\( p \ne 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda \\)

{{#include ../_include/styles.md:impl}}
> \\( \DeadlineTimeout \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/types.go#L67).
