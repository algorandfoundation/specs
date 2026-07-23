SHELL := /usr/bin/env bash

include toolchain.env

LOCAL_UID ?= $(shell id -u)
LOCAL_GID ?= $(shell id -g)
export LOCAL_UID LOCAL_GID UV_VERSION UV_IMAGE_SHA256

# Local defaults
MDBOOK   ?= mdbook
BOOK_DIR ?= .
HOST     ?= 127.0.0.1
PORT     ?= 3000

# MDBOOK_TEST_MODE controls how 'mdbook test' run: auto|local|docker
MDBOOK_TEST_MODE ?= auto
MDBOOK_TEST_MODE := $(strip $(MDBOOK_TEST_MODE))

MERMAID_ASSETS := mermaid.min.js mermaid-init.js

DOCKER_COMPOSE ?= docker compose
UVX            ?= uvx
PRE_COMMIT      = $(UVX) --managed-python --python $(PYTHON_VERSION) pre-commit@$(PRE_COMMIT_VERSION)

# Commands for local and Docker-backed execution
MDBOOK_CMD_LOCAL   = $(MDBOOK)
MERMAID_CMD_LOCAL  = mdbook-mermaid

MDBOOK_CMD_DOCKER  = $(DOCKER_COMPOSE) run --rm mdbook mdbook
MERMAID_CMD_DOCKER = $(DOCKER_COMPOSE) run --rm mdbook mdbook-mermaid
PRE_COMMIT_DOCKER  = $(DOCKER_COMPOSE) run --rm mdbook $(PRE_COMMIT)

.PHONY: help doctor \
        setup test serve build-html check native-version-warnings \
        docker-image docker-setup docker-test docker-serve docker-build-html \
        docker-lint docker-links-check docker-check docker-ci docker-release \
        ci ci-start ci-info submodules-check \
        test-auto serve-auto local-ready \
        clean versions-check hooks-install lint links-check

help:
	@echo "Local:"
	@echo "  make setup             Install local mdBook tools and install Mermaid assets (requires cargo)"
	@echo "  make test              Test the book locally"
	@echo "  make serve             Build and serve the book locally"
	@echo "  make check             Run native CI-equivalent checks and HTML build; warn on version drift"
	@echo ""
	@echo "Docker:"
	@echo "  make ci                Run the authoritative GitHub-equivalent checks and HTML build"
	@echo "  make docker-setup      Build mdBook light ci-cd image and install Mermaid assets (requires docker)"
	@echo "  make docker-test       Test the book via ci-cd image"
	@echo "  make docker-lint       Run all gating pre-commit hooks via ci-cd image"
	@echo "  make docker-check      Run fast Docker-backed lint and mdBook tests (no HTML build)"
	@echo "  make docker-links-check  Check external links via ci-cd image"
	@echo "  make docker-serve      Build and serve the book via ci-cd image"
	@echo "  make docker-release    Build mdBook full release image and build the book (HTML and PDF)"
	@echo ""
	@echo "Auto:"
	@echo "  make test-auto         Test the book locally if possible, else via Docker"
	@echo "  make serve-auto        Build and serve the book locally if possible, else via Docker"
	@echo ""
	@echo "Misc:"
	@echo "  make doctor            Check dependencies, mdBook, Mermaid assets, and config"
	@echo "  make versions-check    Validate the shared toolchain version manifest"
	@echo "  make clean             Remove build artifacts and untracked Mermaid JS"
	@echo "  make hooks-install     Install the Git pre-commit hook (requires uv)"
	@echo "  make lint              Run all gating pre-commit hooks locally (requires uv)"
	@echo "  make links-check       Check external links locally (requires uv)"

# ---------- Diagnostics ----------

