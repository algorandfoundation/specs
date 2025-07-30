$$
\newcommand \Genesis {\mathrm{Genesis}}
\newcommand \GenesisID {\Genesis\mathrm{ID}}
\newcommand \pk {\mathrm{pk}}
\newcommand \spk {\mathrm{spk}}
\newcommand \Tx {\mathrm{Tx}}
\newcommand \TxType {\mathrm{TxType}}
\newcommand \TxTail {\Tx\mathrm{Tail}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \FirstValidRound {r_\mathrm{fv}}
\newcommand \LastValidRound {r_\mathrm{lv}}
\newcommand \sppk {\mathrm{sppk}}
\newcommand \nonpart {\mathrm{nonpart}}
\newcommand \MaxTxTail {\mathrm{TxTail}_\max}
\newcommand \abs[1] {\lvert #1 \rvert}
\newcommand \floor[1] {\left \lfloor #1 \right \rfloor }
$$

$$
\newcommand \MaxTxnNoteBytes {T_{m,\max}}
\newcommand \Stake {\mathrm{Stake}}
\newcommand \Fee {\mathrm{fee}}
\newcommand \MinTxnFee {T_{\Fee,\min}}
\newcommand \PayoutsGoOnlineFee {B_{p,\Fee}}
\newcommand \Eligibility {\mathrm{A_e}}
\newcommand \Units {\mathrm{Units}}
$$

# Validity and State Changes

The new Ledger’s state that results from applying a valid block is the account state
that results from applying each transaction in that block, in sequence.

For a block to be valid, each transaction in its transaction sequence **MUST** be
valid at the block’s round \\( r \\) and for the block’s genesis identifier \\( \GenesisID_B \\).

For a transaction

$$
\Tx = (\GenesisID, \TxType, \FirstValidRound, \LastValidRound, I, I^\prime, I_0, f, a, x, N, \pk, \sppk, \nonpart, \ldots)
$$

(where \\( \ldots \\) represents fields specific to [_transaction types_](./ledger-transactions.md#transaction-type)
besides `pay`and `keyreg`) to be valid at the intermediate state \\( \rho \\) in
round \\( r \\) for the genesis identifier \\( \GenesisID_B \\), the following conditions
**MUST** all hold:

- It **MUST** represent a transition between two valid account states.

- Either \\( \GenesisID = \GenesisID_B \\) or \\( \GenesisID \\) is the empty string.

- \\( \TxType \\) is either `pay`, `keyreg`, `acfg`, `axfer`, `afrz`, `appl`, `stpf`,
or `hb`.

- There are no extra fields that do not correspond to \\( \TxType \\).

- \\( 0 \leq \LastValidRound - \FirstValidRound \leq \MaxTxTail \\).

- \\( \FirstValidRound \leq r \leq \LastValidRound \\).

- \\( \abs{N} \leq \MaxTxnNoteBytes \\).

- \\( I \neq I_\mathrm{pool} \\), \\( I \neq I_f \\), and \\( I \neq 0 \\).

- \\( \Stake(r+1, I) \geq f \geq \MinTxnFee \\).

- The transaction is properly authorized as described in the [Authorization and
Signatures](./ledger-txn-authorization.md) section.

- \\( \Hash(\Tx) \notin \TxTail_r \\).

- If \\( x \neq 0 \\), there exists no \\( \Tx^\prime \in \TxTail \\) with sender
\\( I^\prime \\), lease value \\( x^\prime \\), and last valid round \\( \LastValidRound^\prime \\)
such that \\( I^\prime = I \\), \\( x^\prime = x \\), and \\( \LastValidRound^\prime \geq r \\).

- If \\( \TxType \\) is `pay`,

  - \\( I \neq I_k \\) or both \\( I^\prime \neq I_\mathrm{pool} \\) and
  \\( I_0 \neq 0 \\).

  - \\( \Stake(r+1, I) - f > a \\) if \\( I^\prime \neq I \\) and \\( I^\prime \neq 0 \\).

  - If \\( I_0 \neq 0 \\), then \\( I_0 \neq I \\).

  - If \\( I_0 \neq 0 \\), \\( I \\) cannot hold any assets.

- If \\( \TxType \\) is `keyreg`,

  - \\( p_{\rho, I} \ne 2 \\) (i.e., nonparticipatory accounts may not issue `keyreg`
  transactions)

  - If \\( \nonpart \\) is `True` then \\( \spk = 0 \\), \\( \pk = 0 \\) and
  \\( \sppk = 0 \\)

Given that a transaction is valid, it produces the following updated account state
for intermediate state \\( \rho+1 \\):

- For \\( I \\):

  - If \\( I_0 \neq 0 \\) then \\( a_{\rho+1, I} = a^\prime_{\rho+1, I} = a^\ast_{\rho+1, I} = p_{\rho+1, I} = \pk_{\rho+1, I} = 0 \\);

  - otherwise,
      - \\( a_{\rho+1, I} = \Stake(\rho+1, I) - a - f \\) if \\( I^\prime \neq I \\)
        and \\( a_{\rho+1, I} = \Stake(\rho+1, I) - f \\) otherwise.
      - \\( a^\prime_{\rho+1, I} = T_{r+1} \\).
      - \\( a^\ast_{\rho+1, I} = a^\ast_{\rho, I} + (T_{r+1} - a^\prime_{\rho, I}) \floor{\frac{a_{\rho, I}}{A}} \\).
      - If \\( \TxType \\) is `pay`, then \\( \pk_{\rho+1, I} = \pk_{\rho, I} \\) and \\( p_{\rho+1, I} = p_{\rho, I} \\)
      - Otherwise (i.e., if \\( \TxType \\) is `keyreg`),
          - \\( \pk_{\rho+1, I} = \pk \\)
          - \\( p_{\rho+1, I} = 0 \\) if \\( \pk = 0 \\) and \\( \nonpart = \texttt{False} \\)
          - \\( p_{\rho+1, I} = 2 \\) if \\( \pk = 0 \\) and \\( \nonpart = \texttt{True} \\)
          - \\( p_{\rho+1, I} = 1 \\) if \\( \pk \ne 0 \\)
          - If \\( f > \PayoutsGoOnlineFee \\), then \\( \Eligibility{\rho+1, I} = \texttt{True} \\)

- For \\( I^\prime \\) if \\( I \neq I^\prime \\) and either \\( I^\prime \neq 0 \\)
or \\( a \neq 0 \\):

  - \\( a_{\rho+1, I^\prime} = \Stake(\rho+1, I^\prime) + a \\).

  - \\( a^\prime_{\rho+1, I^\prime} = T_{r+1} \\).

  - \\( a^\ast_{\rho+1, I^\prime} = a^\ast_{\rho, I^\prime} + (T_{r+1} - a^\prime_{\rho, I^\prime}) \floor{\frac{a_{\rho, I^\prime}}{A}} \\).

- For \\( I_0 \\) if \\( I_0 \neq 0 \\):

  - \\( a_{\rho+1, I_0} = \Stake(\rho+1, I_0) + \Stake(\rho+1, I) - a - f \\).

  - \\( a^\prime_{\rho+1, I_0} = T_{r+1} \\).

  - \\( a^\ast_{\rho+1, I_0} = a^\ast_{\rho, I_0} + (T_{r+1} - a^\prime_{\rho, I_0}) \floor{\frac{a_{\rho, I_0}}{A}} \\).

- For all other \\( I^\ast \neq I \\), the account state is identical to that in view \\( \rho \\).

For transaction types other than `pay` and `keyreg`, account state is updated based
on the reference logic described in the [Transaction section]().

Additionally, for all types of transactions, if the [_rekey to_](./ledger-transactions.md#rekey-to)
address of the transaction is nonzero and does not match the transaction sender address,
then the transaction sender account’s spending key is set to the _rekey to_ address.
If the _rekey to_ address of the transaction does match the transaction sender address,
then the transaction sender account’s spending key is set to zero.

> The rest of this section describes the legacy Distribution Rewards system. If
> the \\( R_r \\) rewards rate parameter is \\( 0 \\), all computations keep values
> constant and no legacy reward distribution is carried out.

The final intermediate account \\( \rho_k \\) state changes the balance of the incentive
pool as follows:

$$
a_{\rho_k, I_\mathrm{pool}} = a_{\rho_{k-1}, I_\mathrm{pool}} - R_r(\Units(r))
$$

An account state in the intermediate state \\( \rho+1 \\) and at round \\( r \\)
is valid if all following conditions hold:

- For all addresses \\( I \notin \\{I_\mathrm{pool}, I_f\\} \\), either \\( \Stake(\rho+1, I) = 0 \\)
or \\( \Stake(\rho+1, I) \geq b_\min \times (1 + N_A) \\), where \\( N_A \\) is the
number of assets held by that account.

- \\( \sum_I \Stake(\rho+1, I) = \sum_I \Stake(\rho, I) \\).
