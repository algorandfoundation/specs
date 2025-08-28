$$
\newcommand \tag {\mathrm{tag}}
\newcommand \MessageHandler {\mathrm{MH}}
\newcommand \ForwardingPolicy {\mathrm{ForwardingPolicy}}
\newcommand \InMsg {\ast\texttt{M}}
\newcommand \OutMsg {\texttt{M}\ast}
$$

# Message Handlers

Each incoming message \\( \InMsg \\) is deferred to the correct _message handler_
\\( \MessageHandler_t(\InMsg) \\) given its protocol \\( tag \\) (\\( t \\)). 

The message handler then processes the message and decides on a \\( \ForwardingPolicy \\)
(see the [definition](network-nn-notation.md#messages-incoming-and-outgoing) of
this data type for further details).

A message handler \\( \MessageHandler_t(\InMsg) \\) contains the logic for handling
incoming messages.

The following is the list of registered message handlers defined in the reference
implementation, ordered by \\( tag \\):

- `AV` for Agreement Vote:
   - [Handler's implementation starting point](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/agreement/gossip/network.go#L99).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/agreement/gossip/network.go#L89).

- `MI` for Message of Interest: 
   - [Context](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsPeer.go#L633).
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsPeer.go#L714).

- `MS` for Message Digest Skip:
   - [Context](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsPeer.go#L669).
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsPeer.go#L760).

- `NP` for Net Priority Response: 
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/netprio.go#L35).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsNetwork.go#L710).

- `NI` for Network ID Verification:
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/netidentity.go#L405).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsNetwork.go#L702).

- `PP` for Proposal Payload:
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/agreement/gossip/network.go#L103).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/agreement/gossip/network.go#L89).

- `SP` for State Proof Signature:
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/stateproof/builder.go#L312).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/stateproof/worker.go#L116).

- `TS` for Topic Message Response:
   - [Harcoded implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsPeer.go#L641).

- `TX` for Transaction:
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/data/txHandler.go#L735).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/data/txHandler.go#L262).

- `UE` for Unicast Catchup Request:
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/rpcs/blockService.go#L293).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/rpcs/blockService.go#L169).

- `VB` for Vote Bundle:
   - [Handler's implementation](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/agreement/gossip/network.go#L110).
   - [Handler's registration](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/agreement/gossip/network.go#L89).

- Unrecognized Tag case (a special tag value to account for transmission errors or adversarial behavior):
   - [Context](https://github.com/algorand/go-algorand/blob/0bc3d7e4750db8f98c5dd66f3377147532021c62/network/wsPeer.go#L679).

In general, after a preliminary validation and a series of computations, the produced
output is an _outgoing message_ \\( \OutMsg \\).

Internally, \\( \MessageHandler_t(\InMsg) \\) routes data to the corresponding component
of the node (e.g., "Agreement" for protocol messages, "Transaction Pool" for transactions,
etc.).

> Refer to the normative section of each node component to see how these messages
> are processed and their impact on the node’s overarching state.

{{#include ../_include/styles.md:impl}}
> In the reference implementation, a single entry point callback `Notify()` is used
> to monitor an outgoing connection whenever a message is received. This function
> then sends the message metadata to the appropriate processing stage of the `PerformanceMonitor`.
>
> Usage in [Relay Network](https://github.com/algorand/go-algorand/blob/7e562c35b02289ca95114b4b3a20a7dc2df79018/network/wsPeer.go#L626).
>
> Usage in [P2P Network](https://github.com/algorand/go-algorand/blob/7e562c35b02289ca95114b4b3a20a7dc2df79018/network/p2p/p2p.go#L187).