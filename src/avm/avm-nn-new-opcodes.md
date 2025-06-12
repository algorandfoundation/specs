# New OpCodes

Here we describe the process of adding a new AVM OpCode to `go-algorand` reference
implementation, providing the example of a dummy `double` OpCode.

The AVM OpCodes are versioned (`langspec_v`) and can be categorized as:

- Arithmetic and Logic Operations
- Byte Array Manipulation
- Cryptographic Operations
- Pushing Values on Stack/Heap (Constants, Txn / ASA / App / Account / Global Fields)
- Control Flow
- State Access
- Inner Transactions

## OpCode Definition

Most OpCodes logic lives in `data/transactions/logic/eval.go` ([link](https://github.com/algorand/go-algorand/blob/34deef26be34aebbdd7221dd2c55181e6f584bd2/data/transactions/logic/eval.go)).
Some exceptions are larger families of OpCodes with their own files (e.g., `box.go`).

For the dummy `double` OpCode example, let's define the _operator_ function in
`data/transactions/logic/eval.go` :

```go
func opDouble(cx *EvalContext) error {
    last := len(cx.Stack) - 1
    res, carry := bits.Add64(cx.Stack[last].Uint, cx.Stack[last].Uint, 0)
    if carry > 0 {
        return errors.New("double overflowed")
    }
    cx.Stack[last].Uint = res
    return nil
}
```

## OpCode Spec

OpCodes are included by adding them to `opcodes.go` with a unique byte value.

Let's add the new `OpSpec` value in the `OpSpecs` [array](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/data/transactions/logic/opcodes.go#L492).

The format is `{0x01, "sha256", opSHA256, proto("b:b{32}"), 2, costly(35)}`.

The arguments may be interpreted as follows:

- A `byte` indicating the OpCode number,

- A `string` with the identifier of the OpCode,

- The `eval.go` function that handles OpCode execution (defined above),

- A `proto` structure defined through the `proto()` function. This indicates the
actual signature of the new OpCode.
  - The element before `:` indicates the values _to be popped from the top_ of the stack,
  - The element after `:` indicates the values _to be pushed to the stack_,
  - The letter identifies the type of arguments. In case of `byte` arrays the length
  could be expressed as a number in curly brackets.

- The AVM `version` where the new OpCode is introduced,

- The `cost` of the new OpCode.

For the `double` dummy OpCode:

```go
var OpSpecs = []OpSpec{
    ...
    // Double OpCode
    {0x75, "dobule", opDouble, proto("i:i"), 42, detDefault()},
    ...
}
```

## Update LangSpec

Run `make` from within the `data/transactions/logic/` directory to generate an updated
_language specification_ (`langspec_v`) and TEAL docs.

## Build Binary

Run `make` from the root of the `go-algorand` directory to build new `algod` binary.

## Testing

Tests are organized in the accompanying `data/transactions/logic/eval_test.go` file.

Let's test the new OpCode locally by generating a [netgoal template](https://github.com/algorand/go-algorand/tree/13e66ff9ba5073637f69f9dd4e5572f19b77e38c/cmd/netgoal)
and running a new Local Network.

> Be sure to set the network’s Consensus Version to `future` if you’re adding an
> OpCode to a future AVM version.

## OpCode Cost Estimation

Estimate the new OpCode budget (e.g., benchmarking against similar ones).