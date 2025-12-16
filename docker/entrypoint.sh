#!/bin/sh
set -eu

BOOK_ROOT=${BOOK_ROOT:-/book}
ASSETS_DIR=${MDBOOK_MERMAID_ASSETS_DIR:-/usr/local/share/mdbook-mermaid}

# If the mounted book.toml references mermaid assets, ensure they exist in the book root.
if [ -f "${BOOK_ROOT}/book.toml" ]; then
  if grep -Eq 'preprocessor\.mermaid|mermaid\.min\.js|mermaid-init\.js' "${BOOK_ROOT}/book.toml" 2>/dev/null; then
    for f in mermaid.min.js mermaid-init.js; do
      if [ ! -f "${BOOK_ROOT}/${f}" ] && [ -f "${ASSETS_DIR}/${f}" ]; then
        cp "${ASSETS_DIR}/${f}" "${BOOK_ROOT}/${f}"
      fi
    done
  fi
fi

exec mdbook "$@"
