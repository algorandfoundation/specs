$$
\newcommand \Hash {\mathrm{Hash}}
\newcommand \MaxTxGroupSize {GT_{\max}}
\newcommand \MinTxnFee {T_{\Fee,\min}}
\newcommand \BytesPerBoxReference {\Box_{\mathrm{IO}}}
\newcommand \LogicSigMaxSize {\LogicSig_{\max}}
\newcommand \MaxAbsoluteLogicSigProgramSize {\LogicSig_{\mathrm{abs}}}
\newcommand \PerByteTxnSurcharge {T_{\Fee,b}}
$$

# Transaction Groups

A transaction **MAY** include a _group_ field (msgpack codec `grp`), a 32-byte hash
that specifies what _transaction group_ the transaction belongs to.

Informally, a transaction group is an _ordered_ list of transactions that **MUST**
all be confirmed _together_, in the _specified order_, and included in the _same
block_. If any transaction in the group fails to be confirmed, none of them will
be.

The _group_ field, in each transaction part of the same group, is set to the hash
representing a commitment to the entire group. This group hash is computed by creating
an ordered list of the hashes of all transactions in the group. When computing each
transaction’s hash for this purpose, its own _group_ field is omitted to avoid circular
dependency.

{{#include ../_include/styles.md:example}}
> A user wants to require transaction \\( A \\) to confirm _if and only if_ transactions
> \\( B \\) and \\( C \\) confirm in a certain order. The user performs the following
> procedure:
>
> 1. Specifies transactions' order: \\( [A, B, C] \\);
>
> 1. Computes the hashes of each transaction in the list (without their _group_
> field set): \\( [\Hash(A), \Hash(B), \Hash(C)] \\);
>
> 1. Hash them together in the specified order, getting the _group hash_:
> \\( G = \Hash([\Hash(A), \Hash(B), \Hash(C)]) \\);
>
> 1. Set the _group_ field of all the transactions to the _group hash_ (\\( G \\))
> _before_ signing them.

A _group_ **MAY** contain no more than \\( \MaxTxGroupSize \\) transactions.

More formally, when evaluating a block, the \\( i \\)-th and \\( i+1 \\)-th transactions
in the payset are considered to belong to the same _transaction group_ if the _group_
fields of the two transactions are equal and non-zero.

The block may now be viewed as an ordered sequence of _transaction groups_, where
each transaction group is a contiguous sublist of the payset consisting of one or
more transactions with equal _group_ field.

For each transaction group where the transactions have non-zero _group_, compute
the _group hash_ as follows:

- Take the hash of each transaction in the group, but with its _group_ field omitted.

- Hash this ordered list of hashes. More precisely, hash the canonical msgpack encoding
of a structure with a field `txlist` containing the list of hashes, using `TG` as
[domain separation prefix](../crypto/crypto-domain-separators.md).

If the _group hash_ of any transaction group in a block does not match the _group_
field of the transactions in that group (and that _group_ field is non-zero), then
the block is invalid.

Additionally, if a block contains a transaction group of more than \\( \MaxTxGroupSize \\)
transactions, the block is invalid.

Each transaction in a group requires a fee of \\( \MinTxnFee \\), plus a _size
surcharge_ for any field that exceeds its _basic_ size limit while remaining within
the corresponding _absolute_ limit. Each byte in excess of a basic limit adds a
surcharge of \\( \frac{\PerByteTxnSurcharge}{1{,}000{,}000} \\) of \\( \MinTxnFee \\).
Surcharges apply to:

- a transaction's [_note_](./ledger-transactions.md#note), for bytes beyond its
basic limit;

- an application call's [arguments](./ledger-txn-application-call.md#arguments), for
bytes beyond their basic total length;

- an application call's programs, for bytes beyond the basic combined program length
(see [Extra Program Pages](./ledger-txn-application-call.md#extra-program-pages));

- the group's logic signature programs, for bytes beyond a pooled free allowance of
\\( n \times \LogicSigMaxSize \\) bytes.

If the sum of the fees paid by the \\( n \\) transactions in a transaction group is
less than the sum of the fees they require (each transaction's \\( \MinTxnFee \\)
plus its size surcharges), then the block is invalid. There are two exceptions to
this fee requirement:

1. State Proof transactions require no fee;

1. Heartbeat transactions that set the
[_heartbeat challenge discount_](./ledger-txn-heartbeat.md#heartbeat-challenge-discount)
flag require \\( \MinTxnFee \\) less, provided the _heartbeat address_ was challenged
between \\( 100 \\) and \\( 200 \\) rounds ago, and has not proposed or heartbeat
since that challenge.

> Further explanation of this rule is found in [Heartbeat transaction semantics](./ledger-txn-semantics-heartbeat.md)
> section.

If the sum of the lengths of the boxes denoted by the box references in a transaction
group exceeds \\( \BytesPerBoxReference \\) times the total number of box references
in the transaction group, then the block is invalid. Call this limit the _I/O Budget_
for the group. Box references with an empty name are counted toward the total number
of references, but add nothing to the sum of lengths.

If the sum of the lengths of the boxes modified (by creation or modification) in
a transaction group exceeds the I/O Budget of the group at any time during evaluation
(see [Application Call transaction semantics](./ledger-txn-semantics-application.md)),
then the block is invalid.

Each logic signature _program_ **MUST NOT** exceed \\( \MaxAbsoluteLogicSigProgramSize \\)
bytes, and the sum of the lengths of all the logic signature _arguments_ in a transaction
group **MUST NOT** exceed the number of transactions in the group times
\\( \LogicSigMaxSize \\); otherwise the block is invalid. Logic signature _program_
bytes beyond a pooled free allowance of the same size are permitted, but incur a size
surcharge as described in the group fee requirement above.

Beyond the _group_ field, group minimum fee, group I/O Budget, and group logic sig
size checks, each transaction in a group is evaluated separately and **MUST** be
valid on its own, as described in the [Validity and State Changes](./ledger-validation.md)
section.

{{#include ../_include/styles.md:example}}
> An account with balance \\( 50 \\) ALGO could not spend \\( 100 \\) ALGO in transaction
> \\( A \\) and afterward receive \\( 500 \\) in transaction \\( B \\), even if
> transactions \\( A \\) and \\( B \\) are in the same group, because transaction
> \\( A \\) would overspend the account’s balance.
