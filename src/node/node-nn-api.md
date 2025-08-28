# API

This section provides a non-normative overview of the Algorand Node REST APIs.

It is intended to help readers understand how these systems work and how they interface
with the node’s internal components.

The typical lifecycle of an REST API call to the Algorand Node can be broken down
into three phases:

- **Decoding phase** – the incoming request and its data are parsed and transformed
into a format suitable for internal use.

- **Handling phase** – the request is processed by invoking the appropriate internal
node components.

- **Response phase** – a response object is assembled and, when applicable, includes
encoded data to return to the caller.

Currently, API calls accept and return data in either [JSON](https://ecma-international.org/publications-and-standards/standards/ecma-404/)
or [MessagePack](https://github.com/msgpack/msgpack/blob/master/spec.md) format.

A running Algorand Node includes two primary daemons with their REST API:

- `algod` – handles consensus, block processing, submits transactions, and main
node operations.

- `kmd` – securely manages key storage and wallet-related functionality.

## OpenAPI Schema and Endpoint Code Generation

The `daemon/algod/api` directory within `go-algorand` contains an [OpenAPI v2](https://swagger.io/specification/v2/)
specification.

> Due to limited tool support for OpenAPI v3, both v2 and v3 specifications are
> maintained.

{{#include ../_include/styles.md:impl}}
> The endpoints’ code is automatically generated from this specification using
> [`oapi-codegen`](https://github.com/deepmap/oapi-codegen).
>
> - `algod.oas2.json` [specification file](https://github.com/algorand/go-algorand/blob/6f65ab1c290d953ff8132025088fd9f1af3baf4e/daemon/algod/api/algod.oas2.json).