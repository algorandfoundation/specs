# Contribution Guidelines

The source of the Algorand Specification is released on the official GitHub Algorand
Foundation [repository](https://github.com/algorandfoundation/specs).

If you would like to contribute, please consider submitting an [issue](https://github.com/algorandfoundation/specs/issues/new/choose)
or opening a [pull request](https://github.com/algorandfoundation/specs/pulls).

## Typos

To fix typos, consider opening a pull request labeled _"typo"_. By clicking on the
_“Suggest an edit”_ icon in the top-right corner of the page containing the typo,
you will be redirected to the relevant source code file to be edited in the pull
request.

## Issues

To report major issues, such as unclear contents, errors in mathematical formulas,
broken rendering of the Web version or PDF version, broken rendering of diagrams,
broken links, etc. please consider submitting a [templated issue](https://github.com/algorandfoundation/specs/issues/new/choose).

## Source Code

The Algorand Specifications book is built with [mdBook](https://rust-lang.github.io/mdBook/index.html).

The source code is structured as follows:

```text
src/                      -> mdBook source code
└── _include/             -> Code snippets, templates, TeX-macros, auto-generated files, and examples
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
[`rumdl`](https://github.com/rvben/rumdl).

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
>
> **Correct table format:**
>
> ```text
> | Month    | Savings |
> |----------|---------|
> | January  | €250    |
> | February | €80     |
> | March    | €420    |
> ```
>
> **Incorrect table format:**
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
> | -------- | ------- |
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
> | :----- | :------: | ---: |
> | Item A |    1     |    S |
> | Item B |    5     |    M |
> | Item C |    10    |   XL |

## MathJax

Mathematical formulas are defined with [MathJax](https://www.mathjax.org/).

> mdBook MathJax [documentation](https://rust-lang.github.io/mdBook/format/mathjax.html).

### Inline Equations

Inline equations **MUST** include extra spaces in the MathJax delimiters.

{{#include ./_include/styles.md:example}}
>
> Equation: \\( \int x dx = \frac{x^2}{2} + C \\)
>
> **Correct inline delimiter:**
>
> ```text
> \\( \int x dx = \frac{x^2}{2} + C \\)
> ```
>
> **Incorrect inline delimiter:**
>
> ```text
> \\(\int x dx = \frac{x^2}{2} + C\\)
> ```

### Block Equations

Block equations **MUST** use the `$$` delimiter (instead of `\\[ ... \\]`).

{{#include ./_include/styles.md:example}}
>
> Equation:
>
> $$
> \mu = \frac{1}{N} \sum_{i=0} x_i
> $$
>
> **Correct block delimiter:**
>
> ```text
> $$
> \mu = \frac{1}{N} \sum_{i=0} x_i
> $$
> ```
>
> **Incorrect block delimiter:**
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
>
> Import all TeX-macros:
>
> ```text
> \{{#include ./_include/tex-macros.md:all}}
> ```
>
> Import just a block of TeX-macros (e.g., pseudocode commands):
>
> ```text
> \{{#include ./_include/tex-macros.md:pseudocode}}
> ```

## Block Styles

Block styles are defined in the `./src/_include/styles.md` file using the mdBook
[include feature](https://rust-lang.github.io/mdBook/format/mdbook.html#including-files).

Block styles (e.g., examples, implementation notes, etc.) are “styled quote” blocks
included in the book.

{{#include ./_include/styles.md:example}}
>
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

Excalidraw images **MUST** be exported in `.svg` format without a background and
saved in the `./src/_images/` folder.

Excalidraw images source code **MUST** be committed in the `./src/_excalidraw/`
folder.

## Prepare and Submit a Change

Repository setup, local preview, validation commands, and pull-request preview
behavior are maintained in the [repository README](https://github.com/algorandfoundation/specs#repository-setup).
Follow those instructions before submitting a pull request.

Keep each pull request focused and explain the scope and motivation in its description.
When a change affects rendering, inspect its deployment preview. External-contribution
previews are triggered by maintainers on request.
