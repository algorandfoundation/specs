$$
\newcommand \Peer {\mathrm{Peer}}
$$

# Pseudo Node

A _Pseudo Node_, referred to as `Loopback` in the `go-algorand` codebase, is an
internal component that simulates network communication by redirecting messages
(such as proposals and votes) back into the node itself.

Its purpose is to introduce streamline internal message handling without introducing
code duplication or additional complexity.

By treating self-originated messages as if they were received from an external \\( \Peer \\),
the node can process them using the same logic and flow as actual network messages.
This ensures consistency within the state machine and leverages existing validation
and routing infrastructure.

{{#include ../_include/styles.md:example}}
> The following example from the [reference implementation](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/agreement/actions.go#L387)
> illustrates how the _Pseudo Node_ mechanism is used during proposal assembly.
> The `Loopback` component creates proposals internally. These are then turned into
> events that the system treats just like any other externally received proposals.
> This pattern is particularly useful in scenarios where the node itself is eligible
> to participate in consensus, allowing it to handle its own messages with the same
> rigor as peer-generated ones.
