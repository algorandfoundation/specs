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
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libxshmfence1 \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

# Set a shared cache directory for Puppeteer's browser download
ENV PUPPETEER_CACHE_DIR /usr/local/share/puppeteer_cache

RUN npm install --global mermaid-filter
RUN PANDOC_VERSION=3.8.2 && \
    ARCH=$(dpkg --print-architecture) && \
    curl -fL -o pandoc-${PANDOC_VERSION}-1-${ARCH}.deb https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${ARCH}.deb && \
    dpkg -i pandoc-${PANDOC_VERSION}-1-${ARCH}.deb && \
    rm pandoc-${PANDOC_VERSION}-1-${ARCH}.deb

RUN cargo install mdbook-pandoc

COPY puppeteer-config.json /etc/puppeteer-config.json

# Define the path to the mmdc executable
ARG MMD_PATH="/usr/local/lib/node_modules/mermaid-filter/node_modules/.bin"

# Wrap the real mmdc executable to inject the config file option
RUN mv "${MMD_PATH}/mmdc" "${MMD_PATH}/mmdc-original" && \
    echo "#!/bin/sh" > "${MMD_PATH}/mmdc" && \
    echo "exec \"${MMD_PATH}/mmdc-original\" --puppeteerConfigFile /etc/puppeteer-config.json \"\$@\"" >> "${MMD_PATH}/mmdc" && \
    chmod +x "${MMD_PATH}/mmdc"

RUN useradd --create-home --shell /bin/bash appuser
RUN chown -R appuser:appuser /book
RUN chmod 644 /etc/puppeteer-config.json
USER appuser

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1

ENTRYPOINT ["mdbook"]