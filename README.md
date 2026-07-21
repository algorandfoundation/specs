# Algorand Specifications

The Algorand Specifications are continuously deployed at <https://specs.algorand.co/>

The $\LaTeX$ PDF Book version is generated on [release](https://github.com/algorandfoundation/specs/releases/latest).

> ⚠️ The PDF Book is a work in progress, it may contain formatting errors and missing
> graphic contents. You can track the progress of the PDF Book in [this issue](https://github.com/algorandfoundation/specs/issues/243).

## Contribution

If you would like to contribute, please read the [contribution guideline](https://specs.algorand.co/CONTRIBUTIONS)
first.

To build and serve the Algorand Specifications locally, refer to the [installation
instructions](https://specs.algorand.co/CONTRIBUTIONS#installation).

### Linting

CI runs `make lint` on every pull request and **fails the build** if it does not
pass, so run it locally before pushing. `make lint` drives [pre-commit](https://pre-commit.com/),
which enforces two hooks defined in [`.pre-commit-config.yaml`](./.pre-commit-config.yaml):

- **markdownlint** — Markdown style, configured by [`.markdownlint.json`](./.markdownlint.json).
- **trailing-whitespace** — no trailing whitespace.

```sh
make lint-setup   # once: installs pre-commit (needs python3 + pip)
make lint         # run the same checks CI runs
```

To have the checks run automatically on every `git commit`, install the git hook:

```sh
pre-commit install
```

Rules that commonly trip up new content:

- **Line length (MD013): 120 characters.** Fenced code blocks and Markdown tables
  are exempt, but `$$…$$` math blocks are **not** — wrap long LaTeX across lines
  (whitespace is insignificant in math mode; only `\\` ends a row).
- **Table alignment (MD060): `aligned` style.** Every row's pipes must line up with
  the header. When you add or edit a row, re-pad the whole column so the `|`
  separators stay aligned.

### Typos

To fix typos, consider opening a pull request labeled _"typo"_. By clicking on the
_“Suggest an edit”_ icon in the top-right corner of the page containing the typo,
you will be redirected to the relevant source code file to be edited in the pull
request.

### Issues

To report major issues, such as unclear contents, errors in mathematical formulas,
broken rendering of the Web version or PDF version, broken rendering of diagrams,
broken links, etc. please consider submitting a [templated issue](https://github.com/algorandfoundation/specs/issues/new/choose).

## Archived Specifications

The Algorand Specifications have been completely updated and renewed throughout 2025,
both in form (new website and PDF Book) and contents (non-normative sections, diagrams,
examples, etc.).

The last Algorand Specifications release tag supporting the _old_ format (HTML and PDF)
is: [`7791a63`](https://github.com/algorandfoundation/specs/releases/tag/7791a63).

The source files for the old format are available in the [`_archive`](./_archive)
folder.
