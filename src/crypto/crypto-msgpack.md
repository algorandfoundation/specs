# Canonical Msgpack

Algorand uses a version of [MsgPack](https://github.com/msgpack/msgpack/blob/master/spec.md)
to produce canonical encodings of data.

Algorand's msgpack encodings are valid msgpack encodings, but the encoding function
is _deterministic_ to ensure a canonical representation that can be reproduced to
verify signatures.

A canonical msgpack encoding in Algorand must follow these rules:

1. Maps **MUST** contain keys in lexicographic order;

1. Maps **MUST** omit key-value pairs where the value is a _zero-value_, unless
otherwise specified;

1. Positive integer values **MUST** be encoded as `unsigned` in msgpack, regardless
of whether the value space is semantically signed or unsigned;

1. Integer values **MUST** be represented in the _shortest possible encoding_;

1. Binary arrays **MUST** be represented using the `bin` format family (that is,
use the most recent version of msgpack rather than the older msgpack version that
had no `bin` family).