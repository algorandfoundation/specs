#!/bin/sh
exec /usr/local/lib/node_modules/mermaid-filter/node_modules/.bin/mmdc-original --puppeteerConfigFile /etc/puppeteer-config.json "$@"
