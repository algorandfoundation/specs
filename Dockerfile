# syntax=docker/dockerfile:1

FROM rust:1.90-slim-bookworm AS base

WORKDIR /book

COPY book.toml .
COPY theme ./theme
COPY mermaid.min.js mermaid-init.js ./

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && cargo install mdbook mdbook-mermaid \
    && mdbook-mermaid install

# CI/CD image
FROM base AS ci-cd

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
ENTRYPOINT ["mdbook"]

# Release image ----
FROM base AS release

RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    texlive \
    texlive-luatex \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    fonts-noto \
    fonts-noto-color-emoji \
    librsvg2-bin \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv

RUN cargo install mdbook-pandoc

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1

ENTRYPOINT ["mdbook"]