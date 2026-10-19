#!/usr/bin/env python3
"""INCBIN ranges under src/. Shared by the publication check and overnight loop."""

from __future__ import annotations

import re
from pathlib import Path

ROM_SIZE = 2_097_152
LOGO_START = 0x104
LOGO_END = 0x134
HEADER_START = 0x100
HEADER_END = 0x150

SIZED_INCBIN = re.compile(
    r'INCBIN\s+"([^"]+)"\s*,\s*(\$[0-9A-Fa-f]+|\d+)\s*,\s*(\$[0-9A-Fa-f]+|\d+)',
    re.IGNORECASE,
)
ANY_INCBIN = re.compile(r"\bINCBIN\b", re.IGNORECASE)
# Graphics built from committed PNGs by rgbgfx (AGENTS.md S2). These are
# source, not ROM bytes, so they carry no range.
GENERATED_INCBIN = re.compile(r'INCBIN\s+"out/gfx/([A-Za-z0-9_]+)\.([12])bpp"\s*$', re.IGNORECASE | re.M)


def generated_png(root: Path, name: str, bpp: str) -> Path:
    return root / "gfx" / (f"{name}.png" if bpp == "2" else f"{name}.1bpp.png")


def parse_number(text: str) -> int:
    if text.startswith("$"):
        return int(text[1:], 16)
    if text.lower().startswith("0x"):
        return int(text, 16)
    return int(text, 10)


def code_without_comments(text: str) -> str:
    return "\n".join(line.split(";", 1)[0] for line in text.splitlines())


def asm_files(root: Path) -> list[Path]:
    src = root / "src"
    if not src.is_dir():
        return []
    return sorted(
        path
        for path in src.rglob("*")
        if path.is_file() and path.suffix.lower() in {".asm", ".inc"}
    )


def ranges_in_text(text: str) -> tuple[list[tuple[int, int]], list[str]]:
    """Return half-open file ranges and errors for one assembly text."""
    errors: list[str] = []
    ranges: list[tuple[int, int]] = []
    code = code_without_comments(text)
    sized = list(SIZED_INCBIN.finditer(code))
    generated = len(GENERATED_INCBIN.findall(code))
    if len(sized) + generated != len(ANY_INCBIN.findall(code)):
        errors.append("every INCBIN needs a start and a length")
    for match in sized:
        path, start_text, length_text = match.group(1), match.group(2), match.group(3)
        if path != "roms/magination.gbc":
            errors.append(f'INCBIN path must be "roms/magination.gbc", found "{path}"')
        try:
            start = parse_number(start_text)
            length = parse_number(length_text)
        except ValueError:
            errors.append(f"bad INCBIN operand {start_text}, {length_text}")
            continue
        end = start + length
        if start < 0 or length < 0 or end > ROM_SIZE:
            errors.append(f"INCBIN ${start:x}+${length:x} leaves the {ROM_SIZE}-byte ROM")
            continue
        ranges.append((start, end))
    return ranges, errors


def collect(root: Path) -> tuple[list[tuple[int, int]], list[str], int]:
    """Ranges, errors, and the total included length for every file under src/."""
    ranges: list[tuple[int, int]] = []
    errors: list[str] = []
    for path in asm_files(root):
        text = path.read_text()
        found, file_errors = ranges_in_text(text)
        rel = path.relative_to(root)
        for name, bpp in GENERATED_INCBIN.findall(code_without_comments(text)):
            if not generated_png(root, name, bpp).is_file():
                file_errors.append(f"generated graphics {name} has no gfx/ PNG")
        errors.extend(f"{rel}: {error}" for error in file_errors)
        ranges.extend(found)
    if overlapping(ranges):
        errors.append("INCBIN ranges overlap")
    included = sum(end - start for start, end in ranges)
    if included > ROM_SIZE:
        errors.append(f"INCBIN covers {included} bytes, past the {ROM_SIZE}-byte ROM")
    return ranges, errors, included


def overlapping(ranges: list[tuple[int, int]]) -> bool:
    ordered = sorted(ranges)
    return any(ordered[i][0] < ordered[i - 1][1] for i in range(1, len(ordered)))


def covers(ranges: list[tuple[int, int]], start: int, end: int) -> bool:
    cursor = start
    for left, right in sorted(ranges):
        if right <= cursor:
            continue
        if left > cursor:
            return False
        cursor = right
        if cursor >= end:
            return True
    return cursor >= end


def layout_errors(root: Path) -> list[str]:
    ranges, errors, _included = collect(root)
    if not covers(ranges, LOGO_START, LOGO_END):
        errors.append(
            "Nintendo boot logo ($0104-$0133) must stay inside an INCBIN of the local ROM"
        )
    if not covers(ranges, HEADER_START, HEADER_END):
        errors.append(
            "cartridge header ($0100-$014F) must stay inside an INCBIN of the local ROM"
        )
    return errors


def containing(ranges: list[tuple[int, int]], address: int) -> tuple[int, int] | None:
    for start, end in ranges:
        if start <= address < end:
            return start, end
    return None
