# Appendix A - External Network Libraries

## `gorilla`

Algorand uses a [fork](https://github.com/algorand/websocket) of [gorilla websocket](https://github.com/gorilla/websocket)
(`v1.4.2`), to implement the Relay Network.

Relevant changes:

- Header size and read limits,
  - `connection.ReadMessage()` [is marked as unsafe](https://github.com/gorilla/websocket/compare/main...algorand:websocket:master#diff-4f427d2b022907c552328e63f137561f6de92396d7a6e8f6c2ea1bcf0db52654R1176)
  to avoid explosively compressed messages.

- Server is `TLSServer`,

- Message compression,

- Mutexes for multithreading,

- Connection closing without flushing, and a thread flusher,

- Tests and benchmark over additions.

> Further details refer to the [fork](https://github.com/gorilla/websocket/compare/main...algorand:websocket:master).

## `libp2p`

Algorand uses [go-libp2p library](https://github.com/libp2p/go-libp2p) (building
from the `latest` release), to implement the Peer-to-Peer network.

> See `libp2p` [specifications](https://github.com/libp2p/specs) for detailed documentation
> on this external package.
