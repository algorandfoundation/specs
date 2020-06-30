---
numbersections: true
title: "Algorand Ledger State Machine Specification"
date: \today
abstract: >
  Algorand replicates a state and the state's history between protocol
  participants.  This state and its history is called the _Algorand Ledger_.
---

Overview
========

Parameters
----------

The Algorand Ledger is parameterized by the following values:

 - $t_{\delta}$, the maximum difference between successive timestamps.
 - $T_{\max}$, the length of the _transaction tail_.
 - $B_{\max}$, the maximum number of transaction bytes in a block.
 - $b_{\min}$, the minimum balance for any address.
 - $f_{\min}$, the minimum processing fee for any transaction.
 - $V_{\max}$, the maximum length of protocol version strings.
 - $N_{\max}$, the maximum length of a transaction note string.
 - $G_{\max}$, the maximum number of transactions allowed in a transaction group.
 - $\tau$, the number of votes needed to execute a protocol upgrade.
 - $\delta_d$, the number of rounds over with an upgrade proposal is open.
   Currently defined as 10,000.
 - $\delta_{x_{\min}}$ and $\delta_{x_{\max}}$, the minimum and maximum number
   of rounds needed to prepare for an upgrade.  Currently respectively defined
   as 10,000 and 150,000.
 - $\delta_x$, the default number of rounds needed to prepare for an upgrade.
   Currently defined as 140,000.
 - $\omega_r$, the rate at which the reward rate is refreshed.
 - $A$, the size of an earning unit.
 - $Assets_{\max}$, the maximum number of assets held by an account.


States
------

A _ledger_ is a sequence of states which comprise the common information
established by some instantiation of the Algorand protocol.  A ledger is
identified by a string called the _genesis identifier_, as well as a
_genesis hash_ that cryptographically commits to the starting state of
the ledger. Each state consists of the following components:

 - The _round_ of the state, which indexes into the ledger's sequence of
   states.

 - The _genesis identifier_ and _genesis hash_, which identify the ledger
   to which the state belongs.

 - The current _protocol version_ and the _upgrade state_.

 - A _timestamp_, which is informational and identifies when the state was first
   proposed.

 - A _seed_, which is a source of randomness used to [establish consensus on the
   next state][abft-spec].

 - The current _reward state_, which describes the policy at which incentives
   are distributed to participants.

 - The current _account state_, which holds account balances and keys for all
   stakeholding addresses.
   - One component of this state is the _transaction tail_, which caches the
	 _transaction sets_ (see below) in the last $T_{\max}$ blocks.


Blocks
------

A _block_ is a data structure which specifies the transition between states.
The data in a block is divided between the _block header_ and its _block body_.
The block header contains the following components:

 - The block's _round_, which matches the round of the state it is transitioning
   into.  (The block with round 0 is special in that this block specifies not a
   transition but rather the entire initial state, which is called the _genesis
   state_.  This block is correspondingly called the _genesis block_.)
   The round is stored under msgpack key `rnd`.

 - The block's _genesis identifier_ and _genesis hash_, which match the
   genesis identifier and hash of the states it transitions between.
   The genesis identifier is stored under msgpack key `gen`, and the genesis
   hash is stored under msgpack key `gh`.

 - The block's _upgrade vote_, which results in the new upgrade state.  The
   block also duplicates the upgrade state of the state it transitions into.
   The msgpack representation of the components of the upgrade vote are described
   in detail below.

 - The block's _timestamp_, which matches the timestamp of the state it
   transitions into.  The timestamp is stored under msgpack key `ts`.

 - The block's _seed_, which matches the seed of the state it transitions into.
   The seed is stored under msgpack key `seed`.

 - The block's _reward updates_, which results in the new reward state.  The
   block also duplicates the reward state of the state it transitions into.
   The msgpack representation of the components of the reward updates are described
   in detail below.

 - A cryptographic commitment to the block's _transaction sequence_, described
   below, stored under msgpack key `txn`.

 - The block's _previous hash_, which is the cryptographic hash of the previous
   block in the sequence.  (The previous hash of the genesis block is 0.)  The
   previous hash is stored under msgpack key `prev`.

 - The block's _transaction counter_, which is the total number of transactions
   issued prior to this block.  This count starts from the first block with a
   protocol version that supported the transaction counter.  The counter is
   stored in msgpack field `tc`.
   
The block body is the block's transaction sequence, which describes the sequence
of updates (transactions) to the account state.

A block is _valid_ if each component is also _valid_.  (The genesis block is
always valid).  _Applying_ a valid block to a state produces a new state by
updating each of its components.  The rest of this document defines block
validity and state transitions by describing them for each component.


Round
=====

