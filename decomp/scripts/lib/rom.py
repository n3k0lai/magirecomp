"""Project layout, scaffold, symbols and addresses for every tool.

One place reads the scaffold, the map and the symbol file, so the worker,
`make progress`, the lifter and the checks agree on what is source and what is
still INCBIN (AGENTS.md T1). Nothing here writes to the tree.
"""

from __future__ import annotations

import re
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

SECTION_RE = re.compile(
    r'^SECTION\s+"([^"]+)"\s*,\s*(ROM0|ROMX)\[\$([0-9A-Fa-f]+)\](?:\s*,\s*BANK\[(\$?[0-9A-Fa-f]+)\])?')
INCBIN_RE = re.compile(
    r'^\s*INCBIN\s+"([^"]+)"\s*,\s*\$([0-9A-Fa-f]+)\s*,\s*\$([0-9A-Fa-f]+)\s*$')
INCLUDE_RE = re.compile(r'^\s*INCLUDE\s+"([^"]+)"')
SYM_RE = re.compile(r"^([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) (\S+)$")
MAP_SECTION_RE = re.compile(
    r'\s*SECTION: \$([0-9a-f]{4})(?:-\$([0-9a-f]{4}))? \(\$([0-9a-f]{4}) bytes?\) \["(.*)"\]')
MAP_BANK_RE = re.compile(r"^ROM([0X]) bank #(\d+)")


@dataclass
class Project:
    name: str
    rom: Path
    scaffold: Path
    out: Path
    sym: Path
    map: Path
    sha1: Path
    src: Path
    header: tuple[int, int] = (0x100, 0x150)
    rom_ref: str = "roms/magination.gbc"  # path as written in INCBIN lines
    state: Path = field(default_factory=lambda: ROOT / "overnight" / "own")

    @property
    def size(self) -> int:
        return self.rom.stat().st_size


def project(name: str = "magination") -> Project:
    if name == "magination":
        return Project(
            name, ROOT / "roms/magination.gbc", ROOT / "src/scaffold.asm",
            ROOT / "out/magination.gbc", ROOT / "out/magination.sym",
            ROOT / "out/magination.map", ROOT / "rom.sha1", ROOT / "src")
    base = ROOT / "projects" / name
    mk = (base / "build.mk").read_text()

    def var(key: str) -> Path:
        m = re.search(rf"^{key}\s*:=\s*(\S+)", mk, re.M)
        if not m:
            raise SystemExit(f"{base}/build.mk has no {key}")
        return ROOT / m.group(1)

    rom = var("ROM")
    return Project(
        name, rom, var("ASM"), var("OUT"), var("SYM"), var("MAP"), var("SHA1"),
        var("ASM").parent, rom_ref=str(rom.relative_to(ROOT)),
        state=base / "overnight" / "own")


# ---------------------------------------------------------------- addresses

def cpu_of(addr: int) -> tuple[int, int]:
    bank = addr >> 14
    return bank, (addr if bank == 0 else 0x4000 + (addr & 0x3FFF))


def file_of(bank: int, cpu: int) -> int:
    return cpu if cpu < 0x4000 else bank * 0x4000 + (cpu - 0x4000)


def section_spec(addr: int) -> str:
    bank, cpu = cpu_of(addr)
    return f"ROM0[${cpu:04X}]" if bank == 0 else f"ROMX[${cpu:04X}], BANK[{bank}]"


def parse_bank(tok: str | None) -> int:
    if not tok:
        return 0
    return int(tok[1:], 16) if tok.startswith("$") else int(tok)


# ---------------------------------------------------------------- scaffold

@dataclass
class Section:
    title: str
    addr: int          # file address
    line: int          # line index of SECTION in the scaffold
    includes: list[str] = field(default_factory=list)
    incbins: list[tuple[int, int, int]] = field(default_factory=list)  # (start, end, line)


