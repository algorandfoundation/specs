#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd "${1:-.}" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

cd "$source_dir"
git ls-files --recurse-submodules -z \
    | tar --null --files-from=- --create --file=- \
    | tar --extract --file=- --directory="$work_dir"

# Force this validation build to HTML-only. The optional Pandoc renderer that
# starts and then exits nonzero still fails the whole mdBook build.
awk '
    /^\[output\.pandoc(\]|\.)/ { skip = 1; next }
    /^\[/ { skip = 0 }
    !skip
' "$work_dir/book.toml" > "$work_dir/book.html.toml"
mv "$work_dir/book.html.toml" "$work_dir/book.toml"

mdbook-mermaid install "$work_dir"
mdbook_cmd=mdbook
if command -v mdbook-original >/dev/null 2>&1; then
    mdbook_cmd=mdbook-original
fi
"$mdbook_cmd" build --dest-dir "$source_dir/book/html" "$work_dir"

echo "Removing .html suffixes from generated links..."
while IFS= read -r -d '' file; do
    tmp_file="${file}.tmp.$$"
    sed \
        -e 's|href="index\.html"|href="."|g' \
        -e 's|\(href="[^":]*\)/index\.html\(["#?]\)|\1/\2|g' \
        -e 's|\(href="[^":]*\)\.html\(["#?]\)|\1\2|g' \
        "$file" > "$tmp_file" || {
            rm -f "$tmp_file"
            exit 1
        }
    mv "$tmp_file" "$file"
done < <(find "$source_dir/book/html" -type f \
    \( -name "*.html" -o -name "toc.js" -o -name "toc-*.js" \) -print0)
echo "Done!"
