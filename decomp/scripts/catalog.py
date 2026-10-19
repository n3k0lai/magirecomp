#!/usr/bin/env python3
"""One unit per SECTION in src/scaffold.asm.

An INCLUDE is source. An INCBIN is still the local ROM. The cartridge header
($0100-$014F) stays out of every total. Sizes come from the scaffold spans and
are checked against the linker map when that map exists.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, replace
from pathlib import Path

from progress import ROM_SIZE, parse_number

HEADER_START = 0x100
HEADER_END = 0x150
CATEGORIES = ("code", "data", "graphics", "audio")

SECTION_RE = re.compile(
    r'^SECTION\s+"([^"]+)"\s*,\s*(ROM0|ROMX)\s*\[\s*(\$[0-9A-Fa-f]+|\d+)\s*\]'
    r"(?:\s*,\s*BANK\s*\[\s*(\d+)\s*\])?\s*$",
    re.IGNORECASE,
)
INCLUDE_RE = re.compile(r'^INCLUDE\s+"([^"]+)"\s*$', re.IGNORECASE)
INCBIN_RE = re.compile(
    r'^INCBIN\s+"([^"]+)"\s*,\s*(\$[0-9A-Fa-f]+|\d+)\s*,\s*(\$[0-9A-Fa-f]+|\d+)\s*$',
    re.IGNORECASE,
)
LABEL_RE = re.compile(r"^[A-Za-z_.][A-Za-z0-9_$#@]*:+$")
MAP_SECTION_RE = re.compile(
    r"SECTION:\s+\$([0-9A-Fa-f]+)-\$([0-9A-Fa-f]+)\s+"
    r'\(\$([0-9A-Fa-f]+) bytes?\)\s+\["((?:\\.|[^"\\])*)"\]'
)


@dataclass(frozen=True)
class Section:
    name: str
    kind: str
    source: str
    file_address: int
    span: int
    counted_address: int
    counted_size: int
    category: str

    @property
    def matched_source(self) -> bool:
        return self.kind == "include"


def strip_comment(line: str) -> str:
    quote = False
    out: list[str] = []
    for char in line:
        if char == '"':
            quote = not quote
        if char == ";" and not quote:
            break
        out.append(char)
    return "".join(out).strip()


def file_address(region: str, origin: int, bank: int | None) -> int:
    if region.upper() == "ROM0":
        if bank not in (None, 0):
            raise ValueError(f"ROM0 section cannot name bank {bank}")
        if not 0 <= origin < 0x4000:
            raise ValueError(f"ROM0 origin ${origin:04X} is outside bank 0")
        return origin
    if bank is None:
        raise ValueError("ROMX section needs a BANK")
    if not 0x4000 <= origin < 0x8000:
        raise ValueError(f"ROMX origin ${origin:04X} is outside $4000-$7FFF")
    if not 1 <= bank <= 0x1FF:
        raise ValueError(f"ROM bank {bank} is outside 1-$1FF")
    return bank * 0x4000 + (origin - 0x4000)


def counted_range(start: int, end: int) -> tuple[int, int] | None:
    """Bytes of [start, end) outside the cartridge header."""
    pieces: list[tuple[int, int]] = []
    if start < HEADER_START:
        pieces.append((start, min(end, HEADER_START)))
    if end > HEADER_END:
        pieces.append((max(start, HEADER_END), end))
    pieces = [(left, right) for left, right in pieces if right > left]
    if not pieces:
        return None
    if len(pieces) > 1:
        raise ValueError(f"${start:06X}-${end:06X} is split by the cartridge header")
    left, right = pieces[0]
    return left, right - left


def load_categories(path: Path) -> tuple[dict[int, str], dict[str, str]]:
    banks: dict[int, str] = {}
    names: dict[str, str] = {}
    if not path.is_file():
        return banks, names
    for lineno, raw in enumerate(path.read_text().splitlines(), 1):
        line = strip_comment(raw.split("#", 1)[0])
        if not line:
            continue
        if line.startswith("bank "):
            parts = line.split()
            if len(parts) != 3:
                raise ValueError(f"{path}:{lineno}: expected 'bank $30 audio'")
            category = parts[2]
            if category not in CATEGORIES:
                raise ValueError(f"{path}:{lineno}: unknown category {category}")
            banks[parse_number(parts[1])] = category
            continue
        if not line.startswith('"'):
            raise ValueError(f"{path}:{lineno}: expected a bank line or a quoted section")
        end = line.find('"', 1)
        if end < 0:
            raise ValueError(f"{path}:{lineno}: section name is missing its closing quote")
        name = line[1:end]
        category = line[end + 1 :].strip()
        if category not in CATEGORIES:
            raise ValueError(f"{path}:{lineno}: unknown category {category}")
        names[name] = category
    return banks, names


def category_for(
    name: str, start: int, end: int, banks: dict[int, str], names: dict[str, str]
) -> str:
    if name in names:
        return names[name]
    bank = start // 0x4000
    if (end - 1) // 0x4000 != bank:
        raise ValueError(f"{name} crosses a ROM bank")
    return banks.get(bank, "code")


def parse_scaffold(
    text: str,
    *,
    banks: dict[int, str],
    names: dict[str, str],
    rom_size: int = ROM_SIZE,
) -> list[Section]:
    headers: list[tuple[str, str, int, int | None]] = []
    bodies: list[list[str]] = []
    current: list[str] | None = None
    for raw in text.splitlines():
        line = strip_comment(raw)
        if not line:
            continue
        header = SECTION_RE.match(line)
        if header:
            bank = int(header.group(4)) if header.group(4) else None
            headers.append((header.group(1), header.group(2), parse_number(header.group(3)), bank))
            current = []
            bodies.append(current)
            continue
        if current is None:
            raise ValueError(f"line before the first SECTION: {line}")
        current.append(line)
    if not headers:
        raise ValueError("scaffold has no SECTION")

    placed: list[tuple[str, str, str, int, int]] = []
    seen: set[str] = set()
    for (name, region, origin, bank), lines in zip(headers, bodies, strict=True):
        if name in seen:
            raise ValueError(f"duplicate section {name}")
        seen.add(name)
        address = file_address(region, origin, bank)
        includes = [INCLUDE_RE.match(line) for line in lines if not LABEL_RE.match(line)]
        payloads = [line for line in lines if not LABEL_RE.match(line)]
        if len(payloads) != 1:
            raise ValueError(f"{name} needs one INCLUDE or one INCBIN")
        included = INCLUDE_RE.match(payloads[0])
        incbin = INCBIN_RE.match(payloads[0])
        if included:
            placed.append((name, "include", included.group(1), address, 0))
        elif re.match(r"^ds\b", payloads[0], re.IGNORECASE):
            placed.append((name, "include", "", address, 0))  # fill built from source
        elif incbin:
            if incbin.group(1) != "roms/magination.gbc":
                raise ValueError(f'{name} INCBIN path must be "roms/magination.gbc"')
            length = parse_number(incbin.group(3))
            start = parse_number(incbin.group(2))
            if start != address:
                raise ValueError(
                    f"{name} INCBIN starts at ${start:06X}, section is at ${address:06X}"
                )
            placed.append((name, "incbin", "", address, length))
        else:
            raise ValueError(f"{name} needs one INCLUDE or one INCBIN")
        del includes

    placed.sort(key=lambda item: item[3])
    sections: list[Section] = []
    for index, (name, kind, source, address, claimed) in enumerate(placed):
        end = placed[index + 1][3] if index + 1 < len(placed) else rom_size
        if end <= address:
            raise ValueError(f"{name} is not in file-address order")
        span = end - address
        if kind == "incbin" and claimed != span:
            raise ValueError(
                f"{name} INCBIN length ${claimed:X} does not cover ${span:X} bytes"
            )
        if address < HEADER_END and end > HEADER_START and kind != "incbin":
            raise ValueError(f"{name} covers the cartridge header and must stay INCBIN")
        counted = counted_range(address, end)
        if counted is None:
            counted_address, counted_size = address, 0
        else:
            counted_address, counted_size = counted
        sections.append(
            Section(
                name=name,
                kind=kind,
                source=source,
                file_address=address,
                span=span,
                counted_address=counted_address,
                counted_size=counted_size,
                category=category_for(name, address, end, banks, names),
            )
        )
    if not sections or placed[0][3] != 0:
        raise ValueError("scaffold does not start at file address $000000")
    occupied = sum(section.span for section in sections)
    if occupied != rom_size:
        raise ValueError(f"sections cover ${occupied:X} bytes, not ${rom_size:X}")
    excluded = sum(section.span - section.counted_size for section in sections)
    if excluded != HEADER_END - HEADER_START:
        raise ValueError(
            f"header exclusion is ${excluded:X} bytes, expected ${HEADER_END - HEADER_START:X}"
        )
    return sections


def unescape_map_name(text: str) -> str:
    return text.replace(r"\"", '"').replace(r"\\", "\\")


def load_map(path: Path) -> dict[str, int]:
    sizes: dict[str, int] = {}
    for line in path.read_text(errors="replace").splitlines():
        match = MAP_SECTION_RE.search(line)
        if not match:
            continue
        start = int(match.group(1), 16)
        end = int(match.group(2), 16)
        size = int(match.group(3), 16)
        if end - start + 1 != size:
            raise ValueError(f"map size for {match.group(4)} does not match its range")
        name = unescape_map_name(match.group(4))
        if name in sizes:
            raise ValueError(f"map repeats section {name}")
        sizes[name] = size
    if not sizes:
        raise ValueError(f"{path} has no SECTION lines")
    return sizes


def check_map(sections: list[Section], sizes: dict[str, int]) -> None:
    names = {section.name for section in sections}
    missing = [section.name for section in sections if section.name not in sizes]
    # A header-only section is omitted from `sections` but still belongs in the map.
    # Callers pass every scaffold name, including omitted ones, via the map check
    # against the sections that were counted. Extra map names are reported too.
    extra = sorted(set(sizes) - names)
    if missing or extra:
        detail = ""
        if missing:
            detail += " missing " + ", ".join(missing)
        if extra:
            detail += " extra " + ", ".join(extra)
        raise ValueError("linker map does not match the scaffold:" + detail)
    for section in sections:
        # The last section of a bank may stop short: rgblink fills the rest
        # of the bank (counted as done data, as Alchemy counts linker fill).
        end = section.file_address + section.span
        if sizes[section.name] < section.span and end % 0x4000 == 0:
            continue
        if sizes[section.name] != section.span:
            raise ValueError(
                f"{section.name} map size ${sizes[section.name]:X} "
                f"is not the scaffold span ${section.span:X}"
            )


def load(root: Path, *, rom_size: int = ROM_SIZE) -> list[Section]:
    banks, names = load_categories(root / "config" / "categories.txt")
    text = (root / "src" / "scaffold.asm").read_text()
    sections = parse_scaffold(text, banks=banks, names=names, rom_size=rom_size)
    return [classify(root, s, banks, names) for s in sections]


def classify(root: Path, section: Section, banks: dict[int, str], names: dict[str, str]) -> Section:
    """A section no category line names is code only when instructions are
    most of its source bytes (progress.py's count); otherwise data."""
    if section.name in names or section.file_address // 0x4000 in banks:
        return section
    if section.kind != "include" or not section.source:
        # An INCBIN no call, jump or far call lands in (scripts/xref.py) is
        # data until a flow reference proves code there; ds fill is data.
        return replace(section, category="data")
    import progress  # noqa: PLC0415  (progress imports nothing from here)

    code, _ = progress.Counter.for_root(root).file(section.source)
    category = "code" if code * 2 >= max(1, section.counted_size) else "data"
    return replace(section, category=category)
