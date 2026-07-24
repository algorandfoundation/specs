# syntax=docker/dockerfile:1

ARG UV_VERSION
ARG UV_IMAGE_SHA256

FROM ghcr.io/astral-sh/uv:${UV_VERSION}@sha256:${UV_IMAGE_SHA256} AS uv

FROM rust:1.96-slim-trixie AS base

WORKDIR /book

# Install basic tooling required for building mdBook and running health checks.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY toolchain.env /tmp/toolchain.env

# Install mdBook and the Mermaid preprocessor with matching versions.
RUN . /tmp/toolchain.env \
    && cargo install --locked --root /usr/local mdbook --version "${MDBOOK_VERSION}" \
    && cargo install --locked --root /usr/local mdbook-mermaid --version "${MDBOOK_MERMAID_VERSION}"

# Wrap mdbook to automatically remove .html suffixes after build
RUN mv /usr/local/bin/mdbook /usr/local/bin/mdbook-original
COPY --chmod=755 docker/mdbook-wrapper.sh /usr/local/bin/mdbook

FROM base AS ci-cd

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /uvx /usr/local/bin/

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1

FROM base AS release

RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive \
    texlive-luatex \
    fonts-noto-core \
    librsvg2-bin \
    npm \
    chromium \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    MERMAID_FILTER_FORMAT=svg \
    MMD_PATH=/usr/local/lib/node_modules/mermaid-filter/node_modules/.bin

RUN . /tmp/toolchain.env \
    && npm install --global "mermaid-filter@${MERMAID_FILTER_VERSION}"

RUN . /tmp/toolchain.env \
    && ARCH="$(dpkg --print-architecture)" \
    && case "${ARCH}" in \
         amd64) PANDOC_SHA256="${PANDOC_SHA256_AMD64}" ;; \
         arm64) PANDOC_SHA256="${PANDOC_SHA256_ARM64}" ;; \
         *) echo "Unsupported Pandoc architecture: ${ARCH}" >&2; exit 1 ;; \
       esac \
    && PANDOC_PACKAGE="pandoc-${PANDOC_VERSION}-1-${ARCH}.deb" \
    && curl -fL -o "${PANDOC_PACKAGE}" \
      "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/${PANDOC_PACKAGE}" \
    && echo "${PANDOC_SHA256}  ${PANDOC_PACKAGE}" | sha256sum --check --strict - \
    && dpkg -i "${PANDOC_PACKAGE}" \
    && rm "${PANDOC_PACKAGE}"

RUN . /tmp/toolchain.env \
    && cargo install --locked --root /usr/local mdbook-pandoc --version "${MDBOOK_PANDOC_VERSION}"

COPY docker/puppeteer-config.json /etc/puppeteer-config.json

# Wrap the real mmdc executable to inject the config file option
RUN mv "${MMD_PATH}/mmdc" "${MMD_PATH}/mmdc-original"
COPY --chmod=755 docker/mmdc-wrapper.sh "${MMD_PATH}/mmdc"

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
