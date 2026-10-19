#!/usr/bin/env python3
"""Reject bytes-as-instructions fragments (AGENTS.md S1, W6).

A slice is a fragment when it admits it does not know what the bytes do, or
when the instructions themselves look like data. Used by own-workers submit
and by the pre-commit hook on staged src/*.asm files.
Usage: check_fragments.py FILE...   (exit 1 and print reasons on a hit)
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

INVALID = {0xD3, 0xDB, 0xDD, 0xE3, 0xE4, 0xEB, 0xEC, 0xED, 0xF4, 0xFC, 0xFD}
ADMITS = re.compile(
    r"still unexplained|bytes are (still )?unexplained|whether (these opcodes|anything|this path) "
    r"(run|reach)|bitplane-like values that assemble|decode as instructions|read as instructions|"
    r"what these bytes are for is still unknown", re.I)
NAME = re.compile(r"^Bank[0-9A-Fa-f]+At[0-9A-Fa-f]{4}::", re.M)


def reasons(text: str, name: str = "") -> list[str]:
    out = []
    if re.match(r"bank[0-9a-f]+_at_[0-9a-f]+\.asm$", name):
        out.append("file name is an address-only fragment (bankN_at_XXXX)")
    if NAME.search(text):
        out.append("label is only an address (BankNAtXXXX); name the job the code does")
    head = "\n".join(l for l in text.splitlines()[:25] if l.lstrip().startswith(";"))
    if ADMITS.search(head):
        out.append("header says what the bytes do is unknown; leave them INCBIN")
    code = [l.split(";", 1)[0].strip() for l in text.splitlines()]
    code = [l for l in code if l and not l.endswith(":")]
    instr = [l for l in code if not re.match(r"(db|dw|dl|ds|DEF)\b", l, re.I)]
    for l in code:
        m = re.match(r"db\s+\$([0-9A-Fa-f]{2})\s*$", l, re.I)
        if m and int(m.group(1), 16) in INVALID and len(instr) > 4:
            out.append(f"invalid SM83 opcode ${m.group(1).upper()} emitted between instructions")
            break
    if sum(1 for l in instr if re.match(r"rst\s+\$38\b", l, re.I)) >= 3:
        out.append("three or more `rst $38` ($FF bytes) in code: padding or data")
    for l in instr:
        m = re.match(r"(?:call|jp)\s+(?:(?:nz|z|nc|c)\s*,\s*)?\$([0-9A-Fa-f]{4})\b", l, re.I)
        if m and 0x8000 <= int(m.group(1), 16) < 0xFF80:
            out.append(f"`{l}` leaves ROM; code here would be in RAM")
            break
    return out


def main() -> int:
    bad = 0
    for arg in sys.argv[1:]:
        p = Path(arg)
        if p.name == "scaffold.asm" or not p.is_file():
            continue
        r = reasons(p.read_text(errors="replace"), p.name)
        if r:
            bad += 1
            print(f"{arg}: fragment, not source:", file=sys.stderr)
            for x in r:
                print(f"  {x}", file=sys.stderr)
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
