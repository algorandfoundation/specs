$$
\newcommand \MinBalance {b_{\min}}
\newcommand \Asset {\mathrm{Asa}}
\newcommand \MaxAssetDecimals {\Asset_{d,\max}}
\newcommand \MaxAssetNameBytes {\Asset_{n,\max}}
\newcommand \MaxAssetUnitNameBytes {\Asset_{u,\max}}
\newcommand \MaxAssetURLBytes {\Asset_{r,\max}}
$$

# Assets

Each account can create assets, named by a globally-unique 64-bit unsigned
integer (the _asset ID_).

Assets are associated with a set of _asset parameters_, which can be encoded as a
msgpack struct:

- The _total_ number of units of the asset created, encoded with msgpack field `t`.
This value **MUST** be between \\( 0 \\) and \\( 2^{64}-1 \\).

- The number of digits after the decimal place to be used when displaying the asset,
encoded with msgpack field `dc`. The divisibility of the asset is given by \\( 10^{-\mathrm{dc}} \\).
A `dc` value of \\( 0 \\) represents an asset that is not divisible, while a value of \\( 1 \\)
represents an asset divisible into tenths, \\( 2 \\) into hundredths, etc. This value
**MUST** be between \\( 0 \\) and \\( \MaxAssetDecimals \\) (inclusive) (because
\\( 2^{64}-1 \\) is \\( 20 \\) decimal digits integer).

- Whether holdings of that asset are _frozen by default_, a boolean flag encoded
with msgpack field `df`.

- A string representing the _unit name_ of the asset for display to the user, encoded
with msgpack field `un`. This field _does not uniquely identify an asset_; multiple
assets can have the same unit name. The maximum length of this field is \\( \MaxAssetUnitNameBytes \\)
bytes.

- A string representing the _name of the asset_ for display to the user, encoded
with msgpack field `an`. This _does not uniquely identify an asset_; multiple assets
can have the same name. The maximum length of this field is \\( \MaxAssetNameBytes \\)
bytes.

- A string representing a URL that further describes the asset, encoded with msgpack
field `au`. This _does not uniquely identify an asset_; multiple assets can have the
same URL. The maximum length of this field is \\( \MaxAssetURLBytes \\) bytes.

- A 32-byte hash specifying a commitment to asset-specific metadata, encoded with
msgpack field `am`. This _does not uniquely identify an asset_; multiple assets can
have the same commitment.

- An address of a _manager_ account, encoded with msgpack field `m`. The manager
address is used to update the addresses in the asset parameters using an asset
configuration transaction. The manager can destroy the asset if the creator account
holds its total supply entirely.

- An address of a _reserve_ account, encoded with msgpack field `r`. The reserve
address is not used in the protocol, and is used purely by client software for
user display purposes.

- An address of a _freeze_ account, encoded with msgpack field `f`. The freeze
address is used to issue asset freeze transactions.

- An address of a _clawback_ account, encoded with msgpack field `c`. The clawback
address is used to issue asset transfer transactions from arbitrary source addresses.

Parameters for assets created by an account are stored alongside the account state,
denoted by a pair (address, asset ID).

Accounts can create and hold any number of assets.

An account must hold every asset that it created (even if it holds \\( 0 \\) units
of that asset), until that asset is destroyed.

An account’s asset holding is simply a map from asset IDs to an integer value indicating
how many units of that asset are held by the account, and a boolean flag indicating
if the holding is frozen or unfrozen.

An account that holds any asset cannot be closed.

## Asset Minimum Balance Changes

When an account opts in to an asset or creates an asset, the minimum balance requirements
for that account increases. The minimum balance requirement is decreased equivalently
when an account closes out or deletes an asset.

When opting in to an asset, there is a base minimum balance increase of
\\( \MinBalance \\) μALGO.

When creating an asset, there is a base minimum balance increase of
\\( \MinBalance \\) μALGO.
