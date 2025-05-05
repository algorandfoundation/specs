$$
\newcommand \Next {\mathit{next}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
$$

# Examples of Protocol Runs

The following section presents three examples of valid protocol runs, going from
simple to more complex agreement attempts, by adding partition scenarios that involve
recovery stages.

The run examples are named from “best” to “worst” respectively:

- Vanilla Run: agreement is achieved at the first attempt,
 
- Jalapeño Run: agreement is achieved with a \\( \Next \\) recovery procedure,

- Habanero Run: agreement is achieved with \\( \Late, \Redo, \Down \\) fast recovery
procedure.

Besides being the simplest, the _Vanilla Run_ is the most common case, as infrastructure
failures are extremely rare. However, the partition scenarios in the _Jalapeño Run_
and _Habanero Run_ shed light on the recovery mechanisms.

## Initial Context

All three scenarios share the following _initial context_ and are played by the
node \\( \bar{N} \\).

A _genesis block_ was generated. Algorand has been running for a while with a set
of nodes and accounts, and several blocks have already been generated.

The network is now at round \\( r - 1 \\) (with \\( r >> 2 \\)), meaning that
\\( r - 1 \\) blocks have been generated and confirmed on the blockchain.

Moreover, the node \\( \bar{N} \\) has:

- Received some transactions,

- Verified them to be correctly signed by Algorand accounts,

- Validated them according to Ledger and node context,

- Added them to its \\( \TP \\) (see [normative section](./ledger.md#transaction-pool)),

- Relayed them to other nodes.

For this section, we assume that all players behave according to protocol and are
in sync, that is:

- The context \\( (r, p, s) \\) for all nodes is the same,

- Nodes’ internal clocks are synchronized.