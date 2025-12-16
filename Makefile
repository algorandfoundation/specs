SHELL := /usr/bin/env bash

# Pinned tool versions
MDBOOK_VERSION ?= 0.5.1
MDBOOK_MERMAID_VERSION ?= 0.17.0

MDBOOK ?= mdbook
BOOK_DIR ?= .
HOST   ?= 127.0.0.1
PORT   ?= 3000

MERMAID_ASSETS := mermaid.min.js mermaid-init.js

.PHONY: help tools install-tools mermaid-assets build serve clean clean-mermaid

help:
	@echo "Targets:"
	@echo "  make install-tools   Install pinned mdbook/mdbook-mermaid and set up Mermaid assets"
	@echo "  make serve           Serve the book locally (HOST=$(HOST) PORT=$(PORT))"
	@echo "  make build           Build the HTML into ./book"
	@echo "  make clean           Remove ./book and generated Mermaid JS assets"

tools:
	@command -v "$(MDBOOK)" >/dev/null || { echo "ERROR: 'mdbook' not found. Run: make install-tools"; exit 1; }
	@command -v mdbook-mermaid >/dev/null || { echo "ERROR: 'mdbook-mermaid' not found. Run: make install-tools"; exit 1; }

install-tools:
	@command -v cargo >/dev/null || { echo "ERROR: 'cargo' not found. Install Rust (rustup) first."; exit 1; }
	cargo install mdbook --version "$(MDBOOK_VERSION)"
	cargo install mdbook-mermaid --version "$(MDBOOK_MERMAID_VERSION)"
	$(MAKE) mermaid-assets

# Ensures mermaid.min.js and mermaid-init.js exist in the book directory (idempotent).
mermaid-assets: tools
	mdbook-mermaid install "$(BOOK_DIR)"

build: tools mermaid-assets
	$(MDBOOK) build

serve: tools mermaid-assets
	$(MDBOOK) serve -n "$(HOST)" -p "$(PORT)"

clean: clean-mermaid
	@echo "Removing mdBook assets"
	@rm -rf book

# Remove Mermaid JS files if they were generated locally (i.e., not tracked by git).
clean-mermaid:
	@for f in $(MERMAID_ASSETS); do \
		if [ -f "$$f" ]; then \
			if command -v git >/dev/null 2>&1 && git ls-files --error-unmatch "$$f" >/dev/null 2>&1; then \
				echo "Keeping tracked Mermaid asset: $$f"; \
			else \
				echo "Removing Mermaid asset: $$f"; \
				rm -f "$$f"; \
			fi; \
		fi; \
	done
