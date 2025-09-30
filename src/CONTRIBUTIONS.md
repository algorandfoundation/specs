# Contribution Guidelines

The source of the Algorand Specification is released on the official GitHub Algorand
Foundation [repository](https://github.com/algorandfoundation/specs).

If you would like to contribute, please consider submitting an issue or opening a
pull request.

By clicking on the _“Suggest an edit”_ icon in the top-right corner, while reading
this book, you will be redirected to the relevant source code file to be referenced
in an issue or edited in a pull request.

## Source Code

The Algorand Specifications book is built with [mdBook](https://rust-lang.github.io/mdBook/index.html).

The source code is structured as follows:

```text
.github/                  -> GitHub actions and CI/CD workflows
_archive/                 -> Legacy specification archive
src/                      -> mdBook source code
└── _include/             -> Code snippets, templates, TeX-macros, and examples
└── _excalidraw/          -> Excalidraw diagrams source code
└── _images/              -> SVG files
└── Part_A/               -> Part A normative files
    └── non-normative/    -> Part A non-normative files
└── Part_B/               -> Part B files
└── Part.../              -> ...
└── SUMMARY.md, ...       -> mdBook SUMMARY.md, COVER.md, prefix/suffix-chapters, etc.
```

## Markdown

The book is written in [CommonMark](https://commonmark.org/).

The CI pipeline enforces Markdown linting, formatting, and style checking with
[`markdownlint`](https://github.com/DavidAnson/markdownlint).

### Numbered Lists

Numbered lists **MUST** be defined with `1`-only style.

{{#include ./_include/styles.md:example}}
>
> ```text
> 1. First item
> 1. Second item
> 1. Third item
> ```
>
> Result:
>
> 1. First item
> 1. Second item
> 1. Third item

### Tables

Table rows **MUST** use the same column widths.

{{#include ./_include/styles.md:example}}
> ✅ Correct table format
>
> ```text
> | Month    | Savings |
> |----------|---------|
> | January  | €250    |
> | February | €80     |
> | March    | €420    |
> ```
>
> ❌ Wrong table format
>
> ```text
> | Month | Savings |
> |----------|---------|
> | January | €250 |
> | February | €80 |
> | March | €420 |
> ```
>
> Result:
>
> | Month    | Savings |
> |----------|---------|
> | January  | €250    |
> | February | €80     |
> | March    | €420    |

Consider aligning text in the columns to the left, right, or center by adding a
colon `:` to the left, right, or on both sides of the dashes `---` within the header
row.

{{#include ./_include/styles.md:example}}
>
> ```text
> | Name   | Quantity | Size |
> |:-------|:--------:|-----:|
> | Item A |    1     |    S |
> | Item B |    5     |    M |
> | Item C |    10    |   XL |
> ```
>
> Result:
>
> | Name   | Quantity | Size |
> |:-------|:--------:|-----:|
> | Item A |    1     |    S |
> | Item B |    5     |    M |
> | Item C |    10    |   XL |

## MathJax

Mathematical formulas are defined with [MathJax](https://www.mathjax.org/).

> mdBook MathJax [documentation](https://rust-lang.github.io/mdBook/format/mathjax.html).

### Inline Equations

Inline equations **MUST** include extra spaces in the MathJax delimiters.

{{#include ./_include/styles.md:example}}
> Equation: \\( \int x dx = \frac{x^2}{2} + C \\)
>
> ✅ Correct inline delimiter
>
> ```text
> \\( \int x dx = \frac{x^2}{2} + C \\)
> ```
>
> ❌ Wrong inline delimiter
>
> ```text
> \\(\int x dx = \frac{x^2}{2} + C\\)
> ```

### Block Equations

Block equations **MUST** use the `$$` delimiter (instead of `\\[ ... \\]`).

{{#include ./_include/styles.md:example}}
> Equation:
>
> $$
> \mu = \frac{1}{N} \sum_{i=0} x_i
> $$
>
> ✅ Correct block delimiter
>
> ```text
> $$
> \mu = \frac{1}{N} \sum_{i=0} x_i
> $$
> ```
>
> ❌ Wrong inline delimiter
>
> ```text
> \\[
> \mu = \frac{1}{N} \sum_{i=0} x_i
> \\]
> ```

### TeX-Macros

TeX-macros are defined in the `./src/_include/tex-macros/` folder using the mdBook
[include feature](https://rust-lang.github.io/mdBook/format/mdbook.html#including-files).

TeX-macros are divided into functional blocks (e.g., pseudocode, operators, constants, etc.).

TeX-macros **MUST** be imported at the top of the consumer files using the mdBook.

TeX macros can be imported entirely or partially (e.g., just a functional block).

{{#include ./_include/styles.md:example}}
> Import all TeX-macros:
>
> ```text
> \{{#include ./.include/tex-macros.md:all}}
> ```
>
> Import just a block of TeX-macros (e.g., pseudocode commands):
>
> ```text
> \{{#include ./.include/tex-macros.md:pseudocode}}
> ```

## Block Styles

Block styles are defined in the `./src/.include/styles.md` file using the mdBook
[include feature](https://rust-lang.github.io/mdBook/format/mdbook.html#including-files).

Block styles (e.g., examples, implementation notes, etc.) are “styled quote” blocks
included in the book.

{{#include ./_include/styles.md:example}}
> This example block has been included with the following syntax:
>
> ```text
> \{{#include ./_include/styles.md:example}}
> > This example block has been included with the following syntax:
> ```

## GitHub Links

Links to the `go-algorand` reference implementation or other repositories **MUST**
be [permalinks](https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files).

## Diagrams

### Structured Diagrams

Structured diagrams (e.g., flow charts, sequence diagrams, etc.) are defined with
[Mermaid](https://mermaid.js.org/intro/) “text-to-diagram” tool.

### Unstructured Diagrams

Unstructured diagrams and images are drawn with [Excalidraw](https://excalidraw.com/).

Excalidraw images **MUST** be exported in `.svg` format and saved in the `./src/images/`
folder.

Excalidraw images source code **MUST** be committed in the `./src/.excalidraw/`
folder.

## Docker

The Algorand Specifications repository makes use of a `Dockerfile`.

To run the `specs` book as a container:

```shell
docker compose up
```

This will serve the `specs` book on [localhost:3000](http://localhost:3000).
