#!/usr/bin/env bash
set -euo pipefail

source_dir=/book
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

cd "$source_dir"
git ls-files --recurse-submodules -z \
    | tar --null --files-from=- --create --file=- \
    | tar --extract --file=- --directory="$work_dir"

awk '
    /^\[output\.pandoc(\]|\.)/ { skip = 1; next }
    /^\[/ { skip = 0 }
    !skip
' "$work_dir/book.toml" > "$work_dir/book.html.toml"
mv "$work_dir/book.html.toml" "$work_dir/book.toml"

mdbook-mermaid install "$work_dir"
mdbook build --dest-dir "$source_dir/book/html" "$work_dir"
