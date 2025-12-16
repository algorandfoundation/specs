SHELL := /usr/bin/env bash

# Pinned tool versions (also used when building the Docker images)
MDBOOK_VERSION ?= 0.5.1
MDBOOK_MERMAID_VERSION ?= 0.17.0

# Local defaults
MDBOOK   ?= mdbook
BOOK_DIR ?= .
HOST     ?= 127.0.0.1
PORT     ?= 3000

MERMAID_ASSETS := mermaid.min.js mermaid-init.js

DOCKER_COMPOSE ?= docker compose

# Commands for local and Docker-backed execution
MDBOOK_CMD_LOCAL   = $(MDBOOK)
MERMAID_CMD_LOCAL  = mdbook-mermaid

MDBOOK_CMD_DOCKER  = $(DOCKER_COMPOSE) run --rm mdbook mdbook
MERMAID_CMD_DOCKER = $(DOCKER_COMPOSE) run --rm mdbook mdbook-mermaid

.PHONY: help doctor \
        setup serve serve-auto build clean lint setup-lint-tools \
        docker-ci docker-release docker-serve docker-build-html docker-ci-all

help:
	@echo "Local:"
	@echo "  make setup             Install local mdBook tools + Mermaid assets (requires cargo)"
	@echo "  make serve             Serve the book locally"
	@echo "  make build             Build the book locally"
	@echo "  make serve-auto        Serve locally if possible, else via Docker"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-ci         Build light ci-cd image and install Mermaid assets via Docker"
	@echo "  make docker-serve      Serve the book using the ci-cd Docker image"
	@echo "  make docker-release    Build all images and build the book via release image"
	@echo ""
	@echo "Misc:"
	@echo "  make doctor            Check tools, Mermaid assets, and config"
	@echo "  make clean             Remove build artifacts and untracked Mermaid JS"
	@echo "  make setup-lint-tools  Install pre-commit (requires python3 + pip)"
	@echo "  make lint              Run pre-commit on the repo"

# ---------- Diagnostics ----------

doctor:
	@echo "== mdBook doctor =="
	@if [ -f "book.toml" ]; then \
		echo "✔ book.toml found"; \
	else \
		echo "✖ book.toml NOT found in repo root"; \
	fi
	@for f in $(MERMAID_ASSETS); do \
		if [ -f "$$f" ]; then \
			echo "✔ Mermaid asset present: $$f"; \
		else \
			echo "✖ Mermaid asset missing: $$f"; \
		fi; \
	done
	@echo ""
	@echo "== Local tools =="
	@if command -v $(MDBOOK) >/dev/null 2>&1; then \
		echo "✔ $(MDBOOK) found: $$($(MDBOOK) --version)"; \
	else \
		echo "✖ $(MDBOOK) not found in PATH"; \
	fi
	@if command -v mdbook-mermaid >/dev/null 2>&1; then \
		echo "✔ mdbook-mermaid found: $$(mdbook-mermaid --version || echo '(version check failed)')"; \
	else \
		echo "✖ mdbook-mermaid not found in PATH"; \
	fi
	@echo ""
	@echo "== Docker =="
	@if command -v docker >/dev/null 2>&1 && command -v docker compose >/dev/null 2>&1; then \
		echo "✔ docker and docker compose available"; \
	else \
		echo "✖ docker or docker compose not available"; \
	fi

# ---------- Local workflow ----------

# Unified setup: install mdBook + mdbook-mermaid locally, then generate Mermaid assets
setup:
	@echo "Installing mdbook $(MDBOOK_VERSION) and mdbook-mermaid $(MDBOOK_MERMAID_VERSION) locally..."
	@command -v cargo >/dev/null || { \
		echo "ERROR: 'cargo' not found. Install Rust toolchain first."; exit 1; }
	cargo install --locked --force mdbook --version $(MDBOOK_VERSION)
	cargo install --locked --force mdbook-mermaid --version $(MDBOOK_MERMAID_VERSION)
	@echo "Installing Mermaid assets into $(BOOK_DIR)..."
	$(MERMAID_CMD_LOCAL) install $(BOOK_DIR)

# Serve the book locally
serve:
	$(MDBOOK_CMD_LOCAL) serve --hostname $(HOST) --port $(PORT) $(BOOK_DIR)

# Auto mode: prefer local, fall back to Docker if mdbook is missing
serve-auto:
	@if command -v $(MDBOOK) >/dev/null 2>&1; then \
		echo "Using local mdbook..."; \
		$(MAKE) serve; \
	else \
		echo "Local mdbook not found, falling back to Docker (docker-ci + docker-serve)..."; \
		$(MAKE) docker-ci; \
		$(MAKE) docker-serve; \
	fi

# Build the book locally
build:
	$(MDBOOK_CMD_LOCAL) build $(BOOK_DIR)

# ---------- Docker workflow ----------

# Light Docker flow: build ci-cd image and install Mermaid assets
docker-ci:
	@echo "Building ci-cd (light) Docker image..."
	$(DOCKER_COMPOSE) build mdbook \
	  --build-arg MDBOOK_VERSION=$(MDBOOK_VERSION) \
	  --build-arg MDBOOK_MERMAID_VERSION=$(MDBOOK_MERMAID_VERSION)
	@echo "Installing Mermaid assets via ci-cd container..."
	$(MERMAID_CMD_DOCKER) install $(BOOK_DIR)

docker-build-html:
	$(MDBOOK_CMD_DOCKER) build $(BOOK_DIR)

docker-ci-all: docker-ci docker-build-html

# Full release flow: build all images, install Mermaid assets, then build via release image
docker-release:
	@echo "Building all Docker images (ci-cd + release)..."
	$(DOCKER_COMPOSE) build \
	  --build-arg MDBOOK_VERSION=$(MDBOOK_VERSION) \
	  --build-arg MDBOOK_MERMAID_VERSION=$(MDBOOK_MERMAID_VERSION)
	@echo "Installing Mermaid assets via ci-cd container..."
	$(MERMAID_CMD_DOCKER) install $(BOOK_DIR)
	@echo "Building book via release image..."
	$(DOCKER_COMPOSE) run --rm mdbook-release mdbook build $(BOOK_DIR)

# Serve using Docker (ci-cd image) with ports exposed
docker-serve:
	$(DOCKER_COMPOSE) up mdbook

# ---------- Misc ----------

setup-lint-tools:
	@command -v python3 >/dev/null || { echo "ERROR: 'python3' not found."; exit 1; }
	@python3 -m pip --version >/dev/null 2>&1 || { echo "ERROR: pip not available for python3."; exit 1; }
	@python3 -m pip install --user pre-commit

clean:
	@echo "Removing build directory 'book/' (if any)..."
	@rm -rf book
	@echo "Removing untracked Mermaid JS assets (keeping tracked ones)..."
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

lint:
	@command -v pre-commit >/dev/null || { echo "ERROR: 'pre-commit' not found. Run: make install-lint-tools"; exit 1; }
	@pre-commit run --all-files