The round or _round number_ is a 64-bit unsigned integer which indexes into the
sequence of states and blocks.  The round $r$ of each block is one greater than
the round of the previous block.  Given a ledger, the round of a block
exclusively identifies it.

The rest of this document describes components of states and blocks with respect
to some implicit ledger.  Thus, the round exclusively describes some component,
and we denote the round of a component with a subscript.  For instance, the
timestamp of state/block $r$ is denoted $t_r$.


Genesis Identifier
==================

\newcommand \GenesisID {\mathrm{GenesisID}}

The genesis identifier is a short string that identifies an instance of a
ledger.

The genesis identifier of a valid block is the identifier of the block in the
previous round.  In other words, $\GenesisID_{r+1} = \GenesisID_{r}$.


Genesis Hash
============

\newcommand \GenesisHash {\mathrm{GenesisHash}}

The genesis hash is a cryptographic hash of the genesis configuration,
used to unambiguously identify an instance of the ledger.

The genesis hash is set in the genesis block (or the block at which
an upgrade to a protocol supporting GenesisHash occurs), and must be
preserved identically in all subsequent blocks.


Protocol Upgrade State
======================

A protocol version $v$ is a string no more than $V_{\max}$ bytes long. It
corresponds to parameters used to execute some version of the Algorand
protocol.

The upgrade vote in each block consists of a protocol version $v_r$, a 64-bit
unsigned integer $x_r$ which indicates the delay between the acceptance of a
protocol version and its execution, and a single bit $b$ indicating whether
the block proposer supports the given version.

The upgrade state in each block/state consists of the current protocol version
$v^*_r$, the next proposed protocol version $v'_r$, a 64-bit round number
$s_r$ counting the number of votes for the next protocol version, a 64-bit
round number $d_r$ specifying the deadline for voting on the next protocol
version, and a 64-bit round number $x_r'$ specifying when the next proposed
protocol version would take effect, if passed.

An upgrade vote $(v_r, x_r, b)$ is valid given the upgrade state
$(v^*_r, v'_r, s_r, d_r, x_r')$ if $v_r$ is the empty string or $v'_r$ is the
empty string, $\delta_{x_{\min}} \leq x_r \leq \delta_{x_{\max}}$, and either

 - $b = 0$ or
 - $b = 1$ with $r < d_r$ and either
    - $v'_r$ is not the empty string or
    - $v_r$ is not the empty string.

