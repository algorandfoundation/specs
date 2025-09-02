$$
\newcommand \LogicSig {\mathrm{LSig}}
\newcommand \LogicSigMaxSize {\LogicSig_{\max}}
\newcommand \LogicSigMaxCost {\LogicSig_{c,\max}}
$$

# Execution Environment for Logic Signatures

Logic Signatures execute as part of testing a proposed transaction to see if it is
valid and authorized to be committed into a block. If an authorized program executes
and finishes with a single non-zero `uint64` value on the Stack, then that program
has validated the transaction it is attached to.

The program has access to data from the transaction it is attached to (`txn` opcode),
any transactions in a transaction group it is part of (`gtxn` opcode), and a few global
values like consensus parameters (`global` opcode).

Some _arguments_ may be attached to a transaction being validated by a program. Arguments
are an array of byte strings. A common pattern would be to have the key to unlock
some contract as an argument.

Be aware that Logic Signature arguments are recorded on the blockchain and publicly
visible when the transaction is submitted to the network, even before the transaction
has been included in a block. These arguments are _not_ part of the transaction ID
nor of the [transaction group]() hash (`grp`). They also cannot be read from other
programs in the group of transactions.

## Bytecode Size

The size of a Logic Signature is defined as the length of its bytecode plus the length
of all its arguments. The sum of the sizes of all Logic Signatures in a group **MUST
NOT** exceed \\( \LogicSigMaxSize \\) bytes times the number of transactions in the
group[^1].

## Opcode Budget

Each opcode has an associated cost, usually \\( 1 \\), but a few slow operations
have higher costs.

Before Version 4, the program's cost was estimated as the _static sum_ of all the
opcode costs in the program (whether they were actually executed or not).

Beginning with Version 4, the program's cost is tracked dynamically while being
evaluated. If the program exceeds its opcode budget, it fails.

The total program cost of all Logic Signatures in a group **MUST NOT** exceed \\( \LogicSigMaxCost \\)
times the number of transactions in the group[^1].

{{#include ../_include/styles.md:impl}}
> Opcode budget tracker [reference implementation](https://github.com/algorand/go-algorand/blob/7e562c35b02289ca95114b4b3a20a7dc2df79018/data/transactions/logic/eval.go#L1491).

## Modes

A program can either authorize some _delegated action_ on a normal signature-based
or multisignature-based account or be wholly in charge of a _contract account_.

### Delegated Signature Mode

If the account has signed the program (by providing a valid [Ed25519](../crypto/crypto-ed25519.md)
signature or valid multisignature for the authorizer address on the string `Program`
concatenated with the program bytecode) then, if the program returns `True`, the
transaction is authorized as if the account had signed it. This allows an account
to hand out a signed program so that other users can carry out delegated actions
that are approved by the program. Note that Logic Signature arguments are _not_
signed.

### Contract Account Mode

If the [SHA-512/256](../crypto/crypto-sha512.md) hash of the program (prefixed by
`Program`) is equal to the authorizer address of the transaction sender, then this
is a contract account wholly controlled by the program. No other signature is necessary
or possible. The only way to execute a transaction against the contract account is
for the program to approve it.

---

[^1]: See the [Ledger parameters section]().
