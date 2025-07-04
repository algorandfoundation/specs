# Payment Transaction

## Fields

A _payment_ transaction additionally has the following fields:

- The _amount_ \\( a \\), encoded as msgpack field `amt`, which is a 64-bit unsigned
integer that indicates the amount of μALGO to be transferred.

- The _receiver_ \\( I^\prime \\), encoded as msgpack field `rcv`, is **OPTIONAL**
an 32-bytes address which specifies the receiver of the _amount_ in the transaction.

> If the _receiver_ is omitted (\\( I^\prime = 0 \\)), the _amount_ is transferred
> to the _zero address_.

- The _closing address_ \\( I_0 \\), encoded as msgpack field `close`, is an **OPTIONAL**
32-bytes address that collects all remaining funds in the account after the transfer
and sends them to the specified address.

> If the _closing address_ is omitted (\\( I_0 = 0 \\)), the field has no effect.

## Semantic

TBD