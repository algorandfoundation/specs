$$
\newcommand \Peer {\mathrm{Peer}}
\newcommand \WS {\mathrm{WS}}
\newcommand \PtoP {\mathrm{P2P}}
\newcommand \HYB {\mathrm{HYB}}
\newcommand \Tag {\mathrm{tag}}
\newcommand \InMsg {\ast\texttt{M}}
\newcommand \OutMsg {\texttt{M}\ast}
\newcommand \MessageHandler {\mathrm{MH}}
\newcommand \MessageValidatorHandler {\mathrm{MV}_h}
\newcommand \ForwardingPolicy {\mathrm{ForwardingPolicy}}
$$

# Notation and Data Structures

## Peer

We define a \\( \Peer \\) as a generic network actor.

This construct provides a way to refer to nodes indistinctly and keep track of all
neighbors with inbound or outbound connections that may relay or broadcast messages.

Each of \\( \Peer \\) represents a fully operational Algorand node with a working _network layer_.

A specific \\( \Peer_t \\), with \\( t \in \\{\WS, \PtoP, \HYB\\} \\) is a \\( \Peer \\)
whose _network layer_ implements a specific type of network.

A \\( \Peer \\) has all the necessary contents to communicate with the node it represents
(the HTTP client, the URL representing the node, and extra metadata necessary to maintain an active connection).

