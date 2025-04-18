# Conventions and Notation

This specification defines a _player_ to be a unique participant in
this protocol.

This specification describes the operation of a single _correct_
player. A correct player follows this protocol exactly and is
distinct from a _faulty_ player. A faulty player may deviate from
the protocol in any way, so this specification does not describe the
behavior of those players.

Correct players do not follow distinct protocols, so this
specification describes correct behavior with respect to a single,
implicit player. When the protocol must describe a player distinct
from the implicit player (for example, a message that originated from
another player), the protocol will use subscripts to distinguish
different players. Subscripts are omitted when the player is
unambiguous. For instance, a player might be associated with some
"address" \\(I\\); if this player is the \\(k\\)-th player in the protocol,
then this address may also be denoted \\(I_k\\).

This specification will describe certain objects as _opaque_. This
document does not specify the exact implementation of opaque objects,
but it does specify the subset of properties required for any
implementation of some opaque object.

Opaque data definitions and semantics may be specified in other
documents, which this document will cite when available.

All integers described in this document are unsigned, with a maximum value of 2^64-1, unless otherwise noted.