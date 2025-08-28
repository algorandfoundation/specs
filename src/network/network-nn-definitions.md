$$
\newcommand \Peer {\mathrm{Peer}}
\newcommand \tag {\mathrm{tag}}
$$

# Network Definitions

Let us define a general `GossipNode` pseudo interface, which implements a set of
methods that should be available in any _network layer_ to provide all required
functionalities.

- `Start()`\
Initializes the network by setting up all required data structures, peer connections,
and listeners.

- `Stop()`\
Shuts down the network, closing all connections and performing garbage collection.

- `Address() -> string`\
Computes the address of the caller node, inside the specified network structure,
according to the network layer addressing (see the [addressing section](network-nn-addressing.md)).

- `Broadcast(tag protocolTag, data []byte, wait bool, except Peer)`\
Builds a message and sends a packet of data and protocol \\( \tag \\) to all connected
peers. Conceptually, it only excludes itself, although it could exclude any specific
\\( \Peer \\) using the `except` parameter. If `wait` is active, the call blocks
until the send is complete (allowing for synchronous message sending).

- `Relay(tag protocol.Tag, data []byte, wait bool, except Peer)`\
Similar to `Broadcast`, but semantically intended for message forwarding. The `except`
parameter explicitly identifies the message’s original sender, ensuring the data
is not relayed back to its source. This distinction is useful when implementing
relay logic, where the sender is extracted from the raw message metadata, if present.
In special cases, when a node simulates the reception of its own message for internal
processing, self-exclusion is bypassed, and the node includes itself in the relaying
logic. This helps ensure protocol components receive their own outputs when needed.

{{#include ../_include/styles.md:impl}}
> Relay [reference implementation](https://github.com/algorand/go-algorand/blob/ad67b95fcffe250af94de5d1365dd3b81b845f39/agreement/gossip/network.go#L155)

- `Disconnect(badnode Peer)`\
Forces disconnection from the given `badnode` \\( \Peer \\).

- `RequestConnectOutgoing(replace bool)`\
Initiates outgoing connections to new \\( \Peer \\), with the option to `replace`
the existing managed peer connections.

- `OnNetworkAdvance()`\
Notifies the network layer that the Agreement protocol has made _significant progress_.
While network health monitoring can detect message flow, it cannot ensure _protocol-level
advancement_. A node may reside within a fast, densely connected but _isolated_
partition, receiving messages quickly but missing those from outside. Therefore,
this function is triggered whenever the Agreement protocol observes a _certification-bundle_
or at least a _proposal-value_ for a new block, allowing the node to confidently
infer that the network is not partitioned.

{{#include ../_include/styles.md:impl}}
> Usage of `OnNetworkAdvace` in [reference implementation](https://github.com/algorand/go-algorand/blob/ad67b95fcffe250af94de5d1365dd3b81b845f39/node/impls.go#L87)

- `GetGenesisID() -> string`\
Returns the network-specific `genesisID`, a string indicating the kind of network
this node is connected to (see the Ledger [normative section](ledger.md#genesis-identifier)
for further details on this field).