$$
\newcommand \Peer {\mathrm{Peer}}
\newcommand \tag {\mathrm{tag}}
$$

# Network Definitions

Let us define a general `GossipNode` pseudo interface, which implements a set of
methods that should be available in any _network layer_ to provide all required
functionalities.

- `Start()`: Build a network, initializing all necessary data structures, connections, and
listeners.

- `Stop()`: Closes all connections and garbage collects.

- `Address() -> string`: Computes the address of the caller node, inside the specified
network structure, according to the network layer addressing (see the [addressing section](./network-nn-addressing.md)).

- `Broadcast(tag protocolTag, data []byte, wait bool, except Peer)`: builds a message
and sends a packet of data and protocol \\( \tag \\) to all connected peers. Conceptually,
it only excludes itself, although it could exclude any specific \\( \Peer \\) using
the `except` parameter. The `wait` flag may block the call, allowing for synchronous
message sending.

- `Relay(tag protocol.Tag, data []byte, wait bool, except Peer)`: Similar to `Broadcast()`,
but it excludes a specific \\( \Peer \\), which should be the original sender of
the data.

- `Disconnect(badnode Peer)`: Disconnects from the given `badnode` \\( \Peer \\).

- `RequestConnectOutgoing(replace bool)`: Performs \\( \Peer \\) outgoing connections,
with the option to replace the existing managed peer connections.

- `OnNetworkAdvance()`: Notifies the network library that the Agreement protocol
was able to make notable progress. The network health monitoring is not enough to
guarantee protocol advancements. The node could be part of a densely connected network
partition, where all incoming messages arrive quickly, but protocol messages outside
the partition may never be observed. Thus, this function is called whenever a certification bundle for a new block (or at least a proposal-value) has been observed by the agreement protocol, where we can strongly assume that the network is not in a damaging partition state.

- `GetGenesisID() -> string`: Returns the network-specific `genesisID`, a string
indicating the kind of network this node is connected to (see the Ledger [normative section](ledger.md#genesis-identifier)
for further details on this field).