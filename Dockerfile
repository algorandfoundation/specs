# syntax=docker/dockerfile:1

FROM rust:1.90-slim-bookworm AS base

WORKDIR /book

COPY book.toml .
COPY theme ./theme

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && cargo install mdbook mdbook-mermaid \
    && mdbook-mermaid install

# CI/CD image
FROM base AS ci-cd

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
ENTRYPOINT ["mdbook"]

# Release image
FROM base AS release

RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive \
    texlive-luatex \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    fonts-noto \
    fonts-noto-color-emoji \
    librsvg2-bin \
    npm \
    chromium \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV MERMAID_FILTER_FORMAT=svg

RUN npm install --global mermaid-filter@1.4.7

RUN PANDOC_VERSION=3.8.2 && \
    ARCH=$(dpkg --print-architecture) && \
    curl -fL -o pandoc-${PANDOC_VERSION}-1-${ARCH}.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${ARCH}.deb && \
    dpkg -i pandoc-${PANDOC_VERSION}-1-${ARCH}.deb && \
    rm pandoc-${PANDOC_VERSION}-1-${ARCH}.deb

RUN cargo install mdbook-pandoc

COPY puppeteer-config.json /etc/puppeteer-config.json

# Wrap the real mmdc executable to inject the config file option
ARG MMD_PATH="/usr/local/lib/node_modules/mermaid-filter/node_modules/.bin"
RUN mv "${MMD_PATH}/mmdc" "${MMD_PATH}/mmdc-original"
COPY --chmod=755 mmdc-wrapper.sh "${MMD_PATH}/mmdc"

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1

ENTRYPOINT ["mdbook"]