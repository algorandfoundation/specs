# Algorand Specifications

The Algorand Specifications are published continuously at <https://specs.algorand.co/>.

The $\LaTeX$ PDF Book is generated on [releases](https://github.com/algorandfoundation/specs/releases/latest).

> ⚠️ The PDF Book is a work in progress and may contain formatting errors or
> missing graphics. Progress is tracked in [issue #243](https://github.com/algorandfoundation/specs/issues/243).

## Contributing to the Specifications

Technical contributors should start with the [contribution guidelines](CONTRIBUTING.md).
They define how to propose changes and the authoring conventions for Markdown, MathJax,
links, and diagrams.

The rest of this document is the operational guide for the repository setup, toolchain,
automation, deployments, and releases.

## Repository Setup

### Requirements

All workflows require [Git](https://git-scm.com/downloads), [GNU Make](https://www.gnu.org/software/make/),
[Bash](https://www.gnu.org/software/bash/), and the repository's Git submodules.

Choose one execution path:

- The Docker path requires only [Docker](https://docs.docker.com/engine/install/) with the
  [Docker Compose plugin](https://docs.docker.com/compose/install/) in addition to the common tools.
  The project images contain the HTML, validation, and release toolchains.
- The native path requires [Rust and Cargo](https://www.rust-lang.org/tools/install/) for mdBook and
  [uv](https://docs.astral.sh/uv/getting-started/installation/) for the pinned pre-commit runner.

The Docker path installs no project tooling on the host. The native setup installs
`mdbook` and `mdbook-mermaid` through `cargo`; `uv` manages Python and `pre-commit`.

PDF Book dependencies (Pandoc, Node.js, Chromium, and LaTeX) remain confined just to the
Docker release image.

Clone the repository with its submodules:

```shell
git clone --recurse-submodules https://github.com/algorandfoundation/specs.git
cd specs
make doctor
```

For an existing checkout, synchronize the submodules before building:

```shell
git submodule update --init --recursive
```

Run `make help` for the complete command list and `make doctor` to compare the
local environment with the repository's declared toolchain.

### Docker Workflow

Run the same authoritative checks and HTML build as GitHub CI:

```shell
make ci
```

This runs the Linux AMD64 toolchain, validates the theme submodule, executes all gating
pre-commit hooks, runs `mdbook test`, and builds the HTML site. On ARM hosts, Docker
uses emulation so that local and remote CI execute the same platform-specific tools.

For a faster Docker-backed edit/test loop without the final HTML build, use
`make docker-check`.

Serve the book with hot reload at <http://localhost:3000>. The command builds the image
and installs the generated Mermaid assets first:

```shell
make docker-serve
```

### Local HTML Workflow

Install the pinned `mdbook` and `mdbook-mermaid` versions with `cargo`:

```shell
make setup
```

Ensure Cargo's binary directory, normally `~/.cargo/bin`, is on `PATH`. Run the native
validation and then serve the book:

```shell
make check
make serve
```

`make check` uses tools installed on the host and warns when their versions differ
from `toolchain.env`. When it emits no version-drift warnings, it is the local equivalent
of Dockerized `make ci`. The local workflow does not install the PDF release toolchain.

## Build and Validation

Before submitting a change, choose either validation path:

```shell
# Exact GitHub Linux AMD64 environment (requires Docker)
make ci

# Equivalent native checks; ensure no version-drift warnings are emitted
make check
```

`make ci` requires Docker and runs the exact environment used by GitHub. `make check`
does not require Docker and runs the same validation gates and HTML build with native
tools. `make test-auto` and `make serve-auto` remain available when automatic
native-to-Docker fallback is useful.

External links are deliberately checked separately because remote services can be
transiently unavailable:

```shell
# Native
make links-check

# Docker
make docker-links-check
```

Validate the complete HTML and PDF release path when changing release tooling:

```shell
make docker-release
```

Generated HTML is written to `book/html/`; the release PDF is written to `book/pandoc/pdf/algorand-specs.pdf`.
Use `make clean` to remove build output and untracked generated Mermaid assets.

## Dependency Management

Dependencies are pinned in the format native to each ecosystem.

| Dependency                                           | Source of truth                                                             | Update mechanism                      |
|------------------------------------------------------|-----------------------------------------------------------------------------|---------------------------------------|
| Shared tool versions, image digests, and checksums   | [`toolchain.env`](toolchain.env)                                            | Manual                                |
| Remote pre-commit hooks, including Lychee            | [`.pre-commit-config.yaml`](.pre-commit-config.yaml)                        | Dependabot or `pre-commit autoupdate` |
| GitHub Actions                                       | Full commit SHAs in `.github/workflows/`                                    | Dependabot                            |
| Rust base image                                      | [`Dockerfile`](Dockerfile)                                                  | Dependabot                            |
| Docker platform configuration                        | [`docker-compose.yaml`](docker-compose.yaml)                                | Manual                                |
| mdBook theme                                         | [`theme`](theme) submodule gitlink                                          | Manual                                |

Dependabot configuration is maintained in [`.github/dependabot.yaml`](.github/dependabot.yaml).

### Shared Toolchain Updates

[`toolchain.env`](toolchain.env) is a manifest consumed by Make, Docker, and CI.
It is the single source of truth for tool versioning.
`make versions-check` validates the manifest and warns when native tool versions drift.

When changing it:

1. Update the relevant version and any associated checksum.
1. Run `make versions-check`.
1. Run `make ci`, or `make check` and confirm that it emits no version-drift warnings.
1. Run `make docker-release` when the change affects Pandoc, `mdbook-pandoc`, Mermaid
   Filter, the Docker base, or other release dependencies.

`UV_VERSION` selects the containerized `uv` release and records the expected native
version. `UV_IMAGE_SHA256` pins the exact multi-platform image used by Docker. When
updating `uv`, resolve the corresponding digest and update both values:

```shell
docker buildx imagetools inspect ghcr.io/astral-sh/uv:<version>
```

`PYTHON_VERSION` pins the uv-managed interpreter used for pre-commit, while
`NODE_VERSION` pins the Node runtime bootstrapped by pre-commit for Markdownlint.

Keep ecosystem-native pins in their native configuration: GitHub Action SHAs belong in
workflow files, hook revisions in the pre-commit configuration, the Rust base image in
the Dockerfile, and the theme revision in the submodule gitlink.

### Pre-commit Hook Updates

Dependabot can update every configured hook repository. When updating manually, use
`pre-commit autoupdate --freeze` so each `rev` remains an immutable commit SHA with its
release tag recorded in a comment.

After an updater changes the configuration, run:

```shell
make ci
```

Run `make links-check` or `make docker-links-check` as well when Lychee changes.

### Other Dependency Updates

- Keep the human-readable version comment when Dependabot updates a GitHub Action's
  immutable commit SHA.
- Resolve and record the new multi-platform digest when changing the uv image.
- When updating the theme submodule, review the upstream change, update the gitlink,
  and validate both HTML and PDF output.

## Automation

Every build workflow receives or resolves an immutable source commit. CI passes
the exact built artifact to deployment.

| Workflow                                                                 | Trigger             | Responsibility                               |
|--------------------------------------------------------------------------|---------------------|----------------------------------------------|
| [`ci.yaml`](.github/workflows/ci.yaml)                                   | Reusable workflow   | Lint, test, and build an exact commit        |
| [`pr.yaml`](.github/workflows/pr.yaml)                                   | Pull request        | Run CI and deploy eligible internal previews |
| [`external-pr-preview.yaml`](.github/workflows/external-pr-preview.yaml) | Maintainer dispatch | Resolve, build, and preview an external PR   |
| [`cd.yaml`](.github/workflows/cd.yaml)                                   | Push to `master`    | Deploy the CI-built site to production       |
| [`links.yaml`](.github/workflows/links.yaml)                             | Monthly or manual   | Check external links                         |
| [`release.yaml`](.github/workflows/release.yaml)                         | Maintainer dispatch | Build the PDF and create a draft release     |

### Pull Request Previews

Pull request CI tests the proposed merge commit. Internal PRs receive an automatic
deployment preview.

External PRs run CI without deployment preview. To preview an external PR, a maintainer
runs the external-preview workflow with its PR number.

### Continuous Deployment

Every push to `master` runs CI for that exact commit. The successful HTML artifact
is then deployed to <https://specs.algorand.co/>.

## Release Runbook

The release workflow always builds the current `master` commit, regardless of the
ref selected when dispatching the workflow.

1. Confirm CI and production deployment are successful for the `master` commit.
1. Open **Actions → Create Release Draft → Run workflow**.
1. Wait for the HTML and PDF release build to complete.
1. Open the generated draft release.
1. Confirm the recorded full source commit and tag identify the `master` commit.
1. Optional: Download and inspect the PDF artifact.
1. Review the generated release notes, then publish the draft.

## Troubleshooting

- Run `make doctor` first; it reports missing tools, version mismatches, missing
  Mermaid assets, and Docker Compose availability.
- Run `make versions-check` when CI rejects `toolchain.env`.
- Run `git submodule update --init --recursive` when the theme is missing or at
  the wrong recorded revision.
- Run `make setup` after changing the local mdBook tool versions.
- Run `make ci`, or run `make check` and confirm that it emits no version-drift
  warnings, before submitting changes.
- Use `make clean` before investigating stale generated output.

## Archived Specifications

The Algorand Specifications have been completely updated and renewed throughout 2025,
both in form (new website and PDF Book) and contents (non-normative sections, diagrams,
examples, etc.).

The last release using the previous HTML and PDF format is [`7791a63`](https://github.com/algorandfoundation/specs/releases/tag/7791a63).
Its (normative only) source files remain available in [`_archive`](./_archive).
