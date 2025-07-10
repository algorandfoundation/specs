$$
\newcommand \Asset {\mathrm{Asa}}
$$

# Asset Configuration Transaction

## Fields

An _asset configuration_ transaction additionally has the following fields:

- The _asset ID_ \\( \Asset_\mathrm{cfg,ID} \\), encoded as msgpack field `caid`,
is a 64-bit unsigned integer that identifies the asset being configured. If the
_asset ID_ is omitted (zero), this transaction is _creating_ an asset.

- The _asset parameters_, encoded as a struct under msgpack field `apar`, is a structure
of parameters for the asset being configured. If _asset parameters_ are omitted
(struct of zero values), this transaction is _deleting_ the asset.

## Validation

TODO

## Semantic

TODO