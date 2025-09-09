# Appendix B - Packet Examples

The following is a collection of network packet examples with different protocol
tags (see [definition](network-nn-notation.md#protocol-tags)).

Packets are decoded from `msgpakc` to `JSON`, with:

- Values in `hex` format,

- Algorand addresses decoded according to specification,

- Transaction notes decoded in `UTF-8`.

> Examples of `msgpack` [network packets](https://github.com/algorandfoundation/specs/tree/develop/src/_include/msgs).
> For further details about Algorand canonical encoding, refer to the `msgpack`
> [normative section](../../crypto/crypto.md#canonical-msgpack).

## Agreement Vote (`AV`)

```json
{{#include ../../_include/msgs/AV/av-1.json}}
```

## Message of Interest (`MI`)

To be added.

## Message Digest Skip (`MS`)

To be added.

## Network Priority Response (`NP`)

To be added.

## Network ID Verification (`NI`)

To be added.

## Proposal Payload (`PP`)

To be added.

## State Proof (`SP`)

```json
{{#include ../../_include/msgs/SP/sp-1.json}}
```

## Topic Message Response (`TS`)

To be added.

## Transaction (`TX`)

### Application Call

```json
{{#include ../../_include/msgs/TX/tx-1.json}}
```

### Asset Transfer

```json
{{#include ../../_include/msgs/TX/tx-2.json}}
```

### Asset Opt-In

```json
{{#include ../../_include/msgs/TX/tx-4.json}}
```

## Unicast Catch-up Request (`UE`)

To be added.

## Vote Bundle (`VB`)

To be added.
