#!/usr/bin/env python3
"""Symbol propagation: put label names where numbers stand for them (AGENTS.md T3, O2).

    propagate.py [--project NAME] [--dry-run]

Two byte-identical rewrites, each decided from xref.py's resolution of the
operand at its own line (bank state included), never from the number alone:

- a `DEF NAME EQU $XXXX` whose every flow or pointer use in its file resolves
  to the same lifted global label becomes that label: the DEF line goes and
  NAME is replaced in that file. A DEF used any other way stays.
- a raw `call/jp/jr $XXXX` or `ld r16, $XXXX` whose target resolves to a lifted
  global label takes the label on that line. Pointer loads change only when
  a label starts exactly there; a number that merely equals an address is
  left alone unless the routine reads through it.

The worker builds and compares afterwards; nothing is kept unless the image
still matches (W2).
"""

from __future__ import annotations

import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import rom as R  # noqa: E402
import xref  # noqa: E402

DEF = re.compile(r"^\s*DEF\s+(\w+)\s+EQU\s+\$([0-9A-Fa-f]{4})\b[^\n]*\n", re.M)


def drop_def(text: str, name: str) -> str:
    """Remove the DEF line, and a one-line comment that only described it
    (blank line above it, blank line after the DEF)."""
    lines = text.split("\n")
    for i, l in enumerate(lines):
        if re.match(rf"^\s*DEF\s+{name}\s+EQU\b", l):
            lo = i
            above_blank = i >= 2 and not lines[i - 2].strip() or i == 1
            if (i >= 1 and lines[i - 1].lstrip().startswith(";") and above_blank
                    and (i + 1 >= len(lines) or not lines[i + 1].strip())):
                lo = i - 1
            hi = i + 1
            if lo > 0 and not lines[lo - 1].strip() and hi < len(lines) and not lines[hi].strip():
                hi += 1  # do not leave two blank lines behind
            return "\n".join(lines[:lo] + lines[hi:])
    return text


def global_labels(p: R.Project) -> dict[int, str]:
    at: dict[int, str] = {}
    for n, a in sorted(R.names(p).items()):
        if "." not in n and not n.endswith("End") and not n.startswith("ROM"):
            at.setdefault(a, n)
    return at


def plan(p: R.Project):
    refs = xref.collect(p)
    labels = global_labels(p)
    by_file = defaultdict(list)
    for r in refs:
        by_file[r.file].append(r)
    elsewhere = defaultdict(set)  # name -> files that mention it
    for g in R.unit_banks(p, p.scaffold.read_text()):
        gp = R.ROOT / g
        if gp.exists() and not g.startswith("out/"):
            for tok in set(re.findall(r"\b[A-Za-z_]\w*\b", gp.read_text(errors="replace"))):
                elsewhere[tok].add(g)
    for gp in p.src.rglob("*.inc"):
        for tok in set(re.findall(r"\b[A-Za-z_]\w*\b", gp.read_text(errors="replace"))):
            elsewhere[tok].add(str(gp.relative_to(R.ROOT)))
    edits = {}  # file -> new text
    stats = {"defs": 0, "raw": 0}
    for f, rs in by_file.items():
        path = R.ROOT / f
        text = path.read_text()
        lines = text.split("\n")
        defs = {m.group(1): int(m.group(2), 16) for m in DEF.finditer(text)}
        # raw operands, line by line
        changed = False
        for r in rs:
            if not r.token.startswith("$") or r.target not in labels:
                continue
            if r.kind == "far":
                continue
            lab = labels[r.target]
            i = r.line - 1
            new = re.sub(rf"\{re.escape(r.token)}\b", lab, lines[i], count=1)
            if new != lines[i]:
                lines[i] = new
                stats["raw"] += 1
                changed = True
        text2 = "\n".join(lines) if changed else text
        # DEF aliases
        for name, value in defs.items():
            uses = [r for r in rs if r.token == name]
            if not uses:
                continue
            targets = {r.target for r in uses}
            if len(targets) != 1:
                continue
            fa = targets.pop()
            lab = labels.get(fa)
            if not lab or lab == name or elsewhere[name] - {f}:
                continue
            code = [l.split(";", 1)[0] for l in text2.split("\n")]
            occurrences = sum(len(re.findall(rf"\b{name}\b", l)) for l in code)
            # one occurrence is the DEF itself; every other one must be a resolved use
            if occurrences - 1 != len(uses):
                continue
            text2 = drop_def(text2, name)
            text2 = "\n".join(re.sub(rf"\b{name}\b", lab, l) if ";" not in l else
                              re.sub(rf"\b{name}\b", lab, l.split(";", 1)[0]) + ";" + l.split(";", 1)[1]
                              for l in text2.split("\n"))
            stats["defs"] += 1
        if text2 != text:
            edits[f] = text2
    return edits, stats


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", default="magination")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    p = R.project(args.project)
    edits, stats = plan(p)
    if not args.dry_run:
        for f, t in edits.items():
            (R.ROOT / f).write_text(t)
    print(f"{len(edits)} files: {stats['defs']} DEF aliases replaced by labels, "
          f"{stats['raw']} raw operands named")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
