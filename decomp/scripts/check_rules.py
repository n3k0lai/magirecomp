#!/usr/bin/env python3
"""Rules a tool can check, beyond the publication check (AGENTS.md, Check: lines).

    check_rules.py [--project NAME] [--update-ratchets]

- S4  a placeholder label (`sub_XXXXXX`, `unk_XXXXXX`) sits at the file
      address it spells (needs the last build's symbol file).
- W3  a mechanically lifted code unit says what reaches it (`; Reached from:`).
- W4  a mechanically lifted table names its readers (`; Read by:`), and each
      reader exists as a label.
- W5  no bytes-as-instructions fragments anywhere in src/ (check_fragments).
- O2  ratchets that may only fall, recorded in config/ratchets.tsv:
      def_alias  `DEF NAME EQU $XXXX` whose value is a lifted ROM label's
                 address in that bank (the label is the name; use it)
      raw_flow   call/jp/jr to a raw `$XXXX` in lifted code
      device     `; DEVICE:` tags (forced encodings, see S5)
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parent / "own"))

from lib import rom as R  # noqa: E402
import check_fragments  # noqa: E402

RATCHETS = R.ROOT / "config" / "ratchets.tsv"
PLACEHOLDER = re.compile(r"^((?:sub|unk)_([0-9A-F]{6}))::?", re.M)
DEF = re.compile(r"^\s*DEF\s+(\w+)\s+EQU\s+\$([0-9A-Fa-f]{4})\b", re.M)
RAW_FLOW = re.compile(r"^\s*(?:call|jp|jr)\s+(?:(?:nz|z|nc|c)\s*,\s*)?\$[0-9A-Fa-f]{4}\b", re.I | re.M)
DEVICE = re.compile(r";\s*DEVICE:", re.I)


def ram_code(p: R.Project) -> set[int]:
    """RAM addresses the project copies code to (`ld de, $XXXX` / `ld hl, $XXXX`
    with a WRAM/HRAM value): a call there is a call into copied code."""
    rx = re.compile(r"^\s*ld\s+(?:de|hl)\s*,\s*\$([C-Fc-f][0-9A-Fa-f]{3})\b", re.M)
    out = set()
    for path in p.src.rglob("*.asm"):
        out |= {int(v, 16) for v in rx.findall(path.read_text(errors="replace"))}
    return out


def measure(p: R.Project):
    errors, counts = [], {"def_alias": 0, "raw_flow": 0, "device": 0}
    copied = ram_code(p)
    names = R.names(p)
    have_sym = p.sym.exists()
    globals_at: dict[int, str] = {}
    for n, a in names.items():
        if "." not in n and not n.endswith("End"):
            globals_at.setdefault(a, n)
    for f, bank in R.unit_banks(p, p.scaffold.read_text()).items():
        path = R.ROOT / f
        if not path.exists() or f.startswith("out/"):
            continue
        text = path.read_text(errors="replace")
        for m in PLACEHOLDER.finditer(text):
            if have_sym and names.get(m.group(1)) not in (None, int(m.group(2), 16)):
                errors.append(f"{f}: {m.group(1)} is at ${names[m.group(1)]:06X}, not the address it spells (S4)")
        head = "\n".join(text.splitlines()[:6])
        if "bytes of code in bank" in head and "; Reached from:" not in head:
            errors.append(f"{f}: lifted code without '; Reached from:' (W3)")
        if "bytes of table data in bank" in head:
            m = re.search(r"^; Read by: (.+)$", head, re.M)
            if not m:
                errors.append(f"{f}: lifted table without '; Read by:' (W4)")
            elif have_sym:
                for reader in re.findall(r"(\w+) \(", m.group(1)):
                    if reader not in names:
                        errors.append(f"{f}: reader {reader} is not a label (W4)")
        for why in check_fragments.reasons(text, path.name):
            m = re.search(r"\$([0-9A-Fa-f]{4})` leaves ROM", why)
            if m and int(m.group(1), 16) in copied:
                continue  # code the project copies to RAM first
            errors.append(f"{f}: {why} (W5)")
        for m in DEF.finditer(text):
            v = int(m.group(2), 16)
            if v < 0x8000:
                fa = v if v < 0x4000 else (R.file_of(bank, v) if bank else None)
                if fa is not None and fa in globals_at and globals_at[fa] != m.group(1):
                    counts["def_alias"] += 1
        counts["raw_flow"] += len(RAW_FLOW.findall(text))
        counts["device"] += len(DEVICE.findall(text))
    return errors, counts


def load_ratchets() -> dict[str, int]:
    res = {}
    if RATCHETS.exists():
        for line in RATCHETS.read_text().splitlines():
            if line.strip() and not line.startswith("#"):
                k, v = line.split()[:2]
                res[k] = int(v)
    return res


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", default="magination")
    ap.add_argument("--update-ratchets", action="store_true")
    args = ap.parse_args()
    p = R.project(args.project)
    errors, counts = measure(p)
    if args.project == "magination":
        ratchets = load_ratchets()
        if args.update_ratchets:
            RATCHETS.write_text("# Counts that may only fall (scripts/check_rules.py, AGENTS.md O2/S5).\n"
                                + "".join(f"{k}\t{v}\n" for k, v in counts.items()))
            ratchets = counts
        for k, v in counts.items():
            if k in ratchets and v > ratchets[k]:
                errors.append(f"ratchet {k} rose from {ratchets[k]} to {v} (O2)")
            elif k in ratchets and v < ratchets[k]:
                print(f"ratchet {k} fell from {ratchets[k]} to {v}; run "
                      f"`python3 scripts/check_rules.py --update-ratchets` to lock it in")
    if errors:
        print("rule check failed:", file=sys.stderr)
        for e in errors[:40]:
            print(f"  {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
