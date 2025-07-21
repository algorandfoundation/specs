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

Authorization and Signatures
----------------------------

Transactions are not valid unless they are somehow authorized by the sender account (for example, with a signature).
The authorization information is not considered part of the transaction and does not affect the TXID.
Rather, when serializing a transaction for submitting to a node or including in a block, the transaction and its authorization appear together in a struct called a SignedTxn.
The SignedTxn struct contains the transaction (in msgpack field `txn`), optionally an _authorizer address_ (field `sgnr`), and exactly one of a _signature_ (field `sig`), _multisignature_ (field `msig`), or _logic signature_ (field `lsig`).

The _authorizer address_, a 32 byte string, determines against what to verify the sig / msig / lsig, as described below. If the `sgnr` field is omitted (or zero), then the authorizer address defaults to the transaction sender address. At the time the transaction is applied to the ledger, the authorizer address must match the transaction sender account's spending key (or the sender address, if the account's spending key is zero) -- if it does not match, then the transaction was improperly authorized and is invalid.

 - A valid signature (`sig`) is a (64-byte) valid ed25519 signature of the transaction (encoded in canonical msgpack and with domain separation prefix "TX") where the public key is the authorizer address (interpreted as an ed25519 public key).

 - A valid multisignature (`msig`) is an object containing
   the following fields and which hashes to the authorizer address as described in the [Multisignature][Multisignature] section:

   - The _subsig_ array of subsignatures each consisting of a signer address and a 64-byte signature
     of the transaction. Note, multisignature transaction must contain
     all signer's addresses in the _subsig_ array even if the transaction has not
     been signed by that address.

   - The threshold _thr_ that is a minimum number of signatures required.

   - The multisignature version _v_ (current value is 1).

- A valid logic-signed transaction's signature is the _lsig_ object containing
  the following fields:

  - The logic _l_ which is versioned bytecode. (See [TEAL documentation](TEAL.md))

  - An optional single signature _sig_ of 64 bytes valid for the authorizer address of the transaction which has signed the bytes in _l_.

  - An optional multisignature _msig_ from the authorizer address over the bytes in _l_.

  - An optional array of byte strings _arg_ which are arguments supplied to the program in _l_. (_arg_ bytes are not covered by _sig_ or _msig_)

  The logic signature is valid if exactly one of _sig_ or _msig_ is a valid signature of the program by the authorizer address of the transaction, or if neither _sig_ nor _msig_ is set and the hash of the program is equal to the authorizer address. Also the program must execute and finish with a single non-zero value on the stack. See [TEAL documentation](TEAL.md) for details on program execution.

## ApplyData

\newcommand \ClosingAmount {\mathrm{ClosingAmount}}
\newcommand \AssetClosingAmount {\mathrm{AssetClosingAmount}}

Each transaction is associated with some information about how it is
applied to the account state.  This information is called ApplyData,
and contains the following fields:

- The closing amount, $\ClosingAmount$, which specifies how many microAlgos
  were transferred to the closing address, and is encoded as "ca" in
  msgpack.

- The asset closing amount, $\AssetClosingAmount$, which specifies how many
  of the asset units were transferred to the closing address.  It is
  encoded as "aca" in msgpack.

- The amount of rewards distributed to each of the accounts touched by this
  transaction.  There are three fields ("rs", "rr", and "rc" keys in msgpack
  encoding), representing the amount of rewards distributed to the sender,
  receiver, and closing addresses respectively.  The fields have integer
  values representing microAlgos.  If any of the accounts are the same
  (e.g., the sender and recipient are the same), then that account received
  the sum of the respective reward distributions (i.e., "rs" plus "rr");
  in the reference implementation, one of these two fields will be zero
  in that case.

