# Round

The round or _round number_ is a 64-bit unsigned integer that indexes into the
sequence of states and blocks.

The round \\( r \\) of each block is one greater than the round of the previous block
(\\( r_i = r_{i-1} + 1 \\)).

Given a Ledger \\( L \\), the round of a block _exclusively_ identifies it.

The rest of this document describes components of states and blocks with respect
to some implicit Ledger. Thus, the round exclusively describes some component, and
we denote the round of a component with a subscript. For instance, the timestamp
of state/block \\( r \\) is denoted \\( t_r \\).