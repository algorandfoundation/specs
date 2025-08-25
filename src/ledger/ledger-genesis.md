$$
\newcommand \Genesis {\mathrm{Genesis}}
\newcommand \GenesisID {\Genesis{\mathrm{ID}}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \GenesisHash {\Genesis\Hash}
$$

# Genesis

## Genesis Identifier

The _genesis identifier_ is a short string that identifies an instance of a Ledger
\\( L \\).

The genesis identifier of a valid block is the identifier of the block in the previous
round. In other words, \\( \GenesisID_{r+1} = \GenesisID_{r} \\).

## Genesis Hash

The _genesis hash_ is a cryptographic hash of the genesis configuration, used to unambiguously
identify an instance of the Ledger \\( L \\).

The genesis hash is set in the genesis block (or the block at which an upgrade to
a protocol supporting \\( \GenesisHash \\) occurs), and **MUST** be preserved identically
in all subsequent blocks.
