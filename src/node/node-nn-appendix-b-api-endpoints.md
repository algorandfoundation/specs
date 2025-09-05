# 🔗 API & Endpoints

---

| Parameter Name    | Default Value | Introduced in Version | Last Updated in Version |
|-------------------|:-------------:|:---------------------:|:-----------------------:|
| `EndpointAddress` | `127.0.0.1:0` |           0           |            0            |

**Description:**

Configures the address where the node listens for [REST API](./node-nn-api.md) calls.
It may hold an `IP:port` pair or just a `port`. The value `127.0.0.1:0` and `:0`
will attempt to bind to port `8080` if possible; otherwise, it will bind to a random
port. Any other address ending in `:0` will bind directly to a random port.

---

| Parameter Name                     | Default Value | Introduced in Version | Last Updated in Version |
|------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnablePrivateNetworkAccessHeader` |    `false`    |          35           |           35            |

**Description:**

Responds to Private Network Access preflight requests sent to the node. Useful when
a public website is trying to access a node hosted on a Local Network.

---

| Parameter Name           | Default Value | Introduced in Version | Last Updated in Version |
|--------------------------|:-------------:|:---------------------:|:-----------------------:|
| `RestReadTimeoutSeconds` |     `15`      |           4           |            4            |

**Description:**

Defines the maximum duration (in seconds) the node’s [API server](./node-nn-algod.md#endpoints)
will wait to read the request body for an incoming HTTP request. The request will
be aborted if the body is not fully received within this time frame.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `RestWriteTimeoutSeconds` |     `120`     |           4           |            4            |

**Description:**

Defines the maximum duration (in seconds) the node’s [API server](./node-nn-algod.md#endpoints)
allows writing the response body back to the client. The connection is closed if
the response is not sent within this time frame.

---

| Parameter Name                        | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------------------|:-------------:|:---------------------:|:-----------------------:|
| `BlockServiceCustomFallbackEndpoints` | Empty string  |          16           |           16            |

**Description:**

The comma-delimited list of endpoints that the [block](../ledger/ledger-block.md)
service uses to redirect the HTTP requests if it does not have the round. The block
service will return `404` (StatusNotFound) if empty.

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `RestConnectionsSoftLimit` |    `1024`     |          20           |           20            |

**Description:**

Defines the maximum number of active requests the API server can handle. When the
number of HTTP connections to the [REST API](./node-nn-algod.md#endpoints) exceeds
this soft limit, the server returns HTTP status code `429` (Too Many Requests).

---

| Parameter Name             | Default Value | Introduced in Version | Last Updated in Version |
|----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `RestConnectionsHardLimit` |    `2048`     |          20           |           20            |

**Description:**

Defines the maximum number of active connections the API server will accept before
closing requests with no response.

---

| Parameter Name              | Default Value | Introduced in Version | Last Updated in Version |
|-----------------------------|:-------------:|:---------------------:|:-----------------------:|
| `MaxAPIResourcesPerAccount` |   `100000`    |          21           |           21            |

**Description:**

Sets the maximum total number of resources (created assets, created apps, asset holdings,
and application local state) allowed per account in `AccountInformation` REST API
responses before returning a `400` (Bad Request). If set to `0`, there is no limit.

---

| Parameter Name            | Default Value | Introduced in Version | Last Updated in Version |
|---------------------------|:-------------:|:---------------------:|:-----------------------:|
| `MaxAPIBoxPerApplication` |   `100000`    |          25           |           25            |

**Description:**

Defines the maximum number of boxes per application that will be returned in `GetApplicationBoxes`
[REST API](./node-nn-algod.md#endpoints) responses.

---

| Parameter Name          | Default Value | Introduced in Version | Last Updated in Version |
|-------------------------|:-------------:|:---------------------:|:-----------------------:|
| `EnableExperimentalAPI` |    `false`    |          26           |           26            |

**Description:**

Enables [experimental API endpoint](./node-nn-algod.md#endpoints).

> These endpoints have no guarantees in terms of functionality or future support.

---

| Parameter Name   | Default Value | Introduced in Version | Last Updated in Version |
|------------------|:-------------:|:---------------------:|:-----------------------:|
| `DisableAPIAuth` |    `false`    |          30           |           30            |

**Description:**

Disables authentication for public (non-admin) [API endpoints](./node-nn-algod.md#endpoints).

---
