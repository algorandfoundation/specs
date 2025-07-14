$$
\newcommand \Asset {\mathrm{Asa}}
$$

# Asset Transfer Transaction

## Fields

An _asset transfer_ transaction additionally has the following fields:

- The _asset ID_ \\( \Asset_\mathrm{xfer,ID} \\), encoded as msgpack field `xaid`,
is a 64-bit unsigned integer that identifies the asset being transferred.

- The _asset amount_ \\( \Asset_a \\), encoded as msgpack field `aamt`, is an **OPTIONAL**
64-bit unsigned integer that indicates the number of _asset units_ being transferred.

> If the _asset amount_ is omitted (\\( \Asset_a = 0 \\)), the number of _asset units_
> transferred is zero.

- The _asset sender_ \\( \Asset_I \\), encoded as msgpack field `asnd`, is the **OPTIONAL**
32-byte address that identifies the source address for the asset transfer (non-zero
if the transaction is a _clawback_).

> If the _asset sender_ is omitted (\\( \Asset_I = 0 \\)), the source address of
> the asset transfer is the _sender_ of the transaction.

- The _asset receiver_ \\( \Asset_{I^\prime} \\), encoded as msgpack field `arcv`,
is the 32-byte address that identifies the destination address for the asset transfer.

- The _asset close to address_ \\( \Asset_{I_0}\\), encoded as msgpack field `aclose`,
is an **OPTIONAL** 32-bytes address that collects all remaining _asset units_ in
the _sender_ account _after_ the transfer.

> If the _asset close to address_ is omitted (\\( \Asset_{I_0}\\)), the field has
> no effect.

## Semantic

TODO

## Validation

TODO