# Payment Transaction

## Fields

A _payment_ transaction additionally has the following fields:

| FIELD    |  CODEC  |   TYPE    | REQUIRED |
|:---------|:-------:|:---------:|:--------:|
| Amount   |  `amt`  | `uint64`  |   Yes    |
| Receiver |  `rcv`  | `address` |   Yes    |
| Close-to | `close` | `address` |    No    |

### Amount

The _amount_ \\( a \\) indicates the number of μALGO being transferred by the payment
transaction.

> If the _amount_ is omitted (\\( a = 0 \\)), the number of μALGO transferred is
> zero.

### Receiver

The _receiver_ \\( I^\prime \\) specifies the receiver of the _amount_ in the payment
transaction.

> If the _receiver_ is omitted (\\( I^\prime = 0 \\)), the _amount_ is transferred
> to the _zero address_.

### Close-to

The _close to_ address \\( I_0 \\) (**OPTIONAL**) collects all remaining μALGO in
the _sender_ account _after_ the payment transfer.

> If the _close to_ address is omitted (\\( I_0 = 0 \\)), the field has no effect.

## Validation

 - The _close to_ address **MUST NOT** be the _sender_ address.
 - If Payouts.Enabled, then FeeSink **SHALL NOT** send any payments. Otherwise, the _receiver_ address **MUST** be the RewardsPool address and the _close to_ address **MUST** be the _zero address_.

## Semantic

TODO
