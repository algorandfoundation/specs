# syntax=docker/dockerfile:1

FROM rust:1.90-slim-bookworm

# Set the working directory
WORKDIR /book

# Copy all necessary files
COPY src src
COPY book.toml .

RUN cargo install mdbook mdbook-mermaid
RUN mdbook-mermaid install

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
