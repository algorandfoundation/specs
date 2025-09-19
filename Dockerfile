# syntax=docker/dockerfile:1

FROM rust:1.90-slim-bookworm

WORKDIR /book

COPY book.toml .

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

RUN cargo install mdbook mdbook-mermaid mdbook-pandoc \
    && mdbook-mermaid install

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1

ENTRYPOINT ["mdbook"]