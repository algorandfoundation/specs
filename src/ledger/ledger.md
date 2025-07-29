---
numbersections: true
title: "Algorand Ledger State Machine Specification"
date: \today
abstract: >
  Algorand replicates a state and the state's history between protocol
  participants.  This state and its history is called the _Algorand Ledger_.
---

# Overview

# Reward State

\newcommand \Stake {\mathrm{Stake}}
\newcommand \Units {\mathrm{RewardUnits}}

\newcommand \floor [1]{\left \lfloor #1 \right \rfloor }

The reward state consists of three 64-bit unsigned integers: the total amount
of money distributed to each earning unit since the genesis state $T_r$, the
amount of money to be distributed to each earning unit at the next round $R_r$,
and the amount of money left over after distribution $B^*_r$.

The reward state depends on the $I_{pool}$, the address of the _incentive pool_, and
the functions $\Stake(r, I_{pool})$ and $\Units(r)$.  These are defined as part of the
[Account State][Account State] below.

Informally, every $\omega_r$ rounds, the rate $R_r$ is updated such that rewards given over the next
$\omega_r$ rounds will drain the incentive pool, leaving it with the minimum balance $b_{min}$.
The _rewards residue_ $B^*_r$ is the amount of leftover rewards that should have been given in the previous round but
could not be evenly divided among all reward units. The residue carries over into the rewards to be given in the next round.
The actual draining of the incentive pool account is described in the [Validity and State Changes][Validity and State Changes] section further below.

More formally, let $Z = \Units(r)$. Given a reward state $(T_r, R_r, B^*_r)$, the new reward
state is $(T_{r+1}, R_{r+1}, B^*_{r+1})$ where

 - $R_{r+1} = \floor{\frac{\Stake(r, I_{pool}) - B^*_r - b_{min}}{\omega_r}}$ if
   $R_r \equiv 0 \bmod \omega_r$; $R_{r+1} = R_r$ otherwise,
 - $T_{r+1} = T_r + \floor{\frac{R_r}{Z}}$ if $Z \neq 0$; $T_{r+1} = T_r$
   otherwise, and
 - $B^*_{r+1} = (B^*_r + R_r) \bmod Z$ if $Z \neq 0$; $B^*_{r+1} = B^*_r$
   otherwise.

A valid block's reward state matches the expected reward state.

## Validity and State Changes

The new account state which results from applying a block is the account state
which results from applying each transaction in that block, in sequence. For a
block to be valid, each transaction in its transaction sequence must be valid at
the block's round $r$ and for the block's genesis identifier $\GenesisID_B$.

For a transaction
$$\Tx = (\GenesisID, \TxType, r_1, r_2, I, I', I_0, f, a, x, N, \pk, \sppk, \nonpart,
  \ldots)$$
(where $\ldots$ represents fields specific to transaction types
besides "pay" and "keyreg")
to be valid at the intermediate state $\rho$ in round $r$ for the genesis
identifier $\GenesisID_B$, the following conditions must all hold:

 - It must represent a transition between two valid account states.
 - Either $\GenesisID = \GenesisID_B$ or $\GenesisID$ is the empty string.
 - $\TxType$ is either "pay", "keyreg", "acfg", "axfer", "afrz",
   "appl", "stpf", or "hb".
 - There are no extra fields that do not correspond to $\TxType$.
 - $0 \leq r_2 - r_1 \leq T_{\max}$.
 - $r_1 \leq r \leq r_2$.
 - $|N| \leq N_{\max}$.
 - $I \neq I_{pool}$, $I \neq I_f$, and $I \neq 0$.
 - $\Stake(r+1, I) \geq f \geq f_{\min}$.
 - The transaction is properly authorized as described in the [Authorization and Signatures][Authorization and Signatures] section.
 - $\Hash(\Tx) \notin \TxTail_r$.
 - If $x \neq 0$, there exists no $\Tx' \in TxTail$ with sender $I'$, lease value
   $x'$, and last valid round $r_2'$ such that $I' = I$, $x' = x$, and
   $r_2' \geq r$.
 - If $\TxType$ is "pay",
    - $I \neq I_k$ or both $I' \neq I_{pool}$ and $I_0 \neq 0$.
    - $\Stake(r+1, I) - f > a$ if $I' \neq I$ and $I' \neq 0$.
    - If $I_0 \neq 0$, then $I_0 \neq I$.
    - If $I_0 \neq 0$, $I$ cannot hold any assets.
 - If $\TxType$ is "keyreg",
    - $p_{\rho, I} \ne 2$ (i.e., nonparticipatory accounts may not issue keyreg transactions)
    - If $\nonpart$ is true then $\spk = 0$ ,$\pk = 0$ and $\sppk = 0$

Given that a transaction is valid, it produces the following updated account
state for intermediate state $\rho+1$:

 - For $I$:
    - If $I_0 \neq 0$ then
      $a_{\rho+1, I} = a'_{\rho+1, I} = a^*_{\rho+1, I} = p_{\rho+1, I} = \pk_{\rho+1, I} = 0$;
    - otherwise,
        - $a_{\rho+1, I} = \Stake(\rho+1, I) - a - f$ if $I' \neq I$ and
		  $a_{\rho+1, I} = \Stake(\rho+1, I) - f$ otherwise.
        - $a'_{\rho+1, I} = T_{r+1}$.
        - $a^*_{\rho+1, I} = a^*_{\rho, I} +
                             (T_{r+1} - a'_{\rho, I}) \floor{\frac{a_{\rho, I}}{A}}$.
        - If $\TxType$ is "pay", then $\pk_{\rho+1, I} = \pk_{\rho, I}$ and $p_{\rho+1, I} = p_{\rho, I}$
        - Otherwise (i.e., if $\TxType$ is "keyreg"),
            - $\pk_{\rho+1, I} = \pk$
            - $p_{\rho+1, I} = 0$ if $\pk = 0$ and $\nonpart = \text{false}$
            - $p_{\rho+1, I} = 2$ if $\pk = 0$ and $\nonpart = \text{true}$
            - $p_{\rho+1, I} = 1$ if $\pk \ne 0$.
            - If $f > 2000000$, then $\ie{\rho+1, I} = true$

 - For $I'$ if $I \neq I'$ and either $I' \neq 0$ or $a \neq 0$:
    - $a_{\rho+1, I'} = \Stake(\rho+1, I') + a$.
    - $a'_{\rho+1, I'} = T_{r+1}$.
    - $a^*_{\rho+1, I'} = a^*_{\rho, I'} +
                         (T_{r+1} - a'_{\rho, I'}) \floor{\frac{a_{\rho, I'}}{A}}$.
 - For $I_0$ if $I_0 \neq 0$:
    - $a_{\rho+1, I_0} = \Stake(\rho+1, I_0) + \Stake(\rho+1, I) - a - f$.
    - $a'_{\rho+1, I_0} = T_{r+1}$.
    - $a^*_{\rho+1, I_0} = a^*_{\rho, I_0} +
                         (T_{r+1} - a'_{\rho, I_0}) \floor{\frac{a_{\rho, I_0}}{A}}$.
 - For all other $I^* \neq I$, the account state is identical to that in view $\rho$.

For transaction types other than "pay" and "keyreg", account state is
updated based on the reference logic described below.

Additionally, for all types of transactions, if the RekeyTo address of the transaction is nonzero and does not match the transaction sender address, then the transaction sender account's spending key is set to the RekeyTo address. If the RekeyTo address of the transaction does match the transaction sender address, then the transaction sender account's spending key is set to zero.

The final intermediate account $\rho_k$ state changes the balance of the
incentive pool as follows:
$$a_{\rho_k, I_{pool}} = a_{\rho_{k-1}, I_{pool}} - R_r(\Units(r))$$

An account state in the intermediate state $\rho+1$ and at round $r$ is valid if
all following conditions hold:

 - For all addresses $I \notin \{I_{pool}, I_f\}$, either $\Stake(\rho+1, I) = 0$ or
   $\Stake(\rho+1, I) \geq b_{\min} \times (1 + NA)$, where $NA$ is the number of
   assets held by that account.

 - $\sum_I \Stake(\rho+1, I) = \sum_I \Stake(\rho, I)$.

[sp-crypto-spec]: https://github.com/algorandfoundation/specs/blob/master/dev/crypto.md#state-proofs
[abft-spec]: https://github.com/algorand/spec/abft.md
[partkey-spec]: https://github.com/algorand/spec/partkey.md
