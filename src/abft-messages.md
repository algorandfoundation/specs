# Messages

Players communicate with each other by exchanging _messages_.

A message is an opaque object containing arbitrary data, save for the fields defined
below.

> For a detailed overview of message composition, whether consensus or other types,
> see the [Algorand Network Overview](./network-overview.md).

## Elementary Data Types

A _period_ \\(p\\) is a 64-bit integer.

A _step_ \\(s\\) is an 8-bit integer.

Steps are named for clarity and are defined as follows:

| STEP          | ENUMERATIVE |
|---------------|-------------|
| \\(Propose\\) | \\(0\\)     |
| \\(Soft\\)    | \\(1\\)     |
| \\(Cert\\)    | \\(2\\)     |
| \\(Late\\)    | \\(253\\)   |
| \\(Redo\\)    | \\(254\\)   |
| \\(Down\\)    | \\(255\\)   |
| \\(Next_s\\)  | \\(s + 3\\) |

The following functions are defined on \\(s\\):

- \\(CommitteeSize(s)\\) is a 64-bit integer defined as follows:

  \\[
  CommitteeSize(s) =
  \begin{cases}
  20 & : s = Propose \\\\\\
  2990 & : s = Soft \\\\\\
  1500 & : s = Cert \\\\\\
  500 & : s = Late \\\\\\
  2400 & : s = Redo \\\\\\
  6000 & : s = Down \\\\\\
   5000 & : \text{otherwise}
  \end{cases}
  \\]

- \\(CommitteeThreshold(s)\\) is a 64-bit integer defined as follows:

  \\[
  CommitteeThreshold(s) =
  \begin{cases} 
  0 & : s = Propose \\\\\\
  2267 & : s = Soft \\\\\\
  1112 & : s = Cert \\\\\\
  320 & : s = Late \\\\\\
  1768 & : s = Redo \\\\\\
  4560 & : s = Down \\\\\\
  3838 & : \text{otherwise}
  \end{cases}
  \\]

A _proposal-value_ is a tuple \\(v = (I, p, Digest(e), Hash(Encoding(e)))\\) where:

- \\(I\\) is an address (the "original proposer"),
- \\(p\\) is a period (the "original period"),
- \\(Hash\\) is some cryptographic hash function.

The special proposal-value where all fields are the zero-string is called the _bottom
proposal_ \\(\bot\\).