- If this is an `ApplicationCall` transaction, the `EvalDelta` associated with
  the successful execution of the corresponding application's `ApprovalProgram`
  or `ClearStateProgram`. The `EvalDelta`, encoded as msgpack field `dt`,
  contains the following fields:
  - A `GlobalDelta`, encoding changes to the global state of the called
    application, encoded as msgpack field `gd`.
    - `gd` is a [`StateDelta`][State Deltas].
  - Zero or more `LocalDeltas`, encoding changes to some local states associated
    with the called application, encoded as msgpack field `ld`.
    - `ld` maps an "account offset" to a [`StateDelta`][State Deltas]. Account
      offset 0 is the transaction's sender. Account offsets 1 and greater refer
      to the account specified at that offset minus one in the transaction's
      `Accounts` slice. An account would have its `LocalDeltas` changes as long
      as there is at least a single change in that set.
  - Zero or more `Logs` encoded in an array `lg`, recording the arguments
    to each call of the `log` opcode in the called application. The order
    of the entries follows the execution order of the `log`
    invocations. The maximum total number of `log` calls is 32, and the
    total size of all logged bytes is limited to 1024. No Logs are
    included if a Clear state program fails.
  - Zero or more `InnerTxns`, encoded in an array `itx`. Each element
    of `itx` records a successful inner transaction. Each element will
    contain the transaction fields, encoded under `txn`, in the same
    way that the top-level transaction is encoded, recursively,
    including `ApplyData` that applies to the inner transaction.
    - The recursive depth of inner transactions is limited 8.
    - Up to 16 `InnerTxns` may be present in version 5. In version 6,
    the count of all inner transactions across the transaction group
    must not exceed 256.
    - InnerTxns are limited to `pay`, `axfer`, `acfg`, and `afrz`
      transactions in programs before version 6. Version 6 also
      allows `keyreg` and `appl`.
    - A `ClearStateProgram` execution may not have any InnerTxns.

### State Deltas

A state delta represents an update to a [Key/Value Store
(KV)][Key/Value Stores]. It is represented as an associative array
mapping a byte-array key to a single value delta. It represents a
series of actions that when applied to the previous state of the
key/value store will yield the new state.

A value delta is composed of three fields:

- `Action`, encoded as msgpack field `at`, which specifies how the value for
  this key has changed. It has three possible values:
  - `SetUintAction` (value = `1`), indicating that the value for this key should
    be set to the value delta's `Uint` field.
  - `SetBytesAction` (value = `2`), indicating that the value for this key
    should be set to the value delta's `Bytes` field.
  - `DeleteAction` (value = `3`), indicating that the value for this key should
    be deleted.
- `Bytes`, encoded as msgpack field `bs`, which specifies a byte slice value to
  set.
- `Uint`, encoded as msgpack field `ui`, which specifies a 64-bit unsigned
  integer value to set.

## Transaction Sequences, Sets, and Tails

Each block contains a _transaction sequence_, an ordered sequence of
transactions in that block.  The transaction sequence of block $r$ is denoted
$\TxSeq_r$.  Each valid block contains a _transaction commitment_ $\TxCommit_r$
which is a Merkle tree commitment to this sequence.  The leaves in the Merkle
tree are hashed as $$\Hash("TL", txid, stibhash)$$.  The txid value is the
32-byte transaction identifier.  The stibhash value is a 32-byte hash of the
signed transaction and ApplyData for the transaction, hashed with the
domain-separation prefix `STIB`, and encoded as follows:

- Transactions in a block are encoded in a slightly different way than
  standalone transactions, for efficiency:

  If a transaction contains a $\GenesisID$ value, then (1) it must
  match the block's $\GenesisID$, (2) the transaction's $\GenesisID$
  value must be omitted from the transaction's msgpack encoding in the
  block, and (3) the transaction's msgpack encoding in the block must
  indicate the $\GenesisID$ value was omitted by including a key "hgi"
  with the boolean value true.

  Since transactions must include a $\GenesisHash$ value, the
  $\GenesisHash$ value of each transaction in a block must match the
  block's $\GenesisHash$, and the $\GenesisHash$ value is omitted from
  the transaction as encoded in a block.

- Transactions in a block are also augmented with the ApplyData that reflect
  how that transaction applied to the account state.

The transaction commitment for a block covers the transaction encodings
with the changes described above.  Individual transaction signatures
cover the original encoding of transactions as standalone.

