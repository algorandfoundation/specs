#!/bin/sh
# Wrapper for mdbook that automatically removes .html suffixes after build
set -e

# Run the actual mdbook command
/usr/local/bin/mdbook-original "$@"

# If the command was "build", remove .html suffixes
if [ "$1" = "build" ]; then
    echo "Removing .html suffixes from generated links..."

    # Process toc-*.js files
    find book/ -name "toc-*.js" -o -name "toc.js" | xargs -r sed -i 's|href="index\.html"|href="."|g'
    find book/ -name "toc-*.js" -o -name "toc.js" | xargs -r sed -i 's|\(href="[a-zA-Z0-9.][^"]*\)\.html"|\1"|g'

    # Process all HTML files
    find book/ -name "*.html" -exec sed -i 's|href="index\.html"|href="."|g' {} +
    find book/ -name "*.html" -exec sed -i 's|\(href="[a-zA-Z0-9.][^"]*\)\.html"|\1"|g' {} +

    echo "Done!"
fi
