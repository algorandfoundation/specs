# Reading Guidelines

The Algorand Specifications consist of _normative_ and _non-normative_ sections.

The _normative_ sections formally define Algorand. All the components of the normative
sections are gated by the Algorand consensus protocol. The scope of these sections
is to provide a complete and correct specification of the Algorand protocol, regardless
of the implementation. Therefore, the language used in those sections is formal,
prescriptive, and succinct.

The _non-normative_ sections provide context and auxiliary information for the Algorand
implementation. The components of the non-normative sections are not enforced through
the Algorand consensus protocol. The scope of these sections is to ease understanding
of the normative sections and provide readers with a comprehensive view the Algorand
reference implementation (`go-algorand`). Therefore, the language used in those
sections is informal, descriptive, and discoursive.

The current version of the Algorand Specifications reflects the latest version of the
Algorand consensus protocol in its _normative_ sections and is generally aligned with
the most recent stable release of `go-algorand` in its _non-normative_ sections.
Specifications for previous consensus versions can be found via the link provided in
the `current-protocol.upgrade-state` field of the block corresponding to the desired
consensus version.

## Formatting

The source code of this documentation is built in [CommonMark](https://commonmark.org/)
with [mdBook](https://rust-lang.github.io/mdBook/index.html).

> Notes like this are non-normative comments in the normative sections.

{{#include ./.include/styles.md:example}}
> Sections like this are examples aiming to clarify the formal specifications.

{{#include ./.include/styles.md:impl}}
> Sections like this contain links to the `go-algorand` reference implementation.

The `code-blocks` may contain pseudo-code or real code snippets.

Mathematical formulas are defined with [MathJax](https://www.mathjax.org/)[^1].

Diagrams’ source code is defined with [Mermaid](https://mermaid.js.org/).

Figures’ source code is defined with [Excalidraw](https://excalidraw.com/).

---

[^1]: For a correct rendering of MathJax is recommended to right-click on any formula
and select `Math Settings -> Math Renderer -> Common HTML` from the drop-down menu.