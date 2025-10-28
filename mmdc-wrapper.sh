#!/bin/sh
exec "${MMD_PATH}/mmdc-original" --puppeteerConfigFile /etc/puppeteer-config.json "$@"