If the vote is valid, then the new upgrade state is
$(v^*_{r+1}, v'_{r+1}, s_{r+1}, d_{r+1}, x_{r+1})$ where

 - $v^*_{r+1}$ is $v'_r$ if $r = x_r'$ and $v^*_r$ otherwise.
 - $v'_{r+1}$ is
    - the empty string if $r = x_r'$ or both $r = s_r$ and $s_r + b < \tau$,
    - $v_r$ if $v'_r$ is the empty string, and
    - $v'_r$ otherwise.
 - $s_{r+1}$ is
    - 0 if $r = x_r'$ or both $r = s_r$ and $s_r + b < \tau$, and
    - $s_r + b$ otherwise
 - $d_{r+1}$ is
    - 0 if $r = x_r'$ or both $r = s_r$ and $s_r + b < \tau$,
    - $r + \delta_d$ if $v'_r$ is the empty string and $v_r$ is not the empty
      string, and
    - $d_r$ otherwise.
 - $x_{r+1}$ is
    - 0 if $r = x_r'$ or both $r = s_r$ and $s_r + b < \tau$,
    - $r + \delta_d + \delta$ if $v'_r$ is the empty string and $v_r$ is not
      the empty string (where $\delta = \delta_x$ if $x_r = 0$ and
      $\delta = x_r$ if $x_r \neq 0$), and
    - $x_r'$ otherwise.


Timestamp
=========

The timestamp is a 64-bit signed integer.  The timestamp is purely informational
and states when a block was first proposed, expressed in the number of seconds
since 00:00:00 Thursday, 1 January 1970 (UTC).

The timestamp $t_{r+1}$ of a block in round $r$ is valid if:

 - $t_{r} = 0$ or
 - $t_{r+1} > t_{r}$ and $t_{r+1} < t_{r} + t_{\delta}$.


Cryptographic Seed
==================

\newcommand \Seed {\mathrm{Seed}}

The seed is a 256-bit integer.  Seeds are validated and updated according to the
[specification of the Algorand Byzantine Fault Tolerance protocol][abft-spec].
The $\Seed$ procedure specified there returns the seed from the desired round.


Reward State
============

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


Account State
=============

\newcommand \Record {\mathrm{Record}}
\newcommand \pk {\mathrm{pk}}

The _balances_ are a set of mappings from _addresses_, 256-bit integers, to
_balance records_.  A _balance record_ contains the following fields: the
account _raw balance_, the account _status_, the account _rewards base_ and
_total awarded amount_, and the account [_participation keys_][partkey-spec].

The account raw balance $a_I$ is a 64-bit unsigned integer which determines how
much money the address has.

The account rewards base $a'_I$ and total awarded amount $a^*_I$ are 64-bit
unsigned integers.

Combined with the account balance, the reward base and total awarded amount are
used to distribute rewards to accounts lazily.  The _account stake_ is a
function which maps a given account and round to the account's balance in that
round and is defined as follows:
$$\Stake(r, I) = a_I + (T_r - a'_I) \floor{\frac{a_I}{A}}$$
unless $p_i = 2$ (see below), in which case:
$$\Stake(r, I) = a_I.$$

$\Units(r)$ is a function that computes the total number of whole _earning
units_ present in a system at round $r$.  A user owns $\floor{\frac{a_I}{A}}$
whole earning units, so the total number of earning units in the system is
$\Units(r) = \sum_I \floor{\frac{a_I}{A}}$ for the $a_I$ corresponding to round
$r$.

TODO define how $\Units$ updates.

The account status $p_I$ is an 8-bit unsigned integer which is either 0, 1,
or 2.  An account status of 0 corresponds to an _offline_ account, a status of 1
corresponds to an _online_ account, and a status of 2 corresponds to a
_non-participating_ account.

Combined with the account stake, the account status determines how much _voting
stake_ an account has, which is a 64-bit unsigned integer defined as follows:

 - The account balance, if the account is online.
 - 0 otherwise.

The account's participation keys $\pk$ are defined in Algorand's [specification
of participation keys][partkey-spec].

An account's participation keys and voting stake from a recent round is returned
by the $\Record$ procedure in the [Byzantine Agreement Protocol][abft-spec].

There exist two special addresses: $I_{pool}$, the address of the _incentive pool_,
and $I_f$, the address of the _fee sink_.  For both of these accounts,
$p_I = 2$.

Applications
------

Each account can create applications, each named by a globally-unique integer (the _application ID_). Applications are associated with a set of _application parameters_, which can be encoded as a msgpack struct:

- A mutable Stateful TEAL "Approval" program (`ApprovalProgram`), whose result determines whether or not an `ApplicationCall` transaction referring to this application ID is to be allowed. This program executes for all `ApplicationCall` transactions referring to this application ID except for those whose `OnCompletion == ClearState`, in which case the `ClearStateProgram` is executed instead. This field is encoded with msgpack field `approv`.

- A mutable Stateful TEAL "Clear State" program (`ClearStateProgram`), executed when an opted-in user forcibly removes the local application state associated with this application from their account data. This program, when executed, is not permitted to cause the transaction to fail. This field is encoded with msgpack field `clearp`.

- An immutable "global state schema" (`GlobalStateSchema`), which sets a limit on the size of the global [TEAL Key/Value Store][TEAL Key/Value Stores] that may be associated with this application (see ["State Schemas"][State Schemas]). This field is encoded with msgpack field `gsch`.

- An immutable "local state schema" (`LocalStateSchema`), which sets a limit on the size of a [TEAL Key/Value Store][TEAL Key/Value Stores] that this application will allocate in the account data of an account that has opted in (see ["State Schemas"][State Schemas]). This field is encoded with msgpack field `lsch`.

- The "global state" (`GlobalState`) associated with this application. This field is encoded with msgpack field `gs`.

Parameters for applications created by an account are stored in a map in the account state, indexed by the application ID. This map is encoded as msgpack field `appp`.

`LocalState` for applications that an account has opted in to are also stored in a map in the account state, indexed by the application ID. This map is encoded as msgpack field `appl`.

Assets
------

Each account can create assets, named by a globally-unique integer (the
_asset ID_).  Assets are associated with a set of _asset parameters_,
which can be encoded as a msgpack struct:

 - The total number of units of the asset that have been created, encoded with
   msgpack field `t`.  This value must be between 0 and $2^{64}-1$.

 - The number of digits after the decimal place to be used when displaying the
   asset, encoded with msgpack field `dc`.  A value of 0 represents an asset
   that is not divisible, while a value of 1 represents an asset divisible into
   into tenths, 2 into hundredths, and so on.  This value must be between 0 and
   and 19 (inclusive) ($2^{64}-1$ is 20 decimal digits).

 - Whether holdings of that asset are frozen by default, a boolean flag encoded
   with msgpack field `df`.

 - A string representing the unit name of the asset for display to the user,
   encoded with msgpack field `un`.  This field does not uniquely identify an
   asset; multiple assets can have the same unit name.  The maximum length of
   this field is 8 bytes.

 - A string representing the name of the asset for display to the user, encoded
   with msgpack field `an`.  As above, this does not uniquely identify an asset.
   The maximum length of this field is 32 bytes.

 - A string representing a URL that provides further description of the asset,
   encoded with msgpack field `au`.  As above, this does not uniquely identify
   an asset.  The maximum length of this field is 32 bytes.

 - A 32-byte hash specifying a commitment to asset-specific metadata, encoded with
   msgpack field `am`.  As above, this does not uniquely identify an asset.

 - An address of a _manager_ account, encoded with msgpack field `m`.  The manager
   address is used to update the addresses in the asset parameters using an asset
   configuration transaction.

 - An address of a _reserve_ account, encoded with msgpack field `r`.  The reserve
   address is not used in the protocol, and is used purely by client software for
   user display purposes.

 - An address of a _freeze_ account, encoded with msgpack field `f`.  The freeze
   address is used to issue asset freeze transactions.

 - An address of a _clawback_ account, encoded with msgpack field `c`.
   The clawback address is used to issue asset transfer transactions
   from arbitrary source addresses.

Parameters for assets created by an account are stored in a map in the
account state, indexed by the asset ID.

Accounts can hold up to $Assets_{\max}$ assets (1000 in this protocol).
An account must hold every asset that it created (even if it holds 0
units of that asset), until that asset is destroyed.  An account's asset
holding is simply a map from asset IDs to an integer value indicating
how many units of that asset is held by the account.  An account that
holds any asset cannot be closed.


Transactions
============

\newcommand \Tx {\mathrm{Tx}}
\newcommand \TxSeq {\mathrm{TxSeq}}
\newcommand \TxTail {\mathrm{TxTail}}
\newcommand \TxType {\mathrm{TxType}}
\newcommand \TxCommit {\mathrm{TxCommit}}

\newcommand \vpk {\mathrm{vpk}}
\newcommand \spk {\mathrm{spk}}
\newcommand \vf {\mathrm{vf}}
\newcommand \vl {\mathrm{vl}}
\newcommand \vkd {\mathrm{vkd}}

\newcommand \Hash {\mathrm{Hash}}
\newcommand \nonpart {\mathrm{nonpart}}

Just as a block represents a transition between two ledger states, a
_transaction_ $\Tx$ represents a transition between two account states. A
transaction contains the following fields:

 - The _transaction type_ $\TxType$, which is a short string that indicates the
   type of a transaction.  The following transaction types are supported:

   - Transaction type `pay` corresponds to a _payment_ transaction.

   - Transaction type `keyreg` corresponds to a _key registration_ transaction.

   - Transaction type `acfg` corresponds to an _asset configuration_ transaction.

   - Transaction type `axfer` corresponds to an _asset transfer_ transaction.

   - Transaction type `afrz` corresponds to an _asset freeze_ transaction.

 - The _sender_ $I$, which is an address which identifies the account that
   authorized the transaction.

 - The _fee_ $f$, which is a 64-bit integer that specifies the processing fee
   the sender pays to execute the transaction.

 - The first round $r_1$ and last round $r_2$ for which the transaction may be
   executed.

 - The _lease_ $x$, which is an optional 256-bit integer specifying mutual
   exclusion.  If $x \neq 0$ (i.e., $x$ is set) and this transaction is
   confirmed, then this transaction prevents another transaction from the same
   sender and with the lease set to the same value from being confirmed until
   $r_2$ is confirmed.

 - The _genesis identifier_ $\GenesisID$ of the ledger for which this
   transaction is valid.  The $\GenesisID$ is optional.

 - The _genesis hash_ $\GenesisHash$ of the ledger for which this
   transaction is valid.  The $\GenesisHash$ is required.

 - The _group_ $grp$, an optional 32-byte hash whose meaning is described in
   the [Transaction Groups][Transaction Groups] section below.

 - The _note_ $N$, a sequence of bytes with length at most $N_{\max}$ which
   contains arbitrary data.


A payment transaction additionally has the following fields:

 - The _amount_ $a$, which is a 64-bit number that indicates the amount of money
   to be transferred.

 - The _receiver_ $I'$, which is an optional address which specifies the
   receiver of the funds in the transaction.

 - The _closing address_ $I_0$, which is an optional address that collects all
   remaining funds in the account after the transfer to the receiver.

A key registration transaction additionally has the following fields:

 - The _vote public key_ $\vpk$, (root) public authentication key 
   of an account's participation keys ($\pk$).

 - The _selection public key_ $\spk$, public authorization key of 
   an account's participation keys ($\pk$). If either $\vpk$ or 
   $\spk$ is unset, the transaction deregisters the account's participation 
   key set, as the result, marks the account offline.

 - The _vote first_ $\vf$, first valid round (inclusive) of 
   an account's participation key sets.

 - The _vote last_ $\vl$, last valid round (inclusive) of an account's
   participation key sets.

 - The _vote key dilution_ $\vkd$, number of rounds that a single 
  leaf level authentication key can be used. The higher the number, the 
  more ``dilution'' added to the authentication key's security.  

 - An optional (boolean) flag $\nonpart$ which, when deregistering keys,
   specifies whether to mark the account offline (if $\nonpart$ is false)
   or nonparticipatory (if $\nonpart$ is true).

An application call transaction additionally has the following fields:

- The ID of the application being called, encoded as msgpack field `apid`. If the ID is zero, this transaction is creating an application.

- An `OnCompletion` type, which may specify an additional effect of this transaction on the application's state in the sender or application creator's account data.  This field is encoded as msgpack field `apan`, and may take on one of the following values:

  - `NoOpOC` (value `0`): Only execute the `ApprovalProgram` associated with this application ID, with no additional effects.
  - `OptInOC` (value `1`): Before executing the `ApprovalProgram`, allocate local state for this application into the sender's account data.
  - `CloseOutOC` (value `2`): After executing the `ApprovalProgram`, clear any local state for this application out of the sender's account data.
  - `ClearStateOC` (value `3`): Don't execute the `ApprovalProgram`, and instead execute the `ClearStateProgram` (which may not reject this transaction). Additionally, clear any local state for this application out of the sender's account data as in `CloseOutOC`.
  - `UpdateApplicationOC` (value `4`): After executing the `ApprovalProgram`, replace the `ApprovalProgram` and `ClearStateProgram` associated with this application ID with the programs specified in this transaction.
  - `DeleteApplicationOC` (value `5`): After executing the `ApprovalProgram`, delete the application parameters from the account data of the application's creator.
- Application arguments, encoded as msgpack field `apaa`. These arguments are a slice of byte slices.
- Accounts besides the `Sender` whose local states may be referred to by the executing `ApprovalProgram` or `ClearStateProgram`. These accounts are referred to by their addresses, and this field is encoded as msgpack field `apat`.
- Application IDs, besides the application whose `ApprovalProgram` or `ClearStateProgram` is executing, that the executing program may read global state from. This field is encoded as msgpack field `apfa`.
- Local state schema, encoded as msgpack field `apls`. This field is only used during application creation, and sets bounds on the size of the local state for users who opt in to this application.
- Global state schema, encoded as msgpack field `apgs`. This field is only used during application creation, and sets bounds on the size of the global state associated with this application.
- Approval program, encoded as msgpack field `apap`. This field is used for both application creation and updates, and sets the corresponding application's `ApprovalProgram`.
- Clear state program, encoded as msgpack field `apsu`. This field is used for both application creation and updates, and sets the corresponding application's `ClearStateProgram`.

An asset configuration transaction additionally has the following fields:

 - The ID of the asset being configured, encoded as msgpack field `caid`.
   If the ID is zero, this transaction is creating an asset.

 - The parameters for the asset being configured, encoded as a struct under
   msgpack field `apar`.  If this value is omitted (zero value), this
   transaction is deleting the asset.

An asset transfer transaction additionally has the following fields:

 - The ID of the asset being transferred, encoded as msgpack field `xaid`.

 - The number of units of the asset being transferred, encoded as msgpack
   field `aamt`.

 - The source address for the asset transfer (non-zero iff this is a
   clawback), encoded as msgpack field `asnd`.

 - The destination address for the asset transfer, encoded as msgpack field
   `arcv`.

 - The address to which all remaining asset units should be transferred
   to close out this account's holdings of this asset, encoded as msgpack
   field `aclose`.

An asset freeze transaction additionally has the following fields:

 - The address of the account whose holdings of an asset should be frozen
   or unfrozen, encoded as msgpack field `fadd`.

 - The ID of the asset the holdings of which should be frozen or unfrozen,
   encoded as msgpack field `faid`.

 - The new setting of whether the holdings should be frozen or unfrozen,
   encoded as a boolean msgpack field `afrz` (true for frozen, false for
   unfrozen).

The cryptographic hash of the fields above is called the _transaction
identifier_.  This is written as $\Hash(\Tx)$.

A valid transaction can either be a _signed_ transaction, a _multi-signed_
transaction, or a _logic-signed_ transaction.
This is determined by the _signature_ of a transaction:

 - A valid signed transaction's signature is a 64-byte sequence which validates
   under the sender of the transaction.

 - A valid multisignature transaction's signature is the _msig_ object containing
   the following fields (see [Multisignature][Multisignature] for details):

   - The _subsig_ array of subsignatures each consisting of a signer address and a signature
     as a 64-byte sequence. Note, multisignature transaction must contain
     all signer's addresses in the _subsig_ array even if the transaction has not
     been signed yet.

   - The threshold _thr_ that is a minimum number of signatures required.

   - The multisignature version _v_ (current value is 1).

- A valid logic-signed transaction's signature is the _lsig_ object containing
  the following fields:

  - The logic _l_ which is versioned bytecode. (See TEAL docs for details)

  - An optional single signature _sig_ of 64 bytes valid for the sender of the transaction which has signed the bytes in _l_.

  - An optional multisignature _msig_ from the transaction sender over the bytes in _l_.

  - An optional array of byte strings _arg_ which are arguments supplied to the program in _l_. (_arg_ bytes are not covered by _sig_ or _msig_)

  The logic signature is valid if exactly one of _sig_ or _msig_ is a valid signature of the program by the sender of the transaction, or if neither _sig_ nor _msig_ is set and the hash of the program is equal to the sender address. Also the program must execute and finish with a single non-zero value on the stack. See [TEAL documentation](TEAL.md) for details on program execution.


ApplyData
---------

\newcommand \ClosingAmount {\mathrm{ClosingAmount}}

Each transaction is associated with some information about how it is
applied to the account state.  This information is called ApplyData,
and contains the following fields:

- The closing amount, $\ClosingAmount$, which specifies how many microalgos
  were transferred to the closing address.

- The amount of rewards distributed to each of the accounts touched by this
  transaction.  There are three fields ("rs", "rr", and "rc" keys in msgpack
  encoding), representing the amount of rewards distributed to the sender,
  receiver, and closing addresses respectively.  The fields have integer
  values representing microalgos.  If any of the accounts are the same
  (e.g., the sender and recipient are the same), then that account received
  the sum of the respective reward distributions (i.e., "rs" plus "rr");
  in the reference implementation, one of these two fields will be zero
  in that case.

- If this is an `ApplicationCall` transaction, the `EvalDelta` associated with the successful execution of the corresponding application's `ApprovalProgram` or `ClearStateProgram`. The `EvalDelta`, encoded as msgpack field `dt`, contains the following fields:
  - A `GlobalDelta`, encoding changes to the global state of the called application, encoded as msgpack field `gd`.
    - `gd` is a [`StateDelta`][State Deltas].
  - Zero or more `LocalDeltas`, encoding changes to some local states associated with the called applicaiton, encoded as msgpack field `ld`.
    - `ld` maps an "account offset" to a [`StateDelta`][State Deltas]. Account offset 0 is the transaction's sender. Account offsets 1 and greater refer to the account specified at that index minus one in the transaction's `Accounts` slice.

TEAL Key/Value Stores
---------------------
A TEAL Key/Value Store, or TKV, is an associative array mapping keys of type byte-array to values of type byte-array or 64-bit unsigned integer.

The values in a TKV are represented by the `TealValue` struct, which is composed of three fields:

- `Type`, encoded as msgpack field `tt`. This field may take on one of two values:
  - `TealBytesType` (value = `1`), indicating that the value can be found in the `Bytes` field of this struct.
  - `TealUintType` (value = `2`), indicating that the value can be found in the `Uint` field of this struct.
- `Bytes`, encoded as msgpack field `tb`, representing a byte slice value.
- `Uint`, encoded as msgpack field `ui`, representing an unsigned 64-bit integer value.

The keys in a TKV are encoded directly as bytes.

State Deltas
------------

A state delta represents an update to a [TEAL Key/Value Store (TKV)][TEAL Key/Value Stores]. It is represented as an associative array mapping a byte-array key to a single value delta.

A value delta is composed of three fields:

- Action, encoded as msgpack field `at`, which specifies how the value for this key has changed. It has three possible values:
  - `SetUintAction` (value = `1`), indicating that the value for this key should be set to the value delta's `Uint` field.
  - `SetBytesAction` (value = `2`), indicating that the value for this key should be set to the value delta's `Bytes` field.
  - `DeleteAction` (value = `3`), indicating that the value for this key should be deleted.

State Schemas
-------------

A state schema represents limits on the number of each value type that may appear in a [TEAL Key/Value Store (TKV)][TEAL Key/Value Stores].

A state schema is composed of two fields:

- `NumUint`, encoded as msgpack field `nui`. This field represents the maximum number of integer values that may appear in some TKV.
- `NumByteSlice`, encoded as msgpack field `nbs`. This field represents the maximum number of byte slice values that may appear in some TKV.

Transaction Sequences, Sets, and Tails
--------------------------------------

Each block contains a _transaction sequence_, an ordered sequence of
transactions in that block.  The transaction sequence of block $r$ is denoted
$\TxSeq_r$.  Each valid block contains a _transaction commitment_ $\TxCommit_r$
which is the commitment to this sequence (a hash of the msgpack encoding of the
sequence).

There are two differences between how a standalone transaction is encoded,
and how it appears in the block:

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


Transaction Groups
------------------

A transaction may include a "Group" field (msgpack tag "grp"), a 32-byte hash
that specifies what _transaction group_ the transaction belongs to.
Informally, a transaction group is an ordered list of transactions that, in
order to be confirmed at all, must all be confirmed together, in order, in the
same block. The "Group" field in each transaction is set to what is essentially
the hash of the list of transaction hashes in the group, except to avoid
circularity, when hashing a transaction it is hashed with its "Group" field
omitted. In this way a user wanting to require transaction A to confirm if and
only if transactions B and C confirm can take the hashes of transactions A, B,
and C (without the "Group" field set), hash them together, and set the "Group"
field of all three transactions to that hash before signing them.
A group may contain no more than $G_{max}$ transactions.

More formally, when evaluating a block, consider the $i$th and $(i+1)$th
transaction in the payset to belong to the same _transaction group_ if the
"Group" fields of the two transactions are equal and nonzero.  The block may
now be viewed as an ordered sequence of transaction groups, where each
transaction group is a contiguous sublist of the payset consisting of one or
more transactions with equal "Group" field.  For each transaction group where
the transactions have nonzero "Group", compute the _TxGroup hash_ as follows:

 - Take the hash of each transaction in the group but with its "Group" field omitted.
 - Hash this ordered list of hashes -- more precisely, hash the canonical msgpack encoding of a struct with a field "txlist" containing the list of hashes, using "TG" as domain separation prefix.

If the TxGroup hash of any transaction group in a block does not match the "Group" field of the transactions in that group (and that "Group" field is nonzero), then the block is invalid. Additionally, if a block contains a transaction group of more than $G_{max}$ transactions, the block is invalid.

Beyond this check, each transaction in a group is evaluated separately and must be valid on its own, as described below in the [Validity and State Changes][Validity and State Changes] section. For example, a group containing a zero-fee transaction and a very-high-fee transaction would be rejected because the first transaction has fee less than $f_{\min}$, even if the average transaction fee of the group were above $f_{\min}$. As another example, an account with balance 50 could not spend 100 in transaction A and afterward receive 500 in transaction B, even if transactions A and B are in the same group, because transaction A would leave the account with a negative balance.

Asset Transaction Semantics
---------------------------

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
   the total specified in the parameters) are held by the creator.

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

`ApplicationCall` Transaction Semantics
---------------------------------------

When an `ApplicationCall` transaction is evaluated by the network, it is processed according to the following procedure. None of the effects of the transaction are made visible to other transactions until the points marked **SUCCEED** below. **FAIL** indicates that any modifications to state up to that point must be discarded and the entire transaction rejected.

1.
    - If the Application ID specified by the transaction is zero, create a new application with ID equal to one plus the system transaction counter (this is the same ID selection algorithm as used by Assets).

        When creating an application, the application parameters specified by the transaction (`ApprovalProgram`, `ClearStateProgram`, `GlobalStateSchema`, and `LocalStateSchema`) are allocated into the sender’s account data, keyed by the new Application ID.

        Continue to step 2.

    - If the Application ID specified by the transaction is nonzero, continue to step 2.
2.
    - If `OnCompletion == ClearState`, then:
        - Check if the transaction’s sender is opted in to this Application ID. If not, **FAIL.**
        - Check if the application still exists by looking up the creator’s account by Application ID and checking if it contains the Application’s parameters.
            - If the application does not exist, delete the sender’s local state for this application (marking them as no longer opted in), and **SUCCEED.**
            - If the application does exist, continue to step 3.
    - If the OnCompletion type of this transaction is not ClearState, continue to step 4.
3.
    - Execute the `ClearStateProgram`.
        - If the program execution returns `PASS == true`, apply the local/global key/value store deltas generated by the program’s execution.
        - If the program execution returns `PASS == false`, do not apply any local/global key/value store deltas generated by the program’s execution.
    - Delete the sender’s local state for this application (marking them as no longer opted in). **SUCCEED.**
4.
    - If `OnCompletion == OptIn`, then at this point during execution we will allocate a local Key/Value store for the sender for this Application ID.

        Once this state has been allocated, then from this point forward until an OptOut or ClearState `ApplicationCall` transaction is issued, the sender will be considered opted in to this Application ID.

        Continue to step 5.
5.
    - Execute the `ApprovalProgram`.
        - If the program execution returns `PASS == true`, apply any local/global key/value store deltas generated by the program’s execution. Continue to step 6.
        - If the program execution returns `PASS == false`, **FAIL.**
6.
    - If `OnCompletion == NoOp`
        - **SUCCEED.**
    - If `OnCompletion == OptIn`
        - This was handled above. **SUCCEED.**
    - If `OnCompletion == CloseOut`
        - Check if the transaction’s sender is opted in to this application ID. If not, **FAIL.**
        - Delete the sender’s local state for this application (marking them as no longer opted in). **SUCCEED.**
    - If `OnCompletion == ClearState`
        - This was handled above (unreachable).
    - If `OnCompletion == DeleteApplication`
        - Delete the application’s parameters from the creator’s account data. (Note: this does not affect any local state). **SUCCEED.**
    - If `OnCompletion == UpdateApplication`
        - Update the Approval and ClearState programs for this application according to the programs specified in this `ApplicationCall` transaction. The new programs are not executed in this transaction. **SUCCEED.**

Application Stateful TEAL Execution Semantics
---------------------------------------------

- During the execution of an `ApprovalProgram` or `ClearStateProgram`, the application’s `LocalStateSchema` and `GlobalStateSchema` may never be violated. The program's execution will fail on the first instruction that would cause the relevant schema to be violated.
- Global state may only be read for the application ID whose program is executing, or for any application ID mentioned in the `ForeignApps` transaction field. An attempt to read global state for another application that is not listed in `ForeignApps` will cause the program execution to fail.
- Local state may be read for any opted-in application present in the sender’s account data, or in the account data for any address listed in the transaction’s `Accounts` field. An attempt to read local state from any other account will cause program execution to fail.

Validity and State Changes
--------------------------

The new account state which results from applying a block is the account state
which results from applying each transaction in that block, in sequence. For a
block to be valid, each transaction in its transaction sequence must be valid at
the block's round $r$ and for the block's genesis identifier $\GenesisID_B$.

For a transaction
$$\Tx = (\GenesisID, \TxType, r_1, r_2, I, I', I_0, f, a, x, N, \pk, \nonpart,
  \ldots)$$
(where $\ldots$ represents fields specific to asset transaction types)
to be valid at the intermediate state $\rho$ in round $r$ for the genesis
identifier $\GenesisID_B$, the following conditions must all hold:

 - It must represent a transition between two valid account states.
 - Either $\GenesisID = \GenesisID_B$ or $\GenesisID$ is the empty string.
 - $\TxType$ is either "pay" or "keyreg".
 - There are no extra fields that do not correspond to $\TxType$.
 - $0 \leq r_2 - r_1 \leq T_{\max}$.
 - $r_1 \leq r \leq r_2$.
 - $|N| \leq N_{\max}$.
 - $I \neq I_{pool}$ and $I \neq 0$.
 - $\Stake(r+1, I) \geq f \geq f_{\min}$.
 - Exactly one of the signature or the multisignature is present and verifies
   for $\Hash(\Tx)$ under $I$.
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
    - If $\nonpart$ is true then $\pk = 0$

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

For asset transaction types (asset configuration, asset transfer, and asset freeze),
account state is updated based on the reference logic described in [Asset Transaction Semantics].

TODO define the sequence of intermediate states

The final intermediate account $\rho_k$ state changes the balance of the
incentive pool as follows:
$$a_{\rho_k, I_{pool}} = a_{\rho_{k-1}, I_{pool}} - R_r(\Units(r))$$

An account state in the intermediate state $\rho+1$ and at round $r$ is valid if
all following conditions hold:

 - For all addresses $I \notin \{I_{pool}, I_f\}$, either $\Stake(\rho+1, I) = 0$ or
   $\Stake(\rho+1, I) \geq b_{\min} \times (1 + NA)$, where $NA$ is the number of
   assets held by that account.

 - For all addresses, the number of assets held by that address must be less than
   $Assets_{\max}$.

 - $\sum_I \Stake(\rho+1, I) = \sum_I \Stake(\rho, I)$.


Previous Hash
=============

\newcommand \Prev {\mathrm{Prev}}

The previous hash is a cryptographic hash of the previous block header in the
sequence of blocks.  The sequence of previous hashes in each block header forms
an authenticated, linked-list of the reversed sequence.

Let $B_{r}$ represent the block header in round $r$, and let $H$ be some
cryptographic function.  Then the previous hash $\Prev_{r+1}$ in the block for
round $r+1$ is $\Prev_{r+1} = H(B_{r})$.


Multisignature
==============

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


[abft-spec]: https://github.com/algorand/spec/abft.md
[partkey-spec]: https://github.com/algorand/spec/partkey.md
