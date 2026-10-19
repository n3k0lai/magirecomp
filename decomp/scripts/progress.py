#!/usr/bin/env python3
"""DONE code and DONE data, counted from committed source (AGENTS.md C1-C3).

    progress.py [--project NAME] [--banks] [--record] [--check-map]

A byte is done when committed source outside an INCBIN assembles to it.
DONE code is the bytes of instructions (each line's length from its text,
macros expanded); DONE data is every other done byte, with `ds` fill shown
apart. The cartridge header stays INCBIN and is left out of the totals.

It also counts the humanizing debt, the way Alchemy counts its tagged
devices (C3): placeholder labels (`sub_`, `unk_`), raw `$XXXX` flow targets
in lifted code, and `; DEVICE:` tags. These may only fall.

--record appends one row to docs/progress-history.tsv (commit, date, figures).
--check-map compares the text count with the linker map for sections that
are pure code, so a wrong length rule shows up as a test failure.
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import rom as R  # noqa: E402
from lib.asmlen import length, strip  # noqa: E402

DATA_DIRECTIVE = re.compile(r"^(db|dw|dl|ds|incbin)\b", re.I)
DS = re.compile(r"^ds\s+(\$[0-9A-Fa-f]+|\d+)\s*(?:,|$)", re.I)
MACRO_START = re.compile(r"^\s*MACRO\s+(\w+)", re.I)
MACRO_END = re.compile(r"^\s*ENDM\b", re.I)
PLACEHOLDER = re.compile(r"^(sub|unk)_[0-9A-F]{6}::?", re.M)
RAW_FLOW = re.compile(r"^\s*(?:call|jp|jr)\s+(?:(?:nz|z|nc|c)\s*,\s*)?\$[0-9A-Fa-f]{4}\b", re.I | re.M)
DEVICE = re.compile(r";\s*DEVICE:", re.I)
HISTORY = R.ROOT / "docs" / "progress-history.tsv"
ROM_SIZE = 2_097_152  # magination; report.py and catalog.py read these three


def parse_number(text: str) -> int:
    return int(text[1:], 16) if text.startswith("$") else int(text)


def rewritten_bytes(root: Path) -> int:
    """Bytes outside INCBIN, header included in the INCBIN side (report.py)."""
    text = (root / "src" / "scaffold.asm").read_text()
    return ROM_SIZE - sum(e - s for sec in R.sections(text) for s, e, _ in sec.incbins)


def num(tok: str) -> int | None:
    try:
        return int(tok[1:], 16) if tok.startswith("$") else int(tok)
    except ValueError:
        return None


class Counter:
    def __init__(self, p: R.Project):
        self.p = p
        self.macros: dict[str, list[str]] = {}
        for path in sorted(p.src.rglob("*")):
            if path.suffix in (".asm", ".inc"):
                self._macros(path.read_text(errors="replace"))

    _cache: dict = {}

    @classmethod
    def for_root(cls, root: Path) -> "Counter":
        if root not in cls._cache:
            cls._cache[root] = cls(R.project("magination"))
        return cls._cache[root]

    def _macros(self, text: str) -> None:
        name, body = None, []
        for line in text.splitlines():
            m = MACRO_START.match(line)
            if m:
                name, body = m.group(1), []
                continue
            if name and MACRO_END.match(line):
                self.macros[name] = body
                name = None
                continue
            if name:
                body.append(line)

    def lines(self, lines, depth=0):
        """(code bytes, fill bytes) of these source lines."""
        code = fill = 0
        in_macro = False
        for raw in lines:
            if MACRO_START.match(raw):
                in_macro = True
                continue
            if in_macro:
                in_macro = not MACRO_END.match(raw)
                continue
            n = length(raw)
            if n is not None:
                code += n
                continue
            text = strip(raw)
            if not text:
                continue
            m = DS.match(text)
            if m:
                fill += num(m.group(1)) or 0
                continue
            word = text.split(None, 1)[0]
            if word in self.macros and depth < 4:
                c, f = self.lines(self.macros[word], depth + 1)
                code += c
                fill += f
        return code, fill

    def file(self, rel: str, seen=None):
        seen = seen or set()
        path = R.ROOT / rel
        if rel in seen or not path.exists() or rel.startswith("out/"):
            return 0, 0
        seen.add(rel)
        text = path.read_text(errors="replace")
        code, fill = self.lines(text.splitlines())
        for m in re.finditer(r'^\s*INCLUDE\s+"([^"]+)"', text, re.M):
            inc = m.group(1)
            if inc.endswith(".inc"):
                continue  # macro and constant files emit nothing by themselves
            c, f = self.file(inc, seen)
            code += c
            fill += f
        return code, fill


def measure(p: R.Project, text: str | None = None) -> dict:
    text = text if text is not None else p.scaffold.read_text()
    size = p.size
    hs, lo = p.header
    banks = defaultdict(lambda: {"code": 0, "fill": 0, "incbin": 0})
    counter = Counter(p)
    placeholders = raw_flow = devices = 0
    for sec in R.sections(text):
        bank = sec.addr >> 14
        for s, e, _ in sec.incbins:
            a = s
            while a < e:
                end = min(e, ((a >> 14) + 1) << 14)
                banks[a >> 14]["incbin"] += end - a
                a = end
        for inc in sec.includes:
            c, f = counter.file(inc)
            banks[bank]["code"] += c
            banks[bank]["fill"] += f
            path = R.ROOT / inc
            if path.exists():
                body = path.read_text(errors="replace")
                placeholders += len(PLACEHOLDER.findall(body))
                raw_flow += len(RAW_FLOW.findall(body))
                devices += len(DEVICE.findall(body))
    nbanks = max(1, size // 0x4000)
    rows = []
    for b in range(nbanks):
        v = banks[b]
        total = 0x4000 - (lo - hs if b == 0 else 0)
        incbin = v["incbin"] - (lo - hs if b == 0 else 0)
        done = total - incbin
        code = min(v["code"], done)
        fill = min(v["fill"], done - code)
        rows.append({"bank": b, "total": total, "done": done, "code": code,
                     "fill": fill, "data": done - code - fill, "incbin": incbin})
    tot = {k: sum(r[k] for r in rows) for k in ("total", "done", "code", "fill", "data", "incbin")}
    return {"rows": rows, "total": tot, "placeholders": placeholders,
            "raw_flow": raw_flow, "devices": devices}


def check_map(p: R.Project) -> int:
    """Pure-code sections: text count must equal the linker's size."""
    sizes = R.map_sections(p)
    counter = Counter(p)
    bad = checked = 0
    for sec in R.sections(p.scaffold.read_text()):
        if len(sec.includes) != 1 or sec.incbins or sec.title not in sizes:
            continue
        path = R.ROOT / sec.includes[0]
        if not path.exists():
            continue
        lines = path.read_text(errors="replace").splitlines()
        emitting = [l for l in lines if strip(l) and length(l) is None
                    and (DATA_DIRECTIVE.match(strip(l)) or strip(l).split()[0] in counter.macros
                         or re.match(r"^(rept|for|if|include)\b", strip(l), re.I))]
        if emitting:
            continue
        checked += 1
        code, _ = counter.lines(lines)
        if code != sizes[sec.title][1]:
            bad += 1
            if bad <= 10:
                print(f"{sec.includes[0]}: text count {code}, map {sizes[sec.title][1]}", file=sys.stderr)
    print(f"check-map: {checked} pure-code sections, {bad} disagree")
    return 1 if bad else 0