In addition to _transaction commitment_, each block will also contain _SHA256 transaction commitment_.
It can allow a verifier which does not support SHA512_256 function to verify proof of membership on transaction.
In order to construct this commitment we use Vector Commitment. The leaves in the Vector Commitment
tree are hashed as $$SHA256("TL", txidSha256, stibSha256)$$.  Where:

- txidSha256 = SHA256(`TX` || transcation)
- stibSha256 = SHA256(`STIB` || signed transaction || ApplyData)

The vector commitment uses SHA256 for internal nodes as well.

A valid transaction sequence contains no duplicates: each transaction in the
transaction sequence appears exactly once.  We can call the set of these
transactions the _transaction set_.  (For convenience, we may also write
$\TxSeq_r$ to refer unambiguously to this set.)  For a block to be valid, its
transaction sequence must be valid (i.e., no duplicate transactions may appear
there).

All transactions have a _size_ in bytes.  The size of the transaction $\Tx$ is
denoted $|\Tx|$.  For a block to be valid, the sum of the sizes of each
transaction in a transaction sequence must be at most $B_{\max}$; in other words,
$$\sum_{\Tx \in \TxSeq_r} |\Tx| \leq B_{\max}.$$

The transaction tail for a given round $r$ is a set produced from the union of
the transaction identifiers of each transaction in the last $T_{\max}$
transaction sets and is used to detect duplicate transactions.  In other words,
$$\TxTail_r = \bigcup_{r-T_{\max} \leq s \leq r-1}
              \{\Hash(\Tx) | \Tx \in \TxSeq_s\}.$$
As a result, the transaction tail for round $r+1$ is computed as follows:
$$\TxTail_{r+1} = \TxTail_r \setminus
                  \{\Hash(\Tx) | \Tx \in \TxSeq_{r-T_{\max}}\} \cup
				  \{\Hash(\Tx) | \Tx \in \TxSeq_r\}.$$
The transaction tail is part of the ledger state but is distinct from the
account state and is not committed to in the block.

## Asset Transaction Semantics

