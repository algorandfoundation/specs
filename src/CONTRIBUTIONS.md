# Contribution Guidelines

The source of the Algorand Specification is released on the official GitHub Algorand
Foundation [repository](https://github.com/algorandfoundation/specs).

If you would like to contribute, please consider submitting an issue or opening a
pull request.

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

## Installation

Clone the Algorand Specifications repository and install the git submodules:

**SSH** clone:

```shell
git clone --recurse-submodules git@github.com:algorandfoundation/specs.git
cd specs
```

or

**HTTPS** clone:

```shell
git clone --recurse-submodules https://github.com/algorandfoundation/specs.git
cd specs
```

### Sync git submodules

If the Algorand Specifications repository is already cloned, sync the git submodules
in the `specs` folder:

```shell
git submodule update --init --recursive
```

## Build and Serve

Use the `make` command to build and serve the Algorand Specifications book locally
or in a Docker container.

### In Container

To build and serve the book in a Docker container, the following dependencies are
required:

- **Docker**;
- **Docker Compose**.

Build the Docker image:

```shell
make docker-ci
```

Serve (hot reload) the book on [localhost:3000](http://localhost:3000):

```shell
make docker-serve
```

### Locally

This section is for contributors who **cannot / do not want to** use Docker.

> The PDF Book and release toolchain (Pandoc, mdbook-pandoc, LaTeX, etc.) are intentionally
> **out of scope** here.

To build and serve the book locally, the following dependencies are required:

- **Rust toolchain** (`cargo`): install Rust with [rustup](https://rust-lang.org/tools/install/).

Install the mdBook tools:

```shell
make setup
```

> Ensure Cargo’s bin dir (usually `~/.cargo/bin`) is on your `PATH`.

Build and serve the book (HTML) locally (hot reload) on [localhost:3000](http://localhost:3000):

```shell
make serve
```

## Linting and Formatting

Linting and formatting are enforced with [pre-commit](https://pre-commit.com/).

To run pre-commit hooks locally, the following dependencies are required:

- **Python** (`python3 + pip`).

Install pre-commit hooks:

```shell
make setup-lint-tools
```

Run pre-commit hooks:

```shell
make lint
```

## CI/CD and Release

The CI/CD and Release pipeline is defined in the `.github/workflows/` files.

The CI runs on a Pull Request to:

- Enforce linting and formatting;
- Provide warnings for broken links;
- Deploy the book preview to a temporary URL for review.

The CD pipeline deploys the book to <https://specs.algorand.co> on every push to
the `master` branch.

The Release pipeline creates the release tag, builds the PDF Book, and publishes
it as a release artifact.
