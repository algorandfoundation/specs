# Guidance for AI coding agents

Before changing Markdown content in this repository, read
[`src/CONTRIBUTIONS.md`](./src/CONTRIBUTIONS.md) — in particular its
"Markdown", "MathJax", and "Linting and Formatting" sections — for the
formatting and style rules the linter enforces (numbered lists, table column
alignment, MathJax delimiters, line length including inside `$$ ... $$`
blocks, etc.).

CI enforces these checks via `make lint` and will fail the build if they are
not satisfied, so run `make lint` locally before pushing.
