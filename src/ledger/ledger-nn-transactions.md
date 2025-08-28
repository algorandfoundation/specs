# Transactions

A _transaction_ defines a _state transition_ of Accounts.

Algorand has \\( 8 \\) transaction types.

Transactions consist of:

- A _header_ (common to any type),

- A _body_ (type-specific).

{{#include ../_include/styles.md:impl}}
> Transaction [package](https://github.com/algorand/go-algorand/tree/18990e06116efa0ad29008d5879c8e4dcfa51653/data/transactions).

## Transaction Levels

Algorand transactions have two execution levels:

- _Top Level_: transactions are signed and cannot be duplicated in the Ledger,

- _Inner Level_: transactions are not signed and may be duplicated in the Ledger.

## Transaction Types

The transaction type is identified with a short string of at most [7 characters](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/protocol/txntype.go#L26-L27):

| TYPE ID  | TRANSACTION TYPE                                               |
|:--------:|----------------------------------------------------------------|
|  `pay`   | Payment (ALGO transfer)                                        |
| `keyreg` | Consensus participation keys registration and deregistration   |
|  `acfg`  | Algorand Standard Asset transfer                               |
| `axfer`  | Algorand Strandard Asset creation and reconfiguraiton          |
|  `afrz`  | Algorand Standard Asset freeze (withelisting and blacklisting) |
|  `appl`  | Application (Smart Contract) call
|  `stpf`  | Algorand State Proof                                           |
|   `hb`   | Consensus heartbeat challange                                  |

> For a formal definition of all transaction fields, refer to the [normative section](ledger.md#transactions).

{{#include ../_include/styles.md:impl}}
> The reference implementation also defines the `unknown` transaction type.
>
> Transaction types [definition](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/protocol/txntype.go#L28-L55).

{{#include ../_include/styles.md:impl}}
> Transaction types [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/transactions/transaction.go#L87-L109).

## Transaction Header

The _transaction header_, equal for all transaction types, consists of:

- `TransactionType`
Identifies the transaction type and the related _body_ required fields.

- `Sender`\
That [signs](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/transactions/transaction.go#L266-L278) the transaction.

- `Fee`\
The amount paid by the sender to execute the transaction. Fees can be delegated (set
to \\( 0 \\)) within a transaction `Group` (see group transaction [non-normative section](./ledger-nn-gorup-transaction.md)).

- `FirstValidRound` \\( \r_F \\) and `LastValidRound` \\( \r_L \\)\ 
The difference \\( (r_L - r_F) \\) cannot be greater than \\( 1000 \\) [rounds](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/config/consensus.go#L938).

- `Note` (Optional)\
Contains up to \\( 1 \\) kB of arbitrary data.

- `GenesisHash`\
Ensures the transaction targets a specific Ledger (e.g., `wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8=` for MainNet).

- `GenesisID` (Optional)\
Like the _Genesis Hash_, it [ensures](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/data/transactions/transaction.go#L307)
that the transaction targets a specific Ledger (e.g., `mainnet-v1.0` for MainNet).

- `Group` (Optional)\
A cryptographic commitment to the _group_ this transaction is part of (see group
transaction [non-normative section](./ledger-nn-gorup-transaction.md)).

- `Lease` (Optional)\
32-byte array that enforces [mutual exclusion of transactions](https://github.com/algorand/go-algorand/blob/fcad0bbcc035a8d253cac08e4f90c9c813c40668/ledger/store/trackerdb/data.go#L844-L868).
If this field is set, it acquires a `Lease`(`Sender`, `Lease`), valid until the
`LastValidRound` \\( r_L \\) expires. While the transaction maintains the `Lease`,
no other transaction with the same `Lease` can be committed.

> A typical use case of the `Lease` is a batch of signed transactions, with the
> same `Lease`, sent to the network to ensure only one is executed.

- `RekeyTo`\
An Algorand _address_ (32-byte). If non-zero, the transaction will set the `Sender`
account’s [spending key](../partkey.md#root-keys) to this address as last transaction effect. Therefore,
future transactions sent by the `Sender` account must now be signed with the secret
key of the _address_.

The _transaction header_ verification ensures that a transaction:

- Is signed adequately by the `Sender` (either `SingleSig`, `MultiSig`, or `LogicSig`),

- It is submitted to the right Ledger (`GenesisHash`);

- Pays the `MinFee` (\\( 1000 \\) μALGO) or `PerByteFee` (if network is congested);
  - `Fee` act as an anti-spam mechanism (grows exponentially if the network is congested
  or decays if there is spare block capacity);
  - `Fee` prioritization is not enforced by consensus (although a node does that);
  - Inner Transaction costs _always_ the `MinFee` (regardless of network congestion);
  - `Fee` are pooled in `Group` transactions;
  - `Fee` is independent of the `TransactionType` or usage (i.e., no local fee market);

- `Round`'s validity is not expired (\\( 1000 \\) rounds at most);

- `FirstValidRound` can be delayed in the future;

- `Round`'s validity handles transactions’ idempotency, letting Non-Archival nodes
participate in consensus;

- It is not leased (combination of `Sender` and `Lease`) in its validity range.