# Payment Transaction

## Fields

A _payment_ transaction additionally has the following fields:

- The _amount_ \\( a \\), encoded as msgpack field `amt`, which is an **OPTIONAL**
64-bit unsigned integer that indicates the number of μALGO being transferred.

> If the _amount_ is omitted (\\( a = 0 \\)), the number of μALGO transferred is
> zero.

- The _receiver_ \\( I^\prime \\), encoded as msgpack field `rcv`, is an **OPTIONAL**
32-bytes address which specifies the receiver of the _amount_ in the transaction.

> If the _receiver_ is omitted (\\( I^\prime = 0 \\)), the _amount_ is transferred
> to the _zero address_.

- The _close to address_ \\( I_0 \\), encoded as msgpack field `close`, is an **OPTIONAL**
32-bytes address that collects all remaining μALGO in the _sender_ account _after_
the transfer.

> If the _close to address_ is omitted (\\( I_0 = 0 \\)), the field has no effect.


## Validation

TODO

## Semantic

TODO