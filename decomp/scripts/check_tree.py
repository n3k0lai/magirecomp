#!/usr/bin/env python3
"""Refuse a tree that copies a ROM or the Nintendo boot logo.

The logo scan reads roms/magination.gbc at check time. A slice worktree
does not contain that gitignored file, so the scan uses the copy in the
main checkout. The logo bytes are not stored in this file.
"""

import hashlib
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import coverage  # noqa: E402

LOGO_START = 0x104
LOGO_LEN = 48

FORBIDDEN_SHA1 = {
    "9972a7bca43210b4b6c0b3f6ee5d1957a865e12d": "Magi Nation (USA)",
    "7c6b427810be2f0d7496ccb5eff2226d3ed1194e": "Magi-Nation: Keeper's Quest",
}

FORBIDDEN_SUFFIXES = {
    ".gb",
    ".gbc",
    ".gba",
    ".nes",
    ".sfc",
    ".smc",
    ".z64",
    ".nds",
}


def repo_root() -> Path:
    # This tree lives in decomp/ of a larger repository; check it, not the
    # whole checkout.
    return Path(__file__).resolve().parents[1]


def tracked_files(root: Path) -> list[str]:
    output = subprocess.check_output(["git", "ls-files", "-z"], cwd=root)
    return [name.decode() for name in output.split(b"\0") if name]


def forbidden_path(rel: str) -> bool:
    if rel.startswith(("disassembly/", "out/")):
        return True
    return rel.startswith("roms/") and rel != "roms/README.md"


BYTE_LITERAL = re.compile(rb"(?:\$|0x)([0-9a-fA-F]{2})(?![0-9a-fA-F])")
HEX_RUN = re.compile(rb"[0-9a-fA-F]{96,}")


def magination_rom(root: Path) -> Path:
    """Return the local Magi-Nation image used for the logo scan."""
    direct = root / "roms" / "magination.gbc"
    if direct.is_file():
        return direct
    try:
        common = subprocess.check_output(
            [
                "git",
                "-C",
                str(root),
                "rev-parse",
                "--path-format=absolute",
                "--git-common-dir",
            ],
            text=True,
        ).strip()
    except (subprocess.CalledProcessError, OSError):
        return direct
    shared = Path(common).resolve().parent / "roms" / "magination.gbc"
    if shared.is_file():
        return shared
    return direct


def contains_logo(contents: bytes, logo: bytes) -> bool:
    if logo in contents:
        return True
    literals = bytes(int(match.group(1), 16) for match in BYTE_LITERAL.finditer(contents))
    if logo in literals:
        return True
    digest = logo.hex().encode()
    return any(digest in run.lower() for run in HEX_RUN.findall(contents))


def main() -> int:
    root = repo_root()
    failures: list[str] = []
    files = tracked_files(root)

    for rel in files:
        path = root / rel
        if forbidden_path(rel):
            failures.append(f"{rel}: this path stays out of the repository")
        if Path(rel).suffix.lower() in FORBIDDEN_SUFFIXES:
            failures.append(f"{rel}: ROM images stay out of the repository")
        if not path.is_file():
            continue
        digest = hashlib.sha1(path.read_bytes()).hexdigest()
        name = FORBIDDEN_SHA1.get(digest)
        if name is not None:
            failures.append(f"{rel}: SHA-1 matches {name}")

    failures.extend(coverage.layout_errors(root))

    rom = magination_rom(root)
    if not rom.is_file():
        failures.append(
            "missing roms/magination.gbc; the logo scan reads the local ROM"
        )
    else:
        data = rom.read_bytes()
        if len(data) < LOGO_START + LOGO_LEN:
            failures.append("roms/magination.gbc is too small to contain the boot logo")
        else:
            logo = data[LOGO_START : LOGO_START + LOGO_LEN]
            for rel in files:
                path = root / rel
                if not path.is_file():
                    continue
                if contains_logo(path.read_bytes(), logo):
                    failures.append(f"{rel}: contains the Nintendo boot logo")

    if failures:
        print("publication check failed:", file=sys.stderr)
        for item in failures:
            print(f"  {item}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
