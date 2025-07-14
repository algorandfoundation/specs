$$
\newcommand \Asset {\mathrm{Asa}}
$$

# Asset Freeze Transaction

An _asset freeze_ transaction additionally has the following fields:

- The _asset ID_ \\( \Asset_\mathrm{frz,ID} \\), encoded as msgpack field `faid`,
is a 64-bit unsigned integer that identifies the asset being _frozen_ or _unfrozen_.

- The _freeze address_ \\( I_\mathrm{frz} \\), encoded as msgpack field `fadd`, is
the 32-byte address that identifies the account whose holdings of the _asset ID_
should be _frozen_ or _unfrozen_.

- The _frozen status_ \\( \Asset_f \\), encoded as a msgpack field `afrz`, is a boolean
flag setting of whether the holdings should be frozen (`true`) or unfrozen (`false`).

## Semantic

TODO

## Validation

TODO