# syntax=docker/dockerfile:1

FROM peaceiris/mdbook:latest-rust

# Set the working directory
WORKDIR /book

# Copy all necessary files
COPY src src
COPY book.toml .

RUN mdbook-mermaid install

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
