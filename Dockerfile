# syntax=docker/dockerfile:1

FROM peaceiris/mdbook:latest-rust

# Create a non-root user
RUN adduser --disabled-password --gecos "" mdbookuser

# Set the working directory
WORKDIR /book

# Copy all necessary files
COPY src src
COPY book.toml .

# Change ownership of the working directory to the non-root user
RUN chown -R mdbookuser:mdbookuser /book

USER mdbookuser

RUN mdbook-mermaid install

HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
