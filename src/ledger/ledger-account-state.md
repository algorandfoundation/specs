\newcommand \Record {\mathrm{Record}}
\newcommand \PartKey {\mathrm{PartKey}}
\newcommand \Eligibility {\mathrm{A_e}}
\newcommand \Stake {\mathrm{Stake}}
\newcommand \Units {\mathrm{Units}}

# Account State

The _balances_ are a set of mappings from _addresses_, 256-bit integers, to _balance
records_. 

A _balance record_ contains the following fields:

- The account _raw balance_ in μALGO,
- The account _status_,
- The block incentive _eligibility_ flag,
- The account _last_proposed_ round,
- The account _last_heartbeat_ round,
- The account _rewards base_ and _total awarded amount_ in μALGO,
- The account _spending key_,
- The account [participation keys]().

> In the rest of this section, all references to _Reward calculation_ are with respect
> to the legacy distribution rewards system. They are kept here for completeness
> and for backward compatibility.

The account raw balance \\( a_I \\) is a 64-bit unsigned integer which determines
how much μALGO the address has.

The account rewards base \\( a^\prime_I \\) and total-awarded amount \\(a^\ast_I \\)
are 64-bit unsigned integers.

Combined with the account balance, the reward base and total awarded amount are
used to distribute rewards to accounts lazily.

The _account stake_ is a function which maps a given account and round to the account's
balance in that round and is defined as follows:

$$
\Stake(r, I) = a_I + (T_r - a^\ast_I) \floor{\frac{a_I}{A}}
$$

unless \\( p_I = 2 \\) (see below), in which case:

$$
\Stake(r, I) = a_I
$$

\\( \Units(r) \\) is a function that computes the total number of whole _earning
units_ present in a system at round \\( r \\). 

A user owns \\( \floor{\frac{a_I}{A}} \\) whole earning units, so the total number
of earning units in the system is:

$$
\Units(r) = \sum_I \floor{\frac{a_I}{A}}
$$

for the \\( a_I \\) corresponding to round \\( r \\).

In this sum, online and offline accounts are taken into consideration.

<!-- TODO define how \Units updates -->

The account status \\( p_I \\) is an 8-bit unsigned integer which is either \\( 0, 1, 2 \\):

- A status of 0 corresponds to an _offline_ account,
- A status of 1 corresponds to an _online_ account,
- A status of 2 corresponds to a _non-participating_ account.

Combined with the account stake, the account status determines how much _voting
stake_ an account has, which is a 64-bit unsigned integer defined as follows:

- The account balance, if the account is online.
- 0 otherwise.

The account's _spending key_ determines how transactions from this account must be
authorized (e.g., what public key to verify transaction signatures against).

Transactions from this account must have this value (or, if this value zero, the
account's address) as their _authorization address_. This is described in the
[Authorization and Signatures]() section.

The account's _participation keys_ \\( \PartKey \\) are defined in Algorand's [specification
of participation keys]().

The account's eligibility \\( \Eligibility \\) is a flag that determines whether
the account has elected to receive payouts for proposing blocks (assuming it meets
balance requirements at the time of block proposal).

An account's participation keys and voting stake from a recent round is returned
by the \\( \Record \\) procedure in the [Byzantine Agreement Protocol]().

There exist two special addresses:

- \\( I_\mathrm{pool} \\), the address of the _incentive pool_,

- \\( I_f \\), the address of the _fee sink_. 

For both of these accounts, \\( p_I = 2 \\).