# Algod Daemon

The main daemon running in an Algorand Node is called `algod`.

It is responsible for providing access to core blockchain data and functionality.
This includes transaction details, account balances, smart contract state, and other
node-level information.

The `algod` REST API is used to **GET**:

- Node info (e.g., `/genesis`, `/health`, `/ready`, `/status`, etc.),

- Account info (e.g., `/accounts/{address}`, etc.),

- App info (e.g., `/applications/{application-id}`, etc.),

- ASA info (e.g., `/assets/{asset-id}`, etc.),

- Blocks info (e.g., `/blocks/{round}`, etc.),

- Other ancillary information about the [Ledger](../../ledger/ledger-overview.md)
and pending transactions in the [Transaction Pool](../../ledger/non-normative/ledger-nn-txpool.md).

The `algod` REST API is used to **POST**:

- Synchronization commands (e.g., `/ledger/sync/{round}`, `/catchup/{catchpoint}`, etc.),

- Transactions (e.g., `/transactions`,  `/transactions/simulate`, etc.),

- Consensus commands (e.g., `/participation`,  `/participation/generate/{address}`, etc.),

- AVM Compiler commands (e.g., `/teal/compile`,  `/teal/disassemble`, etc.),

- Other ancillary dev commands.

> Tasks involving the management and the usage of private keys are handled by a
> separate daemon, called _Key Management Daemon_ (`kmd`).

## Authorization

Some `algod` endpoints perform sensitive actions that require authorization.

The `X-Algo-API-Token` header is used to authenticate requests to the private `algod`
endpoints.

By default, the API can be configured with two separate `X-Algo-API-Token` values:

- The `algod.token` is used to access public `algod` endpoints.

- The `admin.algod.token` is used to access private `algod` endpoints.

## Endpoints

Each `algod` endpoint path has two _tags_ to separate endpoints into groups:

- Tag 1: `public` (use the `algod.token`) or private (use `algod.admin.token`),

- Tag 2: `participating`, `nonparticipating`, `data`, or `experimental`.

{{#include ../../_include/styles.md:impl}}
> Each endpoint implements a [`Handler`](https://github.com/algorand/go-algorand/blob/cec401cc6127c6af742685e4c39e71389586c595/daemon/algod/api/server/v2/handlers.go)
> and a [`Client`](https://github.com/algorand/go-algorand/blob/cec401cc6127c6af742685e4c39e71389586c595/daemon/algod/api/client/restClient.go).

## Constants

The following constants define key limits and default behaviors for various `algod`
API endpoints.

These values serve as practical defaults for most use cases. Developers implementing
their own tooling or integrations can use these as general guidelines.

| Constant              | Value                      | Description                                                                                       |
|-----------------------|----------------------------|---------------------------------------------------------------------------------------------------|
| `MaxTealSourceBytes`  | 524,288 bytes              | Maximum allowed size for TEAL source code in API requests.                                        |
| `MaxTealDryrunBytes`  | 1,000,000 bytes            | Maximum allowed size for dryrun simulation requests.                                              |
| `MaxAssetResults`     | 1,000                      | Maximum number of assets returned in a single call to `/v2/accounts/{address}/assets`.            |
| `DefaultAssetResults` | 1,000                      | Default number of assets returned if no explicit limit is provided (up to `MaxAssetResults`).     |
| `WaitForBlockTimeout` | 1e+10 nanoseconds (1 min.) | Timeout duration for the `WaitForBlock` endpoint when waiting for the next block to be generated. |