doctor: versions-check
	@echo "== mdBook =="
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
	@echo "== Local workflow =="
	@if command -v $(MDBOOK) >/dev/null 2>&1; then \
		actual="$$($(MDBOOK) --version 2>/dev/null | awk '{print $$NF}')"; \
		actual="$${actual#v}"; \
		if [ "$$actual" = "$(MDBOOK_VERSION)" ]; then \
			echo "✔ $(MDBOOK) $$actual matches toolchain.env"; \
		else \
			echo "✖ $(MDBOOK) $$actual found; expected $(MDBOOK_VERSION)"; \
		fi; \
	else \
		echo "✖ $(MDBOOK) not found in PATH"; \
	fi
	@if command -v mdbook-mermaid >/dev/null 2>&1; then \
		actual="$$(mdbook-mermaid --version 2>/dev/null | awk '{print $$NF}')"; \
		actual="$${actual#v}"; \
		if [ "$$actual" = "$(MDBOOK_MERMAID_VERSION)" ]; then \
			echo "✔ mdbook-mermaid $$actual matches toolchain.env"; \
		else \
			echo "✖ mdbook-mermaid $$actual found; expected $(MDBOOK_MERMAID_VERSION)"; \
		fi; \
	else \
		echo "✖ mdbook-mermaid not found in PATH"; \
	fi
	@echo ""
	@echo "== Docker workflow =="
	@if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then \
		echo "✔ docker and docker compose available"; \
	else \
		echo "✖ docker or docker compose not available"; \
	fi
	@echo ""
	@echo "== Native linting (optional when using Docker) =="
	@if command -v $(UVX) >/dev/null 2>&1; then \
		actual="$$($(UVX) --version 2>/dev/null | awk '{print $$2}')"; \
		if [ "$$actual" = "$(UV_VERSION)" ]; then \
			echo "✔ uvx $$actual matches toolchain.env"; \
		else \
			echo "⚠ uvx $$actual found; Docker uses $(UV_VERSION)"; \
		fi; \
	else \
		echo "✖ uvx not found in PATH (install uv $(UV_VERSION), or use make ci)"; \
	fi

# ---------- Local workflow ----------

# Unified setup: install mdBook + mdbook-mermaid locally, then generate Mermaid assets
setup:
	@echo "Installing mdbook $(MDBOOK_VERSION) and mdbook-mermaid $(MDBOOK_MERMAID_VERSION) locally..."
	@command -v cargo >/dev/null || { \
		echo "ERROR: 'cargo' not found. Install Rust toolchain first."; exit 1; }
	cargo install --locked mdbook --version $(MDBOOK_VERSION)
	cargo install --locked mdbook-mermaid --version $(MDBOOK_MERMAID_VERSION)
	@echo "Installing Mermaid assets into $(BOOK_DIR)..."
	$(MERMAID_CMD_LOCAL) install $(BOOK_DIR)

# Build and serve the book locally
serve:
	$(MDBOOK_CMD_LOCAL) serve --hostname $(HOST) --port $(PORT) $(BOOK_DIR)

check: native-version-warnings submodules-check lint test build-html

build-html: versions-check
	@bash docker/build-html.sh $(BOOK_DIR)

native-version-warnings: versions-check
	@if command -v $(MDBOOK) >/dev/null 2>&1; then \
		actual="$$($(MDBOOK) --version 2>/dev/null | awk '{print $$NF}')"; \
		actual="$${actual#v}"; \
		if [ "$$actual" != "$(MDBOOK_VERSION)" ]; then \
			echo "WARNING: $(MDBOOK) $$actual found; expected $(MDBOOK_VERSION). Native results may differ; run 'make ci' for the authoritative check."; \
		fi; \
	else \
		echo "WARNING: $(MDBOOK) not found; run 'make setup' or use 'make ci'."; \
	fi
	@if command -v mdbook-mermaid >/dev/null 2>&1; then \
		actual="$$(mdbook-mermaid --version 2>/dev/null | awk '{print $$NF}')"; \
		actual="$${actual#v}"; \
		if [ "$$actual" != "$(MDBOOK_MERMAID_VERSION)" ]; then \
			echo "WARNING: mdbook-mermaid $$actual found; expected $(MDBOOK_MERMAID_VERSION). Native results may differ; run 'make ci' for the authoritative check."; \
		fi; \
	else \
		echo "WARNING: mdbook-mermaid not found; run 'make setup' or use 'make ci'."; \
	fi
	@if command -v $(UVX) >/dev/null 2>&1; then \
		actual="$$($(UVX) --version 2>/dev/null | awk '{print $$2}')"; \
		if [ "$$actual" != "$(UV_VERSION)" ]; then \
			echo "WARNING: uvx $$actual found; expected $(UV_VERSION). Native results may differ; run 'make ci' for the authoritative check."; \
		fi; \
	else \
		echo "WARNING: uvx not found; install uv $(UV_VERSION) or use 'make ci'."; \
	fi

