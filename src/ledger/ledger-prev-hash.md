$$
\newcommand \Prev {\mathrm{Prev}}
\newcommand \Hash {\mathrm{Hash}}
$$

# Previous Hash

The previous hash is a cryptographic hash of the previous block header in the sequence
of blocks.

The sequence of previous hashes in each block header forms an authenticated, linked-list
of the reversed sequence.

Let \\( B_r \\) represent the block header in round \\( r \\), and let \\( \Hash \\)
be some cryptographic hash function.

Then the previous hash \\( \Prev_{r+1} \\) in the block for round \\( r+1 \\) is
\\( \Prev_{r+1} = \Hash(B_r) \\).

> In the reference implementation, \\( \Hash \\) is the [SHA512/256 hash function](./crypto.md#sha512256).