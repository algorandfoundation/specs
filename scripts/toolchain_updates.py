#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Report newer toolchain pins without modifying the repository."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tomllib
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parent.parent
TOOLCHAIN_ENV = ROOT / "toolchain.env"
USER_AGENT = "algorand-specs-toolchain-updates"
DIGEST_RE = re.compile(r"^sha256:([0-9a-f]{64})$")
VERSION_RE = re.compile(r"^\d+(?:\.\d+)+$")


class UpdateError(RuntimeError):
    pass


@dataclass(frozen=True)
class Pin:
    name: str
    current: str
    suggested: str

    @property
    def changed(self) -> bool:
        return self.current != self.suggested


def parse_env_text(text: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        key, separator, value = line.partition("=")
        if not separator or not key or not value:
            raise UpdateError(f"invalid toolchain.env line: {line!r}")
        values[key] = value
    return values


def request(url: str) -> bytes:
    headers = {
        "Accept": "application/json",
        "User-Agent": USER_AGENT,
    }
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if url.startswith("https://api.github.com/"):
        headers["Accept"] = "application/vnd.github+json"
        headers["X-GitHub-Api-Version"] = "2022-11-28"
        if token:
            headers["Authorization"] = f"Bearer {token}"
    try:
        with urlopen(Request(url, headers=headers), timeout=30) as response:
            return response.read()
    except (HTTPError, URLError, TimeoutError) as error:
        raise UpdateError(f"failed to fetch {url}: {error}") from error


def request_json(url: str) -> Any:
    try:
        return json.loads(request(url))
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        raise UpdateError(f"invalid JSON from {url}: {error}") from error


def stable_version(value: str, source: str) -> str:
    value = value.removeprefix("v")
    if not VERSION_RE.fullmatch(value):
        raise UpdateError(f"invalid stable version from {source}: {value!r}")
    return value


def version_tuple(value: str) -> tuple[int, ...]:
    if not VERSION_RE.fullmatch(value):
        raise UpdateError(f"invalid version: {value!r}")
    return tuple(int(part) for part in value.split("."))


def github_release(repo: str) -> dict[str, Any]:
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    data = request_json(url)
    if not isinstance(data, dict) or data.get("draft") or data.get("prerelease"):
        raise UpdateError(f"invalid latest release response for {repo}")
    return data


def crate_version(name: str) -> str:
    data = request_json(f"https://crates.io/api/v1/crates/{name}")
    crate = data.get("crate", {}) if isinstance(data, dict) else {}
    version = (
        crate.get("max_stable_version")
        or crate.get("newest_version")
        or crate.get("max_version")
    )
    return stable_version(str(version), f"crates.io/{name}")


def rust_version() -> str:
    url = "https://static.rust-lang.org/dist/channel-rust-stable.toml"
    try:
        data = tomllib.loads(request(url).decode())
        version = data["pkg"]["rust"]["version"].split()[0]
    except (KeyError, tomllib.TOMLDecodeError, UnicodeDecodeError) as error:
        raise UpdateError(f"invalid Rust stable manifest: {error}") from error
    return stable_version(version, "Rust stable channel")


def python_version(current: str) -> str:
    series = version_tuple(current)[:2]
    url = (
        "https://www.python.org/api/v2/downloads/release/"
        "?is_published=true&page_size=100"
    )
    data = request_json(url)
    releases = data.get("results", []) if isinstance(data, dict) else data
    candidates: list[str] = []
    for release in releases if isinstance(releases, list) else []:
        if not isinstance(release, dict):
            continue
        name_match = re.fullmatch(
            r"Python (\d+(?:\.\d+)+)", str(release.get("name", ""))
        )
        value = name_match.group(1) if name_match else ""
        if (
            VERSION_RE.fullmatch(value)
            and version_tuple(value)[:2] == series
            and not release.get("pre_release", False)
            and release.get("is_published", True)
        ):
            candidates.append(value)
    if not candidates:
        raise UpdateError(f"no published Python {series[0]}.{series[1]} release found")
    return max(candidates, key=version_tuple)


def node_version(current: str) -> str:
    major = version_tuple(current)[0]
    data = request_json("https://nodejs.org/dist/index.json")
    candidates = [
        stable_version(str(item["version"]), "nodejs.org")
        for item in data
        if isinstance(item, dict)
        and "version" in item
        and version_tuple(str(item["version"]).removeprefix("v"))[0] == major
    ]
    if not candidates:
        raise UpdateError(f"no Node {major} release found")
    return max(candidates, key=version_tuple)


def image_digest(image: str) -> str:
    try:
        result = subprocess.run(
            [
                "docker",
                "buildx",
                "imagetools",
                "inspect",
                image,
                "--format",
                "{{.Manifest.Digest}}",
            ],
            check=True,
            capture_output=True,
            text=True,
            timeout=60,
        )
    except FileNotFoundError as error:
        raise UpdateError("docker is required to resolve image digests") from error
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as error:
        detail = getattr(error, "stderr", "") or str(error)
        raise UpdateError(f"failed to inspect {image}: {detail.strip()}") from error
    match = DIGEST_RE.fullmatch(result.stdout.strip())
    if not match:
        raise UpdateError(f"invalid image digest for {image}: {result.stdout.strip()!r}")
    return match.group(1)


def pandoc_pins(current: dict[str, str]) -> list[Pin]:
    release = github_release("jgm/pandoc")
    version = stable_version(str(release.get("tag_name")), "jgm/pandoc")
    assets = {
        asset.get("name"): asset.get("digest")
        for asset in release.get("assets", [])
        if isinstance(asset, dict)
    }
    pins = [Pin("PANDOC_VERSION", current["PANDOC_VERSION"], version)]
    for architecture in ("amd64", "arm64"):
        name = f"pandoc-{version}-1-{architecture}.deb"
        match = DIGEST_RE.fullmatch(str(assets.get(name, "")))
        if not match:
            raise UpdateError(f"missing SHA-256 digest for Pandoc asset {name}")
        key = f"PANDOC_SHA256_{architecture.upper()}"
        pins.append(Pin(key, current[key], match.group(1)))
    return pins


def collect_pins(current: dict[str, str]) -> list[Pin]:
    latest_rust = rust_version()
    latest_uv = stable_version(
        str(github_release("astral-sh/uv").get("tag_name")), "astral-sh/uv"
    )
    npm = request_json("https://registry.npmjs.org/mermaid-filter/latest")
    pypi = request_json("https://pypi.org/pypi/pre-commit/json")

    pins = [
        Pin("RUST_VERSION", current["RUST_VERSION"], latest_rust),
        Pin(
            "RUST_IMAGE_SHA256",
            current["RUST_IMAGE_SHA256"],
            image_digest(f"rust:{latest_rust}-slim-trixie"),
        ),
        Pin(
            "MDBOOK_VERSION",
            current["MDBOOK_VERSION"],
            crate_version("mdbook"),
        ),
        Pin(
            "MDBOOK_MERMAID_VERSION",
            current["MDBOOK_MERMAID_VERSION"],
            crate_version("mdbook-mermaid"),
        ),
        Pin(
            "MDBOOK_PANDOC_VERSION",
            current["MDBOOK_PANDOC_VERSION"],
            crate_version("mdbook-pandoc"),
        ),
        Pin(
            "MERMAID_FILTER_VERSION",
            current["MERMAID_FILTER_VERSION"],
            stable_version(str(npm.get("version")), "npm/mermaid-filter"),
        ),
        Pin(
            "PRE_COMMIT_VERSION",
            current["PRE_COMMIT_VERSION"],
            stable_version(
                str(pypi.get("info", {}).get("version")), "PyPI/pre-commit"
            ),
        ),
        Pin(
            "PYTHON_VERSION",
            current["PYTHON_VERSION"],
            python_version(current["PYTHON_VERSION"]),
        ),
        Pin(
            "NODE_VERSION",
            current["NODE_VERSION"],
            node_version(current["NODE_VERSION"]),
        ),
        Pin("UV_VERSION", current["UV_VERSION"], latest_uv),
        Pin(
            "UV_IMAGE_SHA256",
            current["UV_IMAGE_SHA256"],
            image_digest(f"ghcr.io/astral-sh/uv:{latest_uv}"),
        ),
    ]
    pins[5:5] = pandoc_pins(current)
    return pins


def markdown_report(pins: list[Pin], now: datetime | None = None) -> str:
    changed = sum(pin.changed for pin in pins)
    marker = str(bool(changed)).lower()
    timestamp = (now or datetime.now(UTC)).strftime("%Y-%m-%d %H:%M UTC")
    lines = [
        f"<!-- toolchain-updates: {marker} -->",
        "# Toolchain update report",
        "",
        f"Checked: {timestamp}",
        "",
        f"Updates available for **{changed}** of **{len(pins)}** pins.",
        "",
        "| Pin | Current | Suggested | Status |",
        "|---|---|---|---|",
    ]
    for pin in pins:
        status = "update available" if pin.changed else "current"
        lines.append(
            f"| `{pin.name}` | `{pin.current}` | `{pin.suggested}` | {status} |"
        )
    lines.extend(
        [
            "",
            "Python suggestions stay on the configured major/minor release line; "
            "Node suggestions stay on the configured major release line.",
            "",
        ]
    )
    return "\n".join(lines)


def self_test() -> None:
    assert parse_env_text("A=1\n# comment\nB=two\n") == {"A": "1", "B": "two"}
    assert version_tuple("1.20.3") == (1, 20, 3)
    pins = [Pin("A", "1", "1"), Pin("B", "1", "2")]
    report = markdown_report(pins, datetime(2026, 1, 1, tzinfo=UTC))
    assert "<!-- toolchain-updates: true -->" in report
    assert "Updates available for **1** of **2** pins." in report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0

    try:
        current = parse_env_text(TOOLCHAIN_ENV.read_text())
        print(markdown_report(collect_pins(current)))
    except (KeyError, OSError, UpdateError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
