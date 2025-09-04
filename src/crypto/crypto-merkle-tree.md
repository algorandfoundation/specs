# Merkle Tree

Algorand uses a Merkle Tree to commit to an array of elements and to generate and
verify proofs of elements against such a commitment.

Merkle Trees are used:

- To generate a cryptographic commitment to the `payset` of a block (see the Algorand
Ledger [normative specification](../ledger/ledger-overview.md)),

- For the tree structure in the two-level Ephemeral Signature Scheme (see Algorand
Keys [normative specification](../keys/keys-ephemeral.md)),

- To build [State Proofs](#state-proofs).

The Merkle Tree algorithm is defined for a dense array of `N` elements numbered
`0` through `N-1`.

We now describe how to commit to an array (to produce a commitment in the form of
a root hash), what a proof looks like, and how to verify a proof for one or more
elements.

Since at most one valid proof can be efficiently computed for a given position, element,
and root commitment, we do not formally define an algorithm for generating a proof.
Any algorithm that generates a valid proof (i.e., which passes verification) is correct.

A reasonable strategy for generating a proof is to follow the logic of the proof
verifier and fill in the expected left- and right-sibling values in the proof based
on the internal nodes of the Merkle Tree built up during commitment.

The Merkle Tree can be created using one of the supported [hash functions](./crypto-hash.md).

## Commitment

To commit to an array of `N` elements, each element is first hashed to produce a
\\( 32 \\)-byte hash value, together with the appropriate [domain-separation prefix](./crypto-domain-separators.md);
this produces a list of `N` hashes.

If `N = 0`, then the commitment is all-zero (i.e., \\( 32 \\) zero bytes). Otherwise,
the list of `N` \\( 32 \\)-byte values is repeatedly reduced to a shorter list,
as described below, until exactly one \\( 32 \\)-byte value remains; at that point,
this resulting \\( 32 \\)-byte value is the commitment.

The reduction procedure takes pairs of even-and-odd-indexed values in the list (for
instance, the values at positions `0` and `1`; the values at positions `2` and `3`;
and so on) and hashes each pair to produce a single value in the reduced list (respectively,
at position `0`; at position `1`; and so on).

To hash two values into a single value, the reduction procedure concatenates the
[domain-separation prefix](./crypto-domain-separators.md) `MA` together with the
two values (in the order they appear in the list), and then applies the hash function.

When a list has an _odd_ number of values, the last value is paired together with
an all-zero value (i.e., \\( 32 \\) zero bytes).

The pseudocode for the commitment algorithm is as follows:

```python
def commit(elems):
  hashes = [H(elem) for elem in elems]
  return reduce(hashes)

def reduce(hashes):
  if len(hashes) == 0:
    return [0 for _ in range(32)]
  if len(hashes) == 1:
    return hashes[0]
  nexthashes = []
  while len(hashes) > 0:
    left = hashes[0]
    right = hashes[1] if len(hashes) > 1 else [0 for _ in range(32)]
    hashes = hashes[2:]
    nexthashes.append(H("MA" + left + right))
  return reduce(nexthashes)
```

## Proofs

Logically, to verify that an element appears at some position `P` in the array,
the verifier runs a variant of the commit procedure to compute a candidate root hash.
It then checks if the resulting root hash equals the expected commitment value.

The key difference is that the verifier does not have access to the entire list
of committed elements; the verifier has just some subset of elements (one or more),
along with the positions at which these elements appear.

Thus, the verifier needs to know the siblings (the `left` and `right` values used
in the `reduce()` function above) to compute its candidate root hash.

The list of these siblings constitutes the proof; thus, a proof is a list of zero
or more \\( 32 \\)-byte hash values.

Algorand defines a deterministic order in which the verification procedure expects
to find siblings in this proof, so no additional information is required as part
of the proof (in particular, no information about which part of the Merkle Tree
each proof element corresponds to).

## Verifying a Proof

The following pseudocode defines the logic for verifying a proof (a list of \\( 32 \\)-byte
hashes) for one or more elements, specified as a list of position-element pairs,
sorted by position in the array, against a root commitment.

The function `verify` returns `True` if `proof` is a valid proof for all elements
in `elems` being present at their positions in the array committed to by `root`.

The function implements a variant of `reduce()` for a _sparse_ array, rather than
a fully populated one.

```python
def verify(elems, proof, root):
  if len(elems) == 0:
    return len(proof) == 0
  if len(elems) == 1 and len(proof) == 0:
    return elems[0].pos == 0 && elems[0].hash == root

  i = 0
  nextelems = []
  while i < len(elems):
    pos = elems[i].pos
    poshash = elems[i].hash
    sibling = pos ^ 1
    if i+1 < len(elems) and elems[i+1].pos == sibling:
      sibhash = elems[i+1].hash
      i += 2
    else:
      sibhash = proof[0]
      proof = proof[1:]
      i += 1
    if pos&1 == 0:
      h = H("MA" + poshash + sibhash)
    else:
      h = H("MA" + sibhash + poshash)
    nextelems.append({"pos": pos/2, "hash": h})

  return verify(nextelems, proof, root)
```

> The pseudocode might raise an exception due to accessing the proof past the end;
> this is equivalent to returning `False`.
