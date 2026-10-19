"""Byte length of one RGBDS SM83 source line, from its text alone.

`make progress` uses it to split committed source into code and data
(AGENTS.md C1). An instruction's length depends only on its mnemonic and
operand forms, so no assembler run is needed. A line this module does not
recognise as an instruction returns None and is counted as data.
"""

from __future__ import annotations

import re

R8 = {"a", "b", "c", "d", "e", "h", "l", "[hl]"}
R16 = {"bc", "de", "hl", "sp"}
ONE = {"nop", "halt", "di", "ei", "ret", "reti", "rlca", "rrca", "rla", "rra",
       "daa", "cpl", "scf", "ccf"}
CB = {"rlc", "rrc", "rl", "rr", "sla", "sra", "swap", "srl", "bit", "res", "set"}
ALU = {"add", "adc", "sub", "sbc", "and", "xor", "or", "cp"}
COND = {"nz", "z", "nc", "c"}
INDIRECT_1 = {"[bc]", "[de]", "[hl+]", "[hli]", "[hl-]", "[hld]", "[c]",
              "[$ff00+c]", "[$ff00 + c]"}
LABEL = re.compile(r"^\s*(?:[A-Za-z_.][\w.]*::?)\s*")
MNEMONICS = ONE | CB | ALU | {"stop", "rst", "push", "pop", "inc", "dec", "jp",
                              "jr", "call", "ld", "ldh", "ldi", "ldd"}


def strip(line: str) -> str:
    code = line.split(";", 1)[0].strip()
    while True:
        m = LABEL.match(code)
        if not m or m.end() == 0:
            break
        rest = code[m.end():]
        if rest == code:
            break
        code = rest.strip()
    return code


def operands(rest: str) -> list[str]:
    return [o.strip().lower().replace(" ", "") for o in rest.split(",")] if rest.strip() else []


def length(line: str) -> int | None:
    """Bytes the instruction on this line emits, or None if it is not one."""
    code = strip(line)
    if not code:
        return None
    parts = code.split(None, 1)
    op = parts[0].lower()
    if op not in MNEMONICS:
        return None
    ops = operands(parts[1] if len(parts) > 1 else "")
    if op in ONE:
        return 1
    if op == "stop":
        return 2
    if op in CB:
        return 2
    if op in ("rst", "push", "pop"):
        return 1
    if op in ("inc", "dec"):
        return 1
    if op == "jr":
        return 2
    if op == "call":
        return 3
    if op == "jp":
        return 1 if ops in (["hl"], ["[hl]"]) else 3
    if op in ALU:
        last = ops[-1] if ops else ""
        if op == "add" and ops and ops[0] == "hl":
            return 1
        if op == "add" and ops and ops[0] == "sp":
            return 2
        return 1 if last in R8 else 2
    if op in ("ldi", "ldd"):
        return 1
    if op == "ldh":
        return 1 if ("[c]" in ops or "[$ff00+c]" in ops) else 2
    # ld
    if len(ops) != 2:
        return None
    dst, src = ops
    if dst in R8 and src in R8:
        return 1
    if dst == "sp" and src == "hl":
        return 1
    if dst == "hl" and re.match(r"^sp([+-]|$)", src):
        return 2
    if dst in INDIRECT_1 or src in INDIRECT_1:
        return 1
    if dst in R16:
        return 3
    if dst in R8 and not src.startswith("["):
        return 2  # ld r, n8  /  ld [hl], n8
    if dst.startswith("[") or src.startswith("["):
        return 3  # ld [n16], a / ld a, [n16] / ld [n16], sp
    return None