An asset configuration transaction has the following semantics:

 - If the asset ID is zero, create a new asset with an ID corresponding to
   one plus this transaction's unique counter value.  The transaction's
   counter value is the transaction counter field from the block header
   plus the positional index of this transaction in the block (starting
   from 0).

   On asset creation, the asset parameters for the created asset are
   stored in the creator's account under the newly allocated asset ID.
   The creating account also allocates space to hold asset units of the
   newly allocated asset.  All units of the newly created asset (i.e.,
   the total specified in the parameters) are held by the creator. When
   the creator holding is initialized it ignores the default freeze flag
   and is always initialized to unfrozen.

 - If the asset ID is non-zero, the transaction must be issued by the
   manager of the asset (based on the asset's current parameters).  A
   zero manager address means no such transaction can be issued.

   If the parameters are omitted (the zero value), the asset is destroyed.
   This is allowed only if the creator holds all of the units of that asset
   (i.e., equal to the total in the parameters).

   If the parameters are not omitted, any non-zero key in the asset's
   current parameters (as stored in the asset creator's account) is
   updated to the key specified in the asset parameters.  This applies to
   the manager, reserve, freeze, and clawback keys.  Once a key is set to
   zero, it cannot be updated.  Other parameters are immutable.

An asset transfer transaction has the following semantics:

 - If the asset source field is non-zero, the transaction must be issued
   by the asset's clawback account, and this transaction can neither
   allocate nor close out holdings of an asset (i.e., the asset close-to
   field must not be specified, and the source account must already have
   allocated space to store holdings of the asset in question).  In this
   clawback case, freezes are bypassed on both the source and destination
   of this transfer.

   If the asset source field is zero, the asset source is assumed to be the
   transaction's sender, and freezes are not bypassed.

 - If the transfer amount is 0, the transaction allocates space in the
   sender's account to store the asset ID.  The holdings are initialized
   with a zero number of units of that asset, and the default freeze flag
   from the asset's parameters.  Space cannot be allocated for asset IDs
   that have never been created, or that have been destroyed, at the time
   of space allocation.  Space can remain allocated, however, after the
   asset is destroyed.

 - The transaction moves the specified number of units of the asset from
   the source to the destination.  If either account is frozen, and
   freezes are not bypassed, the transaction fails to execute.  If either
   account does not have any space allocated to hold units of this asset,
   the transaction fails to execute.  If the source account has fewer
   than the specified number of units of that asset, the transaction
   fails to execute.

 - If the asset close-to field is specified, the transaction transfers
   all remaining units of the asset to the close-to address.  If the
   close-to address is not the creator address, then neither the sender
   account's holdings of this asset nor the close-to address's holdings
   can be frozen; otherwise, the transaction fails to execute.  Closing to
   the asset creator is always allowed, even if the source and/or creator
   account's holdings are frozen.  If the sender or close-to address does
   not have allocated space for the asset in question, the transaction
   fails to execute.  After transferring all outstanding units of the
   asset, space for the asset is deallocated from the sender account.

An asset freeze transaction has the following semantics:

 - If the transaction is not issued by the freeze address in the specified
   asset's parameters, the transaction fails to execute.

 - If the specified asset does not exist in the specified account, the
   transaction fails to execute.

 - The freeze flag of the specified asset in the specified account is updated
   to the flag value from the freeze transaction.

When an asset transaction allocates space in an account for an asset,
whether by creation or opt-in, the sender's minimum balance
requirement is incremented by 100,000 microAlgos.  When the space is
deallocated, whether by asset destruction or asset-close-to, the balance
requirement of the sender is decremented by 100,000 microAlgos.

## ApplicationCall Transaction Semantics

When an `ApplicationCall` transaction is evaluated by the network, it is
processed according to the following procedure. None of the effects of the
transaction are made visible to other transactions until the points marked
**SUCCEED** below. **FAIL** indicates that any modifications to state up to that
point must be discarded and the entire transaction rejected.

### Procedure

1.
    - If the application ID specified by the transaction is zero, create a new
      application with ID equal to one plus the system transaction counter (this
      is the same ID selection algorithm as used by Assets).

        When creating an application, the application parameters specified by
        the transaction (`ApprovalProgram`, `ClearStateProgram`,
        `GlobalStateSchema`, `LocalStateSchema`, and `ExtraProgramPages`) are allocated into the
        sender’s account data, keyed by the new application ID.

        Continue to step 2.

    - If the application ID specified by the transaction is nonzero, continue to
      step 2.
2.
    - If `OnCompletion == ClearState`, then:
        - Check if the transaction’s sender is opted in to this application ID.
          If not, **FAIL.**
        - Check if the application parameters still exist in the creator's
          account data.
            - If the application does not exist, delete the sender’s local state
              for this application (marking them as no longer opted in), and
              **SUCCEED.**
            - If the application does exist, continue to step 3.
    - If the `OnCompletion != ClearState`, continue to step 4.
3.
    - Execute the `ClearStateProgram`.
        - If the program execution returns `PASS == true`, apply the
          local/global/box key/value store deltas generated by the program’s
          execution.
        - If the program execution returns `PASS == false`, do not apply any
          local/global/box key/value store deltas generated by the program’s
          execution.
    - Delete the sender’s local state for this application (marking them as no
      longer opted in). **SUCCEED.**
4.
    - If `OnCompletion == OptIn`, then at this point during execution we will
      allocate a local key/value store for the sender for this application
      ID, marking the sender as opted in.

        Continue to step 5.
5.
    - Execute the `ApprovalProgram`.
        - If the program execution returns `PASS == true`, apply any
          local/global key/value store deltas generated by the program’s
          execution. Continue to step 6.
        - If the program execution returns `PASS == false`, **FAIL.**
6.
    - If `OnCompletion == NoOp`
        - **SUCCEED.**
    - If `OnCompletion == OptIn`
        - This was handled above. **SUCCEED.**
    - If `OnCompletion == CloseOut`
        - Check if the transaction’s sender is opted in to this application ID.
          If not, **FAIL.**
        - Delete the sender’s local state for this application (marking them as
          no longer opted in). **SUCCEED.**
    - If `OnCompletion == ClearState`
        - This was handled above (unreachable).
    - If `OnCompletion == DeleteApplication`
        - Delete the application’s parameters from the creator’s account data.
          (Note: this does not affect any local state). **SUCCEED.**
    - If `OnCompletion == UpdateApplication`
        - If an existing program is version 4 or higher, and the
          supplied program is a downgrade from the existing version
          **FAIL**
        - Update the Approval and ClearState programs for this
          application according to the programs specified in this
          `ApplicationCall` transaction. The new programs are not executed in
          this transaction.  **SUCCEED.**

### Application Stateful Execution Semantics

- Before the execution of the first ApplicationCall transaction in a
  group, the combined size of all boxes referred to in the box references
  of all transactions in the group must be less than the I/O budget, i.e., 1,024 times the
  total number of box references in the group, or else the group
  fails.
- During the execution of an `ApprovalProgram` or `ClearStateProgram`,
  the application’s `LocalStateSchema` and `GlobalStateSchema` may
  never be violated. The program's execution will fail on the first
  instruction that would cause the relevant schema to be
  violated. Writing a `Bytes` value to a local or global [Key/Value
  Store][Key/Value Stores] such that the sum of the lengths of the key
  and value in bytes exceeds 128, or writing any value to a key longer
  than 64 bytes, will likewise cause the program to fail on the
  offending instruction.
- During the execution of an `ApprovalProgram`, the total size of all
  boxes that are created or modified in the group must not exceed the
  I/O budget or else the group fails.  The program's execution will
  fail on the first instruction that would cause the constraint to be
  violated. If a box is deleted after creation or modification, its
  size is not considered in this sum.
- Global state may only be read for the application ID whose program
  is executing, or for an _available_ application ID. An attempt to
  read global state for another application that is not _available_
  will cause the program execution to fail.
- Asset parameters may only be read for assets whose ID is
  _available_. An attempt to read asset parameters for an asset that
  is not _available_ will cause the program execution to fail.
- Local state may be read for any _available_ application. An attempt
  to read local state from any other account will cause program
  execution to fail. Further, in programs version 4 or later, Local
  state reads are restricted by application ID in the same way as
  Global state reads.
- Algo balances and asset balances may be read for the sender's
  account or for any _available_ account. An attempt to read a balance
  for any other account will cause program execution to fail.
  Further, in programs version 4 or later, asset balances may only be
  read for assets whose parameters are also _available_.
- Only _available_ boxes may be accessed. An attempt to access any other box
  will cause the program exection to fail.
- Boxes may not be accessed by an app's `ClearStateProgram`.

## Heartbeat Transaction Semantics

 If a heartbeat transaction's $grp$ is empty, and $f < f_{min}$, the
 transaction fails to execute unless:

   - The _note_ $N$ is empty
   - The _lease_ $x$ is empty
   - The _rekey to address_ $\RekeyTo$ is empty
   - The _heartbeat_address_, $a$, is $online$
   - The _heartbeat_address_, $a$, $\ie$ flag is true
   - The _heartbeat_address_, $a$, is _at risk_ of suspension

 An account is _at risk_ of suspension if the current round is between
 100-200 modulo 1000, and the blockseed of the most recent round that
 is 0 modulo 1000 matches $a$ in the first 5 bits.

 If successful, the `LastHeartbeat` of the specified heartbeat address
 $a$ is updated to the current round.


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

# Multisignature

Multisignature term describes a special multisignature address, signing and
validation procedures. In contrast with a regular account address
that may be understood as a public key, multisignature address is a hash of
a constant string identifier for multisignature, version, threshold, and
all addresses used for multisignature address creation:
$$MSig = \Hash("MultisigAddr", version, threshold, \pk_1, ..., \pk_s)$$
One address might be specified multiple times in multisignature address creation.
In this case every occurrence is counted independently in validation.

Validation process checks all non-empty signatures are valid and their count
not less than the threshold. Validation fails if any of signatures is invalid
even if count of all remaining correct signatures is greater or equals than the threshold.


[sp-crypto-spec]: https://github.com/algorandfoundation/specs/blob/master/dev/crypto.md#state-proofs
[abft-spec]: https://github.com/algorand/spec/abft.md
[partkey-spec]: https://github.com/algorand/spec/partkey.md