{{#include ../_include/styles.md:impl}}
> Peer struct [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/wsPeer.go#L177).

## Protocol Tags

A protocol \\( tag \\) is a short 2-byte string that marks a message type.

A \\( tag \\) should not contain a comma, as lists of tags are modeled by comma-separated
tag handles.

Protocol tags play a key role in routing messages to appropriate handlers and incorporating
priority notions.

Conceptually, a \\( tag \\) determines the purpose of an incoming data packet inside
the overarching protocol.

Possible values for the \\( tag \\) type are:

|  TAG   | DESCRIPTION                                                                                                                                                                                                              |
|:------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `"AV"` | Agreement Vote (a protocol vote, see [normative section](../abft/abft.md#votes)).                                                                                                                                              |
| `"MI"` | Message of Interest.                                                                                                                                                                                                     |
| `"MS"` | Message Digest Skip. A request by a \\( \Peer \\) to avoid sending messages with a specific hash.                                                                                                                        |
| `"NP"` | Network Priority Response.                                                                                                                                                                                               |
| `"NI"` | Network ID Verification.                                                                                                                                                                                                 |
| `"PP"` | Proposal Payload (see [normative section](../abft/abft.md#proposals)).                                                                                                                                                         |
| `"SP"` | State Proof Signature (see [normative section](../crypto/crypto.md#signature-format)).                                                                                                                                           |
| `"TS"` | Topic Message Response.                                                                                                                                                                                                  |
| `"TX"` | Transaction (see [normative section](../ledger/ledger.md#transactions)).                                                                                                                                                         |
| `"UE"` | Unicast Catchup Request. Messages used to request blocks by a \\( \Peer \\) when serving blocks for the catchup service (see Algorand Infrastructure [non-normative section](./infrastructure-overview.md#node-catchup). |
| `"VB"` | Vote Bundle (a protocol bundle, see [normative section](../abft/abft.md#bundles)).                                                                                                                                             |
| `"pi"` | Ping[^1].                                                                                                                                                                                                                |
| `"pj"` | Ping Reply[^1].                                                                                                                                                                                                          |

Agreement Vote (`"AV"`) and Proposal Payload (`"PP"`) are the only ones considered
of _“high priority”_. This means they impact internal ordering in the broadcast
queue, as a priority function discriminates against them.

{{#include ../_include/styles.md:impl}}
> High priority tags [reference implementation](https://github.com/algorand/go-algorand/blob/ce9b2b0870043ef9d89be9ccf5cda0c42e3af70c/network/gossipNode.go#L140C6-L140C21).

Messages tagged with `AV` or `PP` get pushed into a separate high-priority queue.

{{#include ../_include/styles.md:impl}}
> High priority queue [reference implementation](https://github.com/algorand/go-algorand/blob/ce9b2b0870043ef9d89be9ccf5cda0c42e3af70c/network/wsNetwork.go#L388).

Every \\( tag \\) has a corresponding set of handlers, described in detail in the
[Message Handlers section](#message-handlers).

## Messages (In and Out)

Algorand nodes communicate inside a _network layer_ exchanging _messages_.

A _message_ is a data structure with a payload (a set of bytes) and metadata that
serves to authenticate, route, and interpret messages received or sent out.

We define a deserializable object _incoming message_ \\( \InMsg \\), as an object
representing a message from some \\( \Peer \\) in the same network layer.

An incoming message \\( \InMsg \\) provides the following fields:

- `sender`, an identified \\( \Peer \\) indicating the sending party,

- `protocolTag`, a tag (see [above](#protocol-tags)), used to identify univocally
the message type and route it to the correct message handler to produce an outgoing
message,

- `payload`, an array of bytes representing the content of the message. See the
[parameters section](network-nn-parameters.md) for details on size constraints,

- `network`, the type of network from which the message originated
([Relay Network](#websocket-network-definition) or [P2P Network](#p2p-network-definition)),

- `received`, a 64-bit integer representing the reception time of this message
(expressed in nanoseconds since the `epoch`).

When an incoming message \\( \InMsg \\) is received, and the appropriate message handler
has processed it, an outgoing message is produced.

We define a deserializable object _outgoing message_ \\( \OutMsg \\), as an object
representing a message from some \\( \Peer \\) in the network.

An outgoing message \\( \OutMsg \\) provides the following fields:

- `protocolTag`, a tag (see [above](#protocol-tags)). Similarly to incoming messages,
it marks how the receiving \\( \Peer \\) should interpret and handle the produced
message,

- `payload`, an array of bytes representing the content of the message. See the
[parameters section](network-nn-parameters.md) for details on size constraints,

- `topics`, a list of key-value pairs (of the form `string -> bytes[]`) for topics
this message serves, used in certain specific scenarios (mainly for the catch-up
service). The possible topic keys are:

  - General purpose:
    - `"RequestHash"`, responding to requests for specific topics,
    - `"Error"`, passing an error message on a specific topic request.

  - Block service:
    - `"roundKey"`, the block round-number topic-key in the request,
    - `"requestDataType"`, the data-type topic-key in the request (e.g., `block`, `cert`, `blockAndCert`),
    - `"blockData"`, serving block data,
    - `"certData"`, serving block certificate data,
    - `"blockAndCert"`, requesting block and certificate data,
    - `"latest"`, serving the latest round.

- `disconnectReason`, only when the `Action` calls for a `Disconnect` as a \\( \ForwardingPolicy \\)
(see below). An enumeration of the reasons to disconnect from a given \\( \Peer \\)
(message sender) may be found right below.

A \\( \ForwardingPolicy \\) is an enumeration, indicating what action should be taken for
a given outgoing message \\( \OutMsg \\). It may take any of the following values:

- `Ignore`, to discard the message (don’t forward),

- `Disconnect`, to disconnect from the \\( \Peer \\) that sent the message \\( \OutMsg \\)
which returned this response,

- `Broadcast`, to forward this message to everyone (except the original sender \\( \Peer \\)),

- `Respond`, to reply to the sender \\( \Peer \\) directly,

- `Accept`, to accept the message for further processing after successful validation.

When an incoming message \\( \InMsg \\) is received, a handler function is called
according to its type. The message handler processes the message according to the
`protocolTag`, and produces an outbound message \\( \OutMsg \\) with information
on how to proceed further.

## Message Handlers

We define a _message handler_ \\( \MessageHandler_t(\InMsg) \\) as a function that
takes an incoming message as input and transforms it into an outgoing message.

$$
\MessageHandler_t(\InMsg) = \OutMsg
$$

where \\( t \\) denotes a \\( tag \\)-specific handler function (according to the
input inbound message `protocolTag`).

We define a _message validator handler_ \\( \MessageValidatorHandler(\InMsg) \\)
as a function that performs synchronous validation of a message _before_ processing
it with the \\( \MessageHandler_t(\InMsg) \\) functions.

The prototype of message validator handlers is similar to regular handlers.

{{#include ../_include/styles.md:impl}}
> The reference implementation defines a helper function, `Propagate(msg IncomingMessage)`,
> representing the prevalent case of a message handler re-propagating an incoming
> message \\( \InMsg \\). Internally, it creates an outgoing message \\( \OutMsg \\),
> with the same data as the received message and the action to `Broadcast`.
>
> ```go
> func Propagate(msg IncomingMessage) OutgoingMessage {
>  return OutgoingMessage{Action: Broadcast, Tag: msg.Tag, Payload: msg.Data, Topics: nil}
> }
> ```

---

[^1]: Removed in `go-algorand` 3.2.1., included for completeness.
