# Reading Guidelines

The Algorand Specifications consist of _normative_ and _non-normative_ sections.

The _normative_ sections formally define Algorand. All the components of the normative
sections are gated by the Algorand consensus protocol. The scope of these sections
is to provide a complete and correct formal specification of the Algorand protocol,
regardless of the implementation. Therefore, the language used in those sections
is formal, prescriptive, and succinct.

The _non-normative_ sections provide context and auxiliary information for the Algorand
implementation. The components of the non-normative sections are not enforced through
the Algorand consensus protocol. The scope of these sections is to ease understanding
of the normative sections and provide readers with a comprehensive view the Algorand
reference implementation (`go-algorand`). Therefore, the language used in those
sections is less formal, descriptive, and discoursive.

## Formatting

The source code of this documentation is built in [CommonMark](https://commonmark.org/)
with [mdBook](https://rust-lang.github.io/mdBook/index.html).

> Notes like this are non-normative comments in the normative sections.

> 📎 **EXAMPLE**
>
> Sections like this are examples aiming to clarify the formal specifications.

> ⚙️ **IMPLEMENTATION**
>
> Sections like this contain links to the `go-algorand` reference implementation.

The `code-blocks` may contain pseudo-code or real code snippets.

Mathematical formulas are defined with [MathJax](https://www.mathjax.org/).

Diagrams are defined with [Mermaid](https://mermaid.js.org/).