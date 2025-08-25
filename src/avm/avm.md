# The Algorand Virtual Machine (AVM) and TEAL.

The AVM is a bytecode-based stack interpreter that executes programs
associated with Algorand transactions.

The Algorand Transaction Execution Approval Language (TEAL) is an assembly language
syntax for specifying a program that is ultimately converted to AVM bytecode.

These programs can be used to check the parameters of the transaction and approve
the transaction as if by a signature. This use is called a _Logic Signature_. Starting
with AVM Version 2, these programs may also execute as _Smart Contracts_, which are
often called _Applications_. Contract executions are invoked with explicit _application
call_ transactions.

_Logic Signatures_ have read-only access to the transaction they are attached to,
the other transactions in their transaction group, and a few global values. In addition,
_Applications_ have access to limited state that is global to the application, per-account
local state for each account that has opted-in to the application, and additional
per-application arbitrary state in named _boxes_.

For both types of program, approval is signaled by finishing with the stack containing
a _single non-zero_ `uint64` value, though `return` can be used to signal an early
approval which approves based only upon the top stack value being a non-zero `uint64`
value.