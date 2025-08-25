$$
\newcommand \Stake {\mathrm{Stake}}
\newcommand \Units {\mathrm{Units}}
\newcommand \floor [1]{\left \lfloor #1 \right \rfloor }
\newcommand \MinBalance {b_\min}
$$

# Reward State

The reward state consists of three 64-bit unsigned integers:

- The total amount of money distributed to each earning unit since the genesis state
\\( T_r \\),

- The amount of money to be distributed to each earning unit at the next round \\( R_r\\),

- The amount of money left over after distribution \\( B^\ast_r \\).

The reward state depends on:

- The address of the _incentive pool_ \\( I_\mathrm{pool} \\),

- The functions \\( \Stake(r, I_\mathrm{pool}) \\)

- \\( \Units(r) \\).

These are defined as part of the [Account State](./ledger-account-state.md).

Informally, every \\( \omega_r \\) rounds, the rate \\( R_r \\) is updated such
that rewards given over the next \\( \omega_r \\) rounds will drain the _incentive
pool_, leaving it with the minimum balance \\( \MinBalance \\).

The _rewards residue_ \\( B^\ast_r \\) is the amount of leftover rewards that should
have been given in the previous round but could not be evenly divided among all reward
units. The residue carries over into the rewards to be given in the next round.

The actual draining of the incentive pool account is described in the [Validity
and State Changes](./ledger-validation.md) section.

More formally, let \\( Z = \Units(r) \\).

Given a reward state \\( (T_r, R_r, B^\ast_r) \\), the new reward state is
\\( (T_{r+1}, R_{r+1}, B^\ast_{r+1}) \\), where:

- \\( R_{r+1} = \floor{\frac{\Stake(r, I_{pool}) - B^\ast_r - \MinBalance}{\omega_r}} \\)
if \\(R_r \equiv 0 \bmod \omega_r \\) or \\( R_{r+1} = R_r \\) otherwise, and

- \\( T_{r+1} = T_r + \floor{\frac{R_r}{Z}} \\) if \\( Z \neq 0 \\) or \\( T_{r+1} = T_r \\)
otherwise, and

- \\( B^\ast_{r+1} = (B^\ast_r + R_r) \bmod Z \\) if \\(Z \neq 0\\) or \\( B^\ast_{r+1} = B^\ast_r \\)
otherwise.

A valid block’s reward state matches the expected reward state.