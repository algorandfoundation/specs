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
\newcommand \GenesisHash {\Genesis\Hash}
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

| FIELD              |  CODEC  |    TYPE     | REQUIRED |
|:-------------------|:-------:|:-----------:|:--------:|
| Transaction Type   | `type`  |  `string`   |   Yes    |
| Sender             |  `snd`  |  `address`  |   Yes    |
| Fee                |  `fee`  |  `uint64`   |   Yes    |
| First Valid Round  |  `fv`   |  `uint64`   |   Yes    |
| Last Valid Round   |  `lv`   |  `uint64`   |   Yes    |
| Genesis Hash       |  `gh`   | `[32]byte`  |   Yes    |
| Lease              |  `lx`   | `[32]byte`  |    No    |
| Genesis Identifier |  `gen`  |  `string`   |    No    |
| Group              |  `grp`  | `[32]byte`  |    No    |
| Rekey-to           | `rekey` |  `address`  |    No    |
| Note               | `note`  | `[32]bytes` |    No    |

### Transaction Type

The _transaction type_ \\( \TxType \\) is a short string indicating the type of
transaction.

The following transaction types are supported:

|  CODEC   | DESCRIPTION                      |
|:--------:|:---------------------------------|
|  `pay`   | ALGO transfers (payment)         |
| `keyreg` | Consensus keys registration      |
|  `acfg`  | Asset creation and configuration |
| `axfer`  | Asset transfer                   |
|  `afrz`  | Asset freeze and unfreeze        |
|  `appl`  | Application calls                |
|  `stpf`  | State Proof                      |
|   `hb`   | Consensus heartbeat              |

### Sender

The _sender_ \\( I \\) identifies the account that authorized the transaction.

### Fee

The _fee_ \\( f \\) specifies the processing fee the _sender_ pays to execute the
transaction, expressed in μALGO.

The _fee_ **MAY** be set to \\( 0 \\) if the transaction is part of a [group](./ledger-txn-group.md).

### First and Last Valid Round

The _first valid round_ \\( \FirstValidRound \\) and _last valid round_ \\( \LastValidRound \\),
define a round interval for which the transaction **MAY** be executed.

<!-- TODO: Specify the ordering between \FirstValidRound and \LastValidRound -->

### Genesis Hash

The _genesis hash_ \\( \GenesisHash \\) defines the Ledger for which this transaction
is valid.

### Genesis Identifier

The _genesis identifier_ \\( \GenesisID \\) (**OPTIONAL**) defines the Ledger for
which this transaction is valid.

### Lease

The _lease_ \\( x \\) (**OPTIONAL**) specifies transactions' mutual exclusion. If
\\( x \neq 0 \\) (i.e., \\( x \\) is set) and this transaction is confirmed, then
this transaction prevents another transaction from the same _sender_ and with the
same _lease_ from being confirmed until \\( \LastValidRound \\) is confirmed.

### Group

The _group_ \\( \Group \\) (**OPTIONAL**) is a commitment whose meaning is described
in the [Transaction Groups]() section.

### Rekey-to

The _rekey to_ \\( \RekeyTo \\) (**OPTIONAL**) is an address. If nonzero, the transaction
will set the _sender_ account’s _authorization address_ field to this value. If the
\\( \RekeyTo \\) address matches the _sender_ address, then the _authorization address_
is instead set to zero, and the original _spending keys_ are re-established.
 
> The _rekey_ functionally works as if the _account_ replaces its private [_spending
> keys_](partkey.md#root-keys), while its address remains the same. The account is
> now controlled by the _authorization address_ (i.e., transaction signatures are
> checked against this address).

### Note

The _note_ \\( N \\) (**OPTIONAL**) contains arbitrary data appended to the transaction.

- The _note_ byte length **MUST NOT** exceed \\( \MaxTxnNoteBytes \\).

## Semantic

TODO

## Validation

Each transaction type must meet their own validation requirements. These can be found in the Validation section of each transaction type.
[Payment Transaction](ledger-txn-payment#Validation)
[Key Registration Transaction](ledger-txn-keyreg#Validation)
[Asset Configuration Transaction](ledger-txn-asset-config#Validation)
[Asset Transfer Transaction](ledger-txn-asset-transfer#Validation)
[Asset Freeze Transaction](ledger-txn-asset-freeze#Validation)
[Application Transaction](ledger-txn-application-call#Validation)
[State Proof Transaction](ledger-txn-state-proof#Validation)
[Heartbeat Transaction](ledger-txn-heartbeat#Validation)

In addition, each transaction must also meet the following requirements:

 - Fields from other transaction types **MUST NOT** exist within the transaction
 - Before proto.EnableFeePooling, the _fee_ field **MUST** be greater than or equal to the _minimum fee_. Excluding State Proof transactions
 - The _last round_ **MUST BE** less than the _first round_
 - The _last round_ minus the _first round_ **MUST NOT** be greater than \\( \MaxTxnLife \\)
 - The _node_ field **MUST NOT** exceed \\( \MaxTxnNodeBytes \\)
 - The _sender_ **MUST NOT** be the RewardsPool address
 - The _sender_ **MUST NOT** be missing
 - If SupportTransactionLeases, and the _lease_ field is provided, it **MUST** be 32 bytes long
 - Before SupportTxGroups, the _group_ field **MUST** be empty
 - Before SupportRekeying, the _rekey_ field **MUST** be empty
