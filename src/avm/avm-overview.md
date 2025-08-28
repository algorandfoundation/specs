# Algorand Virtual Machine Overview

The Algorand Virtual Machine (AVM) is a _bytecode-based Turing-complete stack
interpreter_ that executes programs associated with Algorand transactions.

_TEAL_ is an assembly language syntax for specifying a program that is ultimately
converted to AVM bytecode.

The AVM approves or rejects transactions’ effects on the [Ledger](./ledger.md) state.

![AVM Overview](../_images/avm-overview.svg "AVM Overview")