def pct(a: int, b: int) -> str:
    return f"{100.0 * a / b:.2f}%" if b else "n/a"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", default="magination")
    ap.add_argument("--banks", action="store_true")
    ap.add_argument("--record", action="store_true")
    ap.add_argument("--check-map", action="store_true")
    args = ap.parse_args()
    p = R.project(args.project)
    if args.check_map:
        return check_map(p)
    try:
        m = measure(p)
    except OSError as e:
        print(e, file=sys.stderr)
        return 1
    t = m["total"]
    print(f"{p.name}: DONE {t['done']:,} / {t['total']:,} bytes ({pct(t['done'], t['total'])}), "
          f"{t['incbin']:,} still INCBIN")
    print(f"  DONE code {t['code']:,} bytes ({pct(t['code'], t['total'])} of the image)")
    print(f"  DONE data {t['data'] + t['fill']:,} bytes ({pct(t['data'] + t['fill'], t['total'])}), "
          f"of which {t['fill']:,} is ds fill")
    print(f"  humanizing debt: {m['placeholders']} placeholder labels, "
          f"{m['raw_flow']} raw $XXXX flow targets, {m['devices']} DEVICE tags")
    if args.banks:
        print("\nbank   code    data    fill  incbin  done")
        for r in m["rows"]:
            if r["done"] or r["incbin"]:
                print(f"${r['bank']:02X} {r['code']:7,} {r['data']:7,} {r['fill']:7,} "
                      f"{r['incbin']:7,}  {pct(r['done'], r['total'])}")
    if args.record:
        head = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=R.ROOT,
                              capture_output=True, text=True).stdout.strip()
        new = not HISTORY.exists()
        HISTORY.parent.mkdir(exist_ok=True)
        with HISTORY.open("a") as f:
            if new:
                f.write("date\tcommit\tproject\tdone\tcode\tdata\tfill\tincbin\tplaceholders\traw_flow\tdevices\n")
            f.write(f"{dt.datetime.now().astimezone().isoformat(timespec='seconds')}\t{head}\t{p.name}\t"
                    f"{t['done']}\t{t['code']}\t{t['data']}\t{t['fill']}\t{t['incbin']}\t"
                    f"{m['placeholders']}\t{m['raw_flow']}\t{m['devices']}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
