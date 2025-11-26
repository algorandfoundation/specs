# syntax=docker/dockerfile:1

FROM rust:1.91-slim-bookworm AS base

ARG MDBOOK_VERSION=0.5.1
ARG MDBOOK_MERMAID_VERSION=0.17.0

WORKDIR /book

COPY book.toml .
COPY theme ./theme
COPY theme-ext ./theme

# Install basic tooling required for building mdBook and running health checks.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Install mdBook and the Mermaid preprocessor with matching versions.
RUN cargo install --locked --force --root /usr/local mdbook --version ${MDBOOK_VERSION} \
    && cargo install --locked --force --root /usr/local mdbook-mermaid --version ${MDBOOK_MERMAID_VERSION}

# Wrap mdbook to automatically remove .html suffixes after build
RUN mv /usr/local/bin/mdbook /usr/local/bin/mdbook-original
COPY --chmod=755 mdbook-wrapper.sh /usr/local/bin/mdbook

# CI/CD image
FROM base AS ci-cd

RUN mdbook-mermaid install

ENTRYPOINT ["mdbook"]

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1

# Release image
FROM base AS release

ARG MDBOOK_PANDOC_VERSION=0.11.0

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

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    MERMAID_FILTER_FORMAT=svg \
    MMD_PATH=/usr/local/lib/node_modules/mermaid-filter/node_modules/.bin

RUN npm install --global mermaid-filter@1.4.7

RUN PANDOC_VERSION=3.8.2 && \
    ARCH=$(dpkg --print-architecture) && \
    curl -fL -o pandoc-${PANDOC_VERSION}-1-${ARCH}.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${ARCH}.deb && \
    dpkg -i pandoc-${PANDOC_VERSION}-1-${ARCH}.deb && \
    rm pandoc-${PANDOC_VERSION}-1-${ARCH}.deb

RUN cargo install --locked --force --root /usr/local mdbook-pandoc --version ${MDBOOK_PANDOC_VERSION}

COPY puppeteer-config.json /etc/puppeteer-config.json

# Wrap the real mmdc executable to inject the config file option
RUN mv "${MMD_PATH}/mmdc" "${MMD_PATH}/mmdc-original"
COPY --chmod=755 mmdc-wrapper.sh "${MMD_PATH}/mmdc"

ENTRYPOINT ["mdbook"]

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