# Run 'mdbook-test' locally
test:
	@set -euo pipefail; \
	out="$$(mktemp)"; \
	trap 'rm -f "$$out"' EXIT; \
	status=0; \
	$(MDBOOK_CMD_LOCAL) test $(BOOK_DIR) 2>&1 | tee "$$out" || status=$${PIPESTATUS[0]}; \
	if [ $$status -eq 0 ] && grep -qE '^(ERROR |Error updating )' "$$out"; then \
		status=1; \
	fi; \
	exit $$status

# ---------- Docker workflow ----------

docker-image: versions-check
	@echo "Building ci-cd (light) Docker image..."
	$(DOCKER_COMPOSE) build mdbook

# Light Docker flow: build ci-cd image and install Mermaid assets
docker-setup: docker-image
	@echo "Installing Mermaid assets via ci-cd container..."
	$(MERMAID_CMD_DOCKER) install $(BOOK_DIR)

# Run 'mdbook-test' in Docker (ci-cd image)
docker-test: docker-setup
	@set -euo pipefail; \
	out="$$(mktemp)"; \
	trap 'rm -f "$$out"' EXIT; \
	status=0; \
	$(MDBOOK_CMD_DOCKER) test $(BOOK_DIR) 2>&1 | tee "$$out" || status=$${PIPESTATUS[0]}; \
	if [ $$status -eq 0 ] && grep -qE '^(ERROR |Error updating )' "$$out"; then \
		status=1; \
	fi; \
	exit $$status

docker-lint: docker-image
	@$(PRE_COMMIT_DOCKER) run --all-files

docker-links-check: docker-image
	@$(PRE_COMMIT_DOCKER) run lychee-external --hook-stage manual --all-files --verbose

docker-check: docker-setup docker-lint docker-test

docker-build-html: docker-image
	@$(DOCKER_COMPOSE) run --rm mdbook bash docker/build-html.sh $(BOOK_DIR)

ci-start:
	@echo "== CI environment =="
	@echo "source: $$(git rev-parse HEAD)"
	@echo "target platform: linux/amd64"

ci-info: ci-start submodules-check docker-image
	@$(DOCKER_COMPOSE) run --rm mdbook bash -c '\
		. ./toolchain.env; \
		echo "runtime platform: $$(uname -s)/$$(uname -m)"; \
		rustc --version; \
		cargo --version; \
		mdbook --version; \
		mdbook-mermaid --version; \
		uvx --version; \
		uvx --managed-python --python "$$PYTHON_VERSION" "pre-commit@$$PRE_COMMIT_VERSION" --version; \
		echo "python $$PYTHON_VERSION (pinned)"; \
		echo "node $$NODE_VERSION (pinned for pre-commit)"'

ci: ci-start ci-info docker-check docker-build-html

# Backward-compatible alias. GitHub and contributors should use 'make ci'.
docker-ci: ci

submodules-check:
	@status="$$(git submodule status --recursive)"; \
	if [ -z "$$status" ] || printf '%s\n' "$$status" | grep -Eq '^[+U-]'; then \
		echo "ERROR: submodules are missing or do not match their recorded commits." >&2; \
		echo "Run 'git submodule update --init --recursive'." >&2; \
		exit 1; \
	fi; \
	if ! git submodule foreach --quiet --recursive \
		'git diff --quiet && git diff --cached --quiet && test -z "$$(git ls-files --others --exclude-standard)"'; then \
		echo "ERROR: a submodule contains local changes or untracked files." >&2; \
		exit 1; \
	fi; \
	echo "✔ submodules match their recorded commits and are clean"

# Full release flow: build all images, install Mermaid assets, then build via release image
docker-release: versions-check
	@echo "Building all Docker images (ci-cd + release)..."
	$(DOCKER_COMPOSE) --profile release build
	@echo "Installing Mermaid assets via ci-cd container..."
	$(MERMAID_CMD_DOCKER) install $(BOOK_DIR)
	@echo "Building book via release image..."
	$(DOCKER_COMPOSE) run --rm mdbook-release mdbook build $(BOOK_DIR)

# Build and serve using Docker (ci-cd image) with ports exposed
docker-serve: docker-setup
	$(DOCKER_COMPOSE) up mdbook

# ---------- Auto workflow ----------

