$$
\newcommand \FilterTimeout {\mathrm{FilterTimeout}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
$$

# Parameters

The Algorand protocol is parameterized by the constants described in this section.

For agreement round \\( r \\), the player **SHALL** use the consensus parameters
recorded in the Ledger at round \\( \max(r - 2, 0) \\).

## Time Constants

These values represent durations of _time_.

|         SYMBOL         |   VALUE (s)    | DESCRIPTION                                                                   |
|:----------------------:|:--------------:|:------------------------------------------------------------------------------|
|    \\( \lambda \\)     |  \\( 2.00 \\)  | Time for small message (e.g., a vote) propagation in ideal network conditions |
| \\( \lambda_{0min} \\) |  \\( 2.50 \\)  | Minimum filtering time, for \\( p = 0 \\)                                     |
| \\( \lambda_{0max} \\) |  \\( 3.00 \\)  | Maximum filtering time, for \\( p = 0 \\)                                     |
|   \\( \lambda_f \\)    | \\( 300.00 \\) | Frequency at which the protocol _fast recovery_ steps are repeated            |
|    \\( \Lambda \\)     | \\( 15.00 \\)  | Time for big message (e.g., a block) propagation in ideal network conditions  |
|   \\( \Lambda_0 \\)    |  \\( 4.00 \\)  | Propagation deadline, for \\( p = 0 \\)                                       |

## Round Constants

These are positive integers that represent an amount of protocol _rounds_.

|      SYMBOL      | VALUE (rounds) | DESCRIPTION                 |
|:----------------:|:--------------:|:----------------------------|
| \\( \delta_s \\) |   \\( 2 \\)    | The "seed lookback"         |
| \\( \delta_r \\) |   \\( 80 \\)   | The "seed refresh interval" |

For convenience, we define:

- \\( \delta_b = 2\delta_s\delta_r \\) (the "balance lookback").

Every round lookback \\( r - \delta \\) refers to round \\( \max(r - \delta, 0) \\).

## Timeouts

We define \\( \FilterTimeout(p) \\) on a _period_ \\( p \\) as follows:

- If \\( p = 0 \\):

  - \\( \lambda_{0min} \leq \FilterTimeout(p) \leq \lambda_{0max} \\).

- If \\( p \ne 0 \\):

  - \\( \FilterTimeout(p) = 2\lambda \\).

> [!NOTE]
> In the reference implementation \\( \FilterTimeout(0) \\) is calculated dynamically
> based on the lower 95th percentile of the observed lowest credentials per round arrival
> time. Players may choose different values of \\( \FilterTimeout(0) \\) within its
> range. Agreement safety does not require equal values. An adaptive strategy is
> described in the [non-normative section](./non-normative/abft-nn-dynamic-filter-timeout.md).

We define \\( \DeadlineTimeout(p) \\) on _period_ \\( p \\) as follows:

- If \\( p = 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda_0 \\)

- If \\( p \ne 0 \\):

  - \\( \DeadlineTimeout(p) = \Lambda + \lambda \\)

> [!IMPORTANT]
> **IMPLEMENTATION:**
>
> \\( \DeadlineTimeout \\) [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/types.go#L67).