def scaffold_text(p: Project, committed: bool = True) -> str:
    """The committed scaffold by default: a concurrent splice may hold a
    half-edited working copy for a few seconds under the lock."""
    if committed:
        rel = p.scaffold.relative_to(ROOT)
        r = subprocess.run(["git", "show", f"HEAD:./{rel}"], cwd=ROOT,
                           capture_output=True, text=True)
        if r.returncode == 0:
            return r.stdout
    return p.scaffold.read_text()


def sections(text: str) -> list[Section]:
    out: list[Section] = []
    for i, line in enumerate(text.split("\n")):
        m = SECTION_RE.match(line)
        if m:
            bank = 0 if m.group(2) == "ROM0" else parse_bank(m.group(4))
            out.append(Section(m.group(1), file_of(bank, int(m.group(3), 16)), i))
            continue
        if not out:
            continue
        m = INCLUDE_RE.match(line)
        if m:
            out[-1].includes.append(m.group(1))
            continue
        m = INCBIN_RE.match(line)
        if m:
            s, n = int(m.group(2), 16), int(m.group(3), 16)
            out[-1].incbins.append((s, s + n, i))
    return out


def holes(text: str) -> list[dict]:
    """INCBIN ranges: dict(start, end, line, section_line)."""
    res = []
    for sec in sections(text):
        for s, e, line in sec.incbins:
            res.append({"start": s, "end": e, "line": line, "section_line": sec.line})
    return res


def hole_for(addr: int, hs: list[dict]):
    for h in hs:
        if h["start"] <= addr < h["end"]:
            return h
    return None


# ---------------------------------------------------------------- symbols

def symbols(p: Project) -> dict[int, str]:
    """file address -> preferred label (global over local over ...End)."""
    rank: dict[int, tuple[int, str]] = {}
    if not p.sym.exists():
        return {}
    for line in p.sym.read_text().splitlines():
        m = SYM_RE.match(line)
        if not m:
            continue
        bank, cpu, name = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
        if cpu >= 0x8000:
            continue
        fa = file_of(bank, cpu)
        r = 2 if name.endswith("End") else 1 if "." in name else 0
        if fa not in rank or r < rank[fa][0]:
            rank[fa] = (r, name)
    return {a: n for a, (r, n) in rank.items()}


def names(p: Project) -> dict[str, int]:
    """label -> file address, every label in the symbol file."""
    res = {}
    if p.sym.exists():
        for line in p.sym.read_text().splitlines():
            m = SYM_RE.match(line)
            if m:
                res[m.group(3)] = file_of(int(m.group(1), 16), int(m.group(2), 16))
    return res


def constants(p: Project) -> dict[str, int]:
    """DEF NAME EQU $xxxx across the project's source."""
    rx = re.compile(r"^\s*DEF\s+(\w+)\s+EQU\s+\$([0-9A-Fa-f]+)\b", re.M)
    res = {}
    for path in sorted(p.src.rglob("*")):
        if path.suffix in (".asm", ".inc"):
            for m in rx.finditer(path.read_text(errors="replace")):
                res.setdefault(m.group(1), int(m.group(2), 16))
    return res


def ram_names(p: Project) -> dict[int, str]:
    res: dict[int, str] = {}
    for n, v in constants(p).items():
        if v >= 0x8000:
            res.setdefault(v, n)
    return res


def map_sections(p: Project) -> dict[str, tuple[int, int]]:
    """section title -> (file address, size) from the last build's map."""
    res = {}
    if not p.map.exists():
        return res
    bank = 0
    for line in p.map.read_text().splitlines():
        b = MAP_BANK_RE.match(line)
        if b:
            bank = int(b.group(2))
            continue
        m = MAP_SECTION_RE.match(line)
        if m:
            res[m.group(4)] = (file_of(bank, int(m.group(1), 16)), int(m.group(3), 16))
    return res


def unit_banks(p: Project, text: str | None = None) -> dict[str, int]:
    """source file -> bank of the section that INCLUDEs it."""
    res = {}
    for sec in sections(text if text is not None else scaffold_text(p)):
        for inc in sec.includes:
            res[inc] = sec.addr >> 14
    return res
