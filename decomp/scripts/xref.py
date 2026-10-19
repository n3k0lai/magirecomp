#!/usr/bin/env python3
"""Cross-references from committed source to ROM file addresses (AGENTS.md T2).

    xref.py [--project NAME] [--holes] [--target ADDR] [--tsv FILE]

Every call, jump, far call (`CallBankedHL` with HL and E known) and 16-bit
pointer load in lifted code becomes one row: target file address, kind,
the file and line that make it, and the global routine around that line.
A $4000-$7FFF target takes the bank last stored to rROMB0 in that routine,
else the routine's own ROMX bank; a ROM0 routine that stored no bank gives no
row (the bank is unknown, and we do not guess it).

The worker uses these rows as evidence: code is lifted only where a flow
row lands (W3), a table only where a pointer row lands (W4), and context
packs quote the reading lines (W6). --holes keeps rows whose target is
still INCBIN.
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import rom as R  # noqa: E402

FLOW = re.compile(r"^\s*(call|jp|jr)\s+(?:(?:nz|z|nc|c)\s*,\s*)?([A-Za-z_][\w.]*|\$[0-9A-Fa-f]{1,4})\s*$", re.I)
LD16 = re.compile(r"^\s*ld\s+(hl|de|bc)\s*,\s*([A-Za-z_][\w.]*|\$[0-9A-Fa-f]{4})\s*$", re.I)
LD8 = re.compile(r"^\s*ld\s+([ae])\s*,\s*(\$[0-9A-Fa-f]{1,2}|\d+|[A-Za-z_]\w*)\s*$", re.I)
BANKSTORE = re.compile(r"^\s*ld\s+\[\s*(rROMB0|\$2[0-9A-Fa-f]{3}|\$3[0-9A-Fa-f]{3})\s*\]\s*,\s*a\s*$", re.I)
GLOBAL = re.compile(r"^([A-Za-z_]\w*)::?")
FAR = {"CallBankedHL"}


@dataclass
class Ref:
    target: int
    kind: str      # call | jump | far | pointer
    file: str
    line: int
    routine: str
    text: str
    token: str = ""


def value(tok: str, consts: dict, names: dict):
    if tok.startswith("$"):
        return int(tok[1:], 16), False
    if tok.isdigit():
        return int(tok), False
    if tok in consts:
        return consts[tok], False
    if tok in names:
        return names[tok], True  # already a file address
    return None, False


def collect(p: R.Project) -> list[Ref]:
    consts = R.constants(p)
    names = R.names(p)
    refs: list[Ref] = []
    for f, bank in R.unit_banks(p, p.scaffold.read_text()).items():
        path = R.ROOT / f
        if not path.exists() or f.startswith("out/"):
            continue
        routine = "?"
        stored = None
        a_val = None
        hl_val = e_val = None
        for n, raw in enumerate(path.read_text(errors="replace").splitlines(), 1):
            line = raw.split(";", 1)[0].rstrip()
            g = GLOBAL.match(line)
            if g:
                routine, stored, a_val, hl_val, e_val = g.group(1), None, None, None, None
            m = LD8.match(line)
            if m:
                v, _ = value(m.group(2), consts, {})
                if m.group(1).lower() == "a":
                    a_val = v
                else:
                    e_val = v
                continue
            if BANKSTORE.match(line):
                stored = a_val
                continue

            def resolve(tok):
                v, is_file = value(tok, consts, names)
                if v is None:
                    return None
                if is_file:
                    return v
                if v < 0x4000:
                    return v
                if v < 0x8000:
                    b = stored if stored else (bank or None)
                    return R.file_of(b, v) if b else None
                return None

            m = LD16.match(line)
            if m:
                tok = m.group(2)
                fa = resolve(tok)
                if m.group(1).lower() == "hl":
                    hl_val = value(tok, consts, names)
                if fa is not None and fa >= 0x150:
                    refs.append(Ref(fa, "pointer", f, n, routine, raw.strip(), tok))
                continue
            m = FLOW.match(line)
            if not m:
                continue
            tok = m.group(2)
            if tok.startswith("."):
                continue
            if tok in FAR:
                (v, is_file) = hl_val or (None, False)
                if v is not None and e_val is not None and not is_file:
                    cpu = v
                    if 0x4000 <= cpu < 0x8000 and 0 < e_val < (p.size >> 14):
                        refs.append(Ref(R.file_of(e_val, cpu), "far", f, n, routine, raw.strip(), ""))
                hl_val = e_val = None
                continue
            fa = resolve(tok)
            if fa is not None:
                kind = "call" if m.group(1).lower() == "call" else "jump"
                refs.append(Ref(fa, kind, f, n, routine, raw.strip(), tok))
    return refs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", default="magination")
    ap.add_argument("--holes", action="store_true")
    ap.add_argument("--target")
    ap.add_argument("--tsv")
    args = ap.parse_args()
    p = R.project(args.project)
    refs = collect(p)
    hs = R.holes(p.scaffold.read_text())
    if args.holes:
        refs = [r for r in refs if R.hole_for(r.target, hs)]
    if args.target:
        t = int(args.target.lstrip("$"), 16)
        refs = [r for r in refs if r.target == t]
    rows = [f"{r.target:06X}\t{r.kind}\t{r.file}:{r.line}\t{r.routine}\t{r.text}" for r in
            sorted(refs, key=lambda r: (r.target, r.file, r.line))]
    if args.tsv:
        Path(args.tsv).write_text("target\tkind\tsite\troutine\ttext\n" + "\n".join(rows) + "\n")
    else:
        print("\n".join(rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