# Validate the complete local mdBook toolchain without producing output.
local-ready:
	@command -v $(MDBOOK) >/dev/null 2>&1
	@command -v mdbook-mermaid >/dev/null 2>&1
	@actual="$$($(MDBOOK) --version 2>/dev/null | awk '{print $$NF}')"; \
		test "$${actual#v}" = "$(MDBOOK_VERSION)"
	@actual="$$(mdbook-mermaid --version 2>/dev/null | awk '{print $$NF}')"; \
		test "$${actual#v}" = "$(MDBOOK_MERMAID_VERSION)"
	@for f in $(MERMAID_ASSETS); do test -f "$$f" || exit 1; done

# Auto mode: prefer a complete local toolchain, otherwise fall back to Docker.
serve-auto:
	@if $(MAKE) --no-print-directory local-ready >/dev/null 2>&1; then \
		echo "Using local mdbook..."; \
		$(MAKE) serve; \
	else \
		echo "Local mdbook not found, falling back to Docker..."; \
		$(MAKE) docker-serve; \
	fi

# Auto mode for tests: prefer local, fall back to Docker if mdbook is missing
test-auto:
	@case "$(MDBOOK_TEST_MODE)" in \
		local) \
			$(MAKE) test ;; \
		docker) \
			$(MAKE) docker-test ;; \
		auto) \
			if $(MAKE) --no-print-directory local-ready >/dev/null 2>&1; then \
				echo "Using local mdbook..."; \
				$(MAKE) test; \
			else \
				echo "Local mdbook not found; running tests in Docker..."; \
				$(MAKE) docker-test; \
			fi ;; \
		*) echo "ERROR: MDBOOK_TEST_MODE must be auto|local|docker (got: $(MDBOOK_TEST_MODE))" >&2; exit 2 ;; \
	esac

# ---------- Misc ----------

versions-check:
	@set -eu; \
	. ./toolchain.env; \
	for name in MDBOOK_VERSION MDBOOK_MERMAID_VERSION MDBOOK_PANDOC_VERSION \
		PANDOC_VERSION PANDOC_SHA256_AMD64 PANDOC_SHA256_ARM64 \
		MERMAID_FILTER_VERSION PRE_COMMIT_VERSION PYTHON_VERSION NODE_VERSION \
		UV_VERSION UV_IMAGE_SHA256; do \
		value="$${!name:-}"; \
		if [[ -z "$$value" || "$$value" =~ [^0-9A-Za-z._-] ]]; then \
			echo "ERROR: invalid or missing $$name in toolchain.env" >&2; \
			exit 1; \
		fi; \
	done; \
	for name in PANDOC_SHA256_AMD64 PANDOC_SHA256_ARM64 UV_IMAGE_SHA256; do \
		if [[ ! "$${!name}" =~ ^[0-9a-f]{64}$$ ]]; then \
			echo "ERROR: $$name must be a lowercase SHA-256 digest" >&2; \
			exit 1; \
		fi; \
	done; \
	configured="$$(awk '$$1 == "minimum_pre_commit_version:" { print $$2 }' .pre-commit-config.yaml)"; \
	if [[ "$$configured" != "$$PRE_COMMIT_VERSION" ]]; then \
		echo "ERROR: minimum_pre_commit_version ($$configured) must match PRE_COMMIT_VERSION ($$PRE_COMMIT_VERSION)" >&2; \
		exit 1; \
	fi; \
	configured="$$(awk '$$1 == "node:" { print $$2; exit }' .pre-commit-config.yaml)"; \
	if [[ "$$configured" != "$$NODE_VERSION" ]]; then \
		echo "ERROR: pre-commit node version ($$configured) must match NODE_VERSION ($$NODE_VERSION)" >&2; \
		exit 1; \
	fi; \
	echo "✔ toolchain.env is valid"

hooks-install: versions-check
	@command -v $(UVX) >/dev/null 2>&1 || { echo "ERROR: 'uvx' not found. Install uv $(UV_VERSION)."; exit 1; }
	@$(PRE_COMMIT) install

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

lint: versions-check
	@command -v $(UVX) >/dev/null 2>&1 || { echo "ERROR: 'uvx' not found. Install uv $(UV_VERSION)."; exit 1; }
	@$(PRE_COMMIT) run --all-files

links-check: versions-check
	@command -v $(UVX) >/dev/null 2>&1 || { echo "ERROR: 'uvx' not found. Install uv $(UV_VERSION)."; exit 1; }
	@$(PRE_COMMIT) run lychee-external --hook-stage manual --all-files --verbose
