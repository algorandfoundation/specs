$$
\newcommand \MaxTimestampIncrement {\Delta t_{\max}}
$$

# Timestamp

The timestamp \\( t \\) is a 64-bit signed integer.

The timestamp is purely informational and states when a block was first proposed,
expressed in the number of seconds since the Unix epoch (00:00:00 UTC on Thursday,
1 January 1970).

The timestamp \\( t_{r+1} \\) of a block in round \\( r \\) is valid if:

- \\( t_{r} = 0 \\) or
- \\( t_{r+1} > t_{r} \\) and \\( t_{r+1} < t_{r} + \MaxTimestampIncrement \\).

{{#include ../_include/styles.md:example}}
> Suppose the block production stalls on round \\( r \\) for a prolonged time. When
> correct operations resume, a certain number \\( n \\) of blocks has to be committed
> until the timestamp catches up to external time references. If \\( t^{\ast} \\)
> is the current external time reference, then:
>
> $$
> n = \left\lceil \frac{t^{\ast} - t_{r}}{\MaxTimestampIncrement} \right\rceil
> $$
