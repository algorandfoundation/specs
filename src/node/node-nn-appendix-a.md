# Appendix A - MsgPack Reference

In the `go-algorand` reference implementation, all data structures that are exchanged
between components of the Algorand node are annotated to specify how they should
be encoded.

The Algorand Cryptographic [specification](../crypto/crypto-representation.md) defines
the encoding rules for each type using a canonical variant of _MessagePack_.

Additional details about how encoding works in the Algorand Node can be found in
the `go-algorand` MessagePack [documentation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/docs/messagepack.md).

Here are some important rules used by the codec:

- If a struct includes the special field `\_struct struct{}`, then all codec options
(such as `omitempty`, `omitemptyarray`, etc.) apply to each field within that struct.

- The first part of the codec tag string specifies the field name to use in the encoded
output. If this name is omitted (e.g., `codec:","` or `codec:",..."`), the field
will be encoded using its original Go field name.

> For a broader understanding of the `msgpack` format in Go, refer to this [primer](https://ugorji.net/blog/go-codec-primer).
