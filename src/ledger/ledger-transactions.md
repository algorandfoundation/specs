$$
\newcommand \Tx {\mathrm{Tx}}
\newcommand \TxSeq {\mathrm{TxSeq}}
\newcommand \TxTail {\mathrm{TxTail}}
\newcommand \TxType {\mathrm{TxType}}
\newcommand \TxCommit {\mathrm{TxCommit}}
\newcommand \vpk {\mathrm{vpk}}
\newcommand \spk {\mathrm{spk}}
\newcommand \sppk {\mathrm{sppk}}
\newcommand \vf {\mathrm{vf}}
\newcommand \vl {\mathrm{vl}}
\newcommand \vkd {\mathrm{vkd}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \nonpart {\mathrm{nonpart}}
\newcommand \RekeyTo {\mathrm{RekeyTo}}
\newcommand \FirstValidRound {r_\mathrm{fv}}
\newcommand \LastValidRound {r_\mathrm{lv}}
\newcommand \Genesis {\mathrm{Genesis}}
\newcommand \GenesisID {\Genesis\mathrm{ID}}
\newcommand \GenesisID {\Genesis\Hash}
\newcommand \Group {\Tx\mathrm{G}}
\newcommand \RekeyTo {\mathrm{RekeyTo}}
\newcommand \MaxTxnNoteBytes {T_{m,\max}}
$$

# Transactions

Just as a block represents a transition between two Ledger states, a _transaction_
\\( \Tx \\) represents a transition between two account states.

Algorand transactions have different _transaction types_.

Transaction _fields_ are divided into a:

- A _header_, common to any type,

- A _body_, which is type-specific.

Transaction fields are **REQUIRED** unless specified as **OPTIONAL**.

The cryptographic hash of the transaction fields, including the transaction specific
fields of the _body_, is called the _transaction identifier_. This is written as
\\( \Hash(\Tx) \\).

## Transaction Header

A transaction _header_ contains the following fields:

- The _transaction type_ \\( \TxType \\), encoded as msgpack field `type`, is a
short string indicating the type of transaction. The following transaction types
are supported:

|   TYPE   | DESCRIPTION                      |
|:--------:|:---------------------------------|
|  `pay`   | ALGO transfers (payment)         |
| `keyreg` | Consensus keys registration      |
|  `acfg`  | Asset creation and configuration |
| `axfer`  | Asset transfer                   |
|  `afrz`  | Asset freeze and unfreeze        |
|  `appl`  | Application calls                |
|  `stpf`  | State Proof                      |
|   `hb`   | Consensus heartbeat              |

- The _sender_ \\( I \\), encoded as msgpack field `snd`, is the 32-byte address
that identifies the account that authorized the transaction.

- The _fee_ \\( f \\), encoded as msgpack field `fee`, is a 64-bit unsigned integer
that specifies the processing fee the _sender_ pays to execute the transaction,
expressed in μALGO. The _fee_ **MAY** be set to \\( 0 \\) if the transaction is
part of a [group](./ledger-txn-group.md).

- The _first valid_ \\( \FirstValidRound \\) and _last valid_ \\( \LastValidRound \\),
encoded respectively as msgpack fields `fv` and `lv`, are 64-bit unsigned integers
which define a round interval for which the transaction **MAY** be executed.

<!-- TODO: Specify the ordering between \FirstValidRound and \LastValidRound -->

- The _lease_ \\( x \\), encoded as msgpack field `lx`, is an **OPTIONAL** 32-byte
array specifying mutual exclusion. If \\( x \neq 0 \\) (i.e., \\( x \\) is set) and
this transaction is confirmed, then this transaction prevents another transaction
from the same _sender_ and with the _same lease_ from being confirmed until \\( \LastValidRound \\)
is confirmed.

- The _genesis identifier_ \\( \GenesisID \\), encoded as msgpack field `gen`, is
an **OPTIONAL** string, which defines the Ledger for which this transaction is valid.

- The _genesis hash_ \\( \GenesisHash \\), encoded as msgpack field `gh`, is a 32-byte
hash, which defines the Ledger for which this transaction is valid.

- The _group_ \\( \Group \\), encoded as msgpack field `grp`, is an **OPTIONAL**
32-byte hash whose meaning is described in the [Transaction Groups][Transaction Groups]
section.

- The _rekey to address_ \\( \RekeyTo \\), encoded as msgpack field `rekey`, is
an **OPTIONAL** 32-byte address. If nonzero, the transaction will set the _sender_
account's _authorization address_ field to this value. If the \\( \RekeyTo \\) address
matches the _sender_ address, then the _authorization address_ is instead set to
zero, and the original _spending keys_ are re-established.
 
> The _rekey_ functionally works as if the _account_ replaces its private [_spending
> keys_](partkey.md#root-keys), while its address remains the same. The account is
> now controlled by the _authorization address_ (i.e., transaction signatures are
> checked against this address).

- The _note_ \\( N \\), encoded as msgpack field `note`, is an **OPTIONAL** bytes-array
with length at most \\( \MaxTxnNoteBytes \\) which contains arbitrary data.