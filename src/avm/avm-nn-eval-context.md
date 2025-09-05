$$
\newcommand \EC {\mathrm{EC}}
$$

# Evaluation Context

An _Evaluation Context_ \\( \EC \\) is a core runtime structure used during AVM
program execution. It maintains all the state and metadata required to evaluate
a program within a transaction (group) scope.

Below is a simplified interface example for the _Evaluation Context_, inspired by
the `go-algorand` reference implementation.

## Static Properties

These \\( \EC \\) methods expose context information that remains fixed throughout
the execution of a specific transaction within the group:

- `RunMode() -> {SmartSignature, Application}`\
Returns whether the context is for a _stateless_ LogicSig or a _stateful_ Application.

- `GroupIndex() -> int`\
Returns the index of the current transaction within its group.

- `PastScratch(past_group_index int) -> map[int, StackValue]`\
Retrieves the final scratch space of a previous transaction in the same group, by index.

- `GetProgram() -> []byte`\
Returns the bytecode of the currently executing program \\( \EC_P \\).

Additional program-related accessors:

- `getCreatorAddress() -> []byte` — Gets the Creator address of the Application.

- `AppID() -> uint64` — Returns the ID of the current Application.

- `ProgramVersion() -> uint64` — AVM version for the executing program.

- `GetOpSpec() -> OpSpec` — Returns the [Opcode Specification](./avm-appendix-a.md)
for the current opcode.

- `begin(program []byte) -> bool` — Verifies whether the given program version is
supported and executable in the current context.

## Dynamic Properties

These \\( \EC \\) reflect the evolving state of execution, may change as the transaction
executes.

- `PC() -> int`\
Returns the current program counter of the executed application \\( \EC_{pc} \\).

### Budget and Cost Tracking

The _opcode budget_ limits the AVM program execution.

- `Cost() -> int`\
Returns the total `opcode` execution cost so far.

- `remainingBudget() -> int`\
Returns the remaining `opcode` budget available for execution.

## Inner Transactions

- `InnerTxnPending() -> []Transaction`\
Returns inner transactions that are queued but not yet submitted.

- `addInnerTxn()`
Adds an inner transaction to the group. Validates constraints such as group size,
fees, and sender address. Used by the `itxn_begin` and `itxn_next` opcodes.

## Program Evaluation

- `step()`
The core _transition function_ that advances execution one `opcode` at a time. See
the dedicated [non-normative section](./avm-nn-transition-function.md) for further
details.

## Ledger Interaction

These functions expose the current Ledger context to the AVM:

- `getRound() -> uint64`
Returns the current [round](../ledger/ledger-round.md) from the Ledger.

- `getLatestTimestamp() -> uint64`
Returns the [latest timestamp](../ledger/ledger-timestamp.md) of the most recently
committed block.

### Prefetched Ledger Accessors

- `accountRetrieval()`, `assetRetrieval()`, `boxRetrieval()`, `applicationRetrieval()`\
Provide runtime access to prefetched Ledger data (e.g., foreign accounts, apps, boxes,
and assets) as declared in the transaction’s foreign arrays.
