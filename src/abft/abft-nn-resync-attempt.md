$$
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
$$

# Resynchronization Attempt

The resynchronization is an auxiliary function used throughout the recovery steps.

A partial order relation is defined in the space of all observed _bundles_. We call
this relation _freshness_.

A resynchronization attempt broadcasts the _freshest_ observed bundle (if any).

Priority-wise, bundles' freshness is defined as follows:

- Bundles for a \\( \Cert \\) step are fresher than all other bundles.

- Bundles from a later _period_ are fresher than bundles from an older period.

- Bundles for \\( \Next \\) step are fresher than bundles for a \\( \Soft \\) step of the same period.

- Bundles for \\( \Next \\) step for the \\( \bot \\) _proposal-value_ are fresher
than bundles for a \\( \Next \\) step for some other value.

> For a formal definition of this property, refer to the ABFT [normative section](./abft.md#special-values).

{{#include ../_include/styles.md:impl}}
> Bundle freshness [reference implementation](https://github.com/algorand/go-algorand/blob/55011f93fddb181c643f8e3f3d3391b62832e7cd/agreement/player.go#L518).

> In the reference implementation, a resynchronization attempt is handled by the `partitionPolicy`
> function, as the network is assumed to be in a “partitioned state” due to the
> temporary inability to reach consensus. In this case, the function is only invoked
> when the current step \\( s \geq 3 \\) or when the current period \\( p \geq 3 \\)
> (that is, the player has gone through _two full periods_ without reaching a consensus).
