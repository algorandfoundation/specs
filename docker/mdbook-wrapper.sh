#!/bin/sh
# Wrapper for mdbook that automatically removes .html suffixes after build
set -e

# Run the actual mdbook command
/usr/local/bin/mdbook-original "$@"

# If the command was "build", remove .html suffixes
if [ "$1" = "build" ]; then
    echo "Removing .html suffixes from generated links..."

    # Process all relevant files (HTML and JS) in one go
    find book/ -type f \( -name "*.html" -o -name "toc.js" -o -name "toc-*.js" \) -print0 | \
        xargs -0 sed -i \
            -e 's|href="index\.html"|href="."|g' \
            -e 's|\(href="[^":]*\)\.html\(["#]\)|\1\2|g'

    echo "Done!"
fi
