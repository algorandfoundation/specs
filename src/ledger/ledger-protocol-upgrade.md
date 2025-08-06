$$
\newcommand \MaxVersionStringLen {V_\max}
\newcommand \DefaultUpgradeWaitRounds {\delta_x}
\newcommand \MaxUpgradeWaitRounds {\delta_{x_{\max}}}
\newcommand \MinUpgradeWaitRounds {\delta_{x_{\min}}}
\newcommand \UpgradeThreshold {\tau}
\newcommand \UpgradeVoteRounds {\delta_d}
$$

# Protocol Upgrade State

A protocol version \\( v \\) is a string no more than \\( \MaxVersionStringLen \\)
bytes long. It corresponds to parameters used to execute some version of the Algorand
protocol.

The upgrade vote in each block consists of:

- A protocol version \\( v_r \\);
- A 64-bit unsigned integer \\( x_r \\) which indicates the delay between the acceptance
of a protocol version and its execution;
- A single bit \\( b \\) indicating whether the block proposer supports the given
version.

The upgrade state in each block/state consists of:

- The _current_ protocol version \\( v_r^{\ast} \\);
- The _next proposed_ protocol version \\( v_r^{\prime} \\);
- A 64-bit round number \\( s_r \\) counting the number of votes for the next protocol
version;
- A 64-bit round number \\( d_r \\) specifying the deadline for voting on the next
protocol version;
- A 64-bit round number \\( x_r^{\prime} \\) specifying when the next proposed protocol
version would take effect, if passed.

An upgrade vote \\( (v_r, x_r, b) \\) is _valid_ given the upgrade state
\\( (v_r^{\ast}, v_r^{\prime}, s_r, d_r, x_r^{\prime}) \\) if \\( v_r \\) is the _empty_ string
or \\( v_r^{\prime} \\) is the _empty_ string, \\( \MinUpgradeWaitRounds \leq x_r \leq \MaxUpgradeWaitRounds \\), and either:

- \\( b = 0 \\) or
- \\( b = 1 \\) with \\( r < d_r \\) and either
  - \\( v_r^{\prime} \\) is not the empty string or
  - \\( v_r \\) is not the empty string.

If the vote is valid, then the new upgrade state is

$$
(v_{r+1}^{\ast}, v_{r+1}^{\prime}, s_{r+1}, d_{r+1}, x_{r+1})
$$

Where

- \\( v_{r+1}^{\ast} \\) is \\( v_r^{\prime} \\) if \\( r = x_r^{\prime} \\) and \\( v_r^{\ast} \\)
otherwise.
- \\( v^{\prime}_{r+1} \\) is
  - the empty string if \\( r = x_r^{\prime} \\) or both \\( r = s_r \\) and
  \\( s_r + b < \UpgradeThreshold \\),
  - \\( v_r \\) if \\( v_r^{\prime} \\) is the empty string, and
  - \\( v_r^{\prime} \\) otherwise.

- \\( s_{r+1} \\) is
  - \\( 0 \\) if \\( r = x_r^{\prime} \\) or both \\( r = s_r \\) and  \\( s_r + b < \UpgradeThreshold \\), and
  - \\( s_r + b \\) otherwise

- \\( d_{r+1} \\) is
  - \\( 0 \\) if \\( r = x_r^{\prime} \\) or both \\( r = s_r \\) and \\( s_r + b < \UpgradeThreshold \\),
  - \\( r + \UpgradeVoteRounds \\) if \\( v_r^{\prime} \\) is the empty string and
  \\( v_r \\) is not the empty string, and
  - \\( d_r \\) otherwise.

- \\( x_{r+1} \\) is
  - \\( 0 \\) if \\( r = x_r^{\prime} \\) or both \\( r = s_r \\) and \\( s_r + b < \UpgradeThreshold \\),
  - \\( r + \UpgradeVoteRounds + \delta \\) if \\( v_r^{\prime} \\) is the empty string and \\( v_r \\) is not
  the empty string (where \\( \delta = \DefaultUpgradeWaitRounds \\) if \\( x_r = 0 \\)
  and \\( \delta = x_r \\) if \\( x_r \neq 0 \\)), and
  - \\( x_r^{\prime} \\) otherwise.