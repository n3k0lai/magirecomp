#!/usr/bin/env python3
"""Mechanical lifts: code and tables from ROM bytes, with no model (AGENTS.md T3).

    lift.py plan ADDR [--project NAME]     print the unit it would write
    lift.py apply ADDR [...]                splice units into the working tree

The worker drives this; it is a CLI for inspection. A unit is written only
with evidence from xref.py (W3, W4):

- code: a call, jump or far call lands on ADDR. The routine is decoded with
  every internal branch followed; it must end in ret/reti/jp inside the
  same INCBIN, no internal target may fall inside an instruction, and no
  invalid opcode may appear. Labels: `sub_XXXXXX` (file address) and
  `.l_XXXX` (CPU address) until a naming pass proves a name (S4).
- table: a pointer load lands on ADDR. The table runs to the next lifted
  byte; that edge must be at most MAX_TABLE bytes away, and every pointer row
  inside it marks a label. Rows are `db` of eight, or `dw Label` when each
  word is a pointer to an existing global label. An existing `DEF NAME EQU`
  of that address becomes the label (O2), and raw `$XXXX` operands in the
  readers become the label (symbol propagation, T3).

The bytes judge every unit: the worker builds and compares before keeping
anything (W2).
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import rom as R  # noqa: E402
from lib import sm83  # noqa: E402

import xref  # noqa: E402

MAX_TABLE = 512
MAX_CODE = 2048


@dataclass
class Unit:
    kind: str
    start: int
    end: int
    label: str
    body: str
    file: str
    evidence: list[str]
    rename: dict[str, str] = field(default_factory=dict)   # file -> text rewrite done by propagate
    drop_defs: list[tuple[str, str]] = field(default_factory=list)  # (file, name)
    labels: dict[int, str] = field(default_factory=dict)  # file addr -> label inside this unit


class Reject(Exception):
    pass


def slug(name: str) -> str:
    if re.match(r"^(sub|unk)_[0-9A-F]{6}$", name):
        return name.lower()
    s = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "_", name)
    return re.sub(r"[^A-Za-z0-9]+", "_", s).strip("_").lower()


def next_edge(addr: int, hs) -> int:
    h = R.hole_for(addr, hs)
    if h is None:
        raise Reject(f"${addr:06X} is not inside an INCBIN")
    return h["end"]


def global_label_at(syms_all: dict[str, int], fa: int) -> str | None:
    best = None
    for n, a in syms_all.items():
        if a == fa and "." not in n and not n.endswith("End"):
            if best is None or n < best:
                best = n
    return best


def defs_for(p: R.Project, value: int, bank: int) -> list[tuple[str, str]]:
    """(file, name) of `DEF name EQU $value` in source of this bank (or bank 0)."""
    out = []
    rx = re.compile(rf"^\s*DEF\s+(\w+)\s+EQU\s+\${value:04X}\b", re.M | re.I)
    for f, b in R.unit_banks(p, p.scaffold.read_text()).items():
        if b not in (bank, 0) and value >= 0x4000:
            continue
        path = R.ROOT / f
        if path.exists():
            for m in rx.finditer(path.read_text(errors="replace")):
                out.append((f, m.group(1)))
    return out


def table_name(p: R.Project, fa: int) -> tuple[str, list[tuple[str, str]]]:
    bank, cpu = R.cpu_of(fa)
    defs = defs_for(p, cpu, bank)
    names = sorted({n for _, n in defs})
    if names:
        name = names[0]
        if re.match(r"^w[A-Z]", name):
            name = name[1:]  # a ROM table is not WRAM; the w prefix was wrong
        return name, defs
    return f"unk_{fa:06X}", defs


def plan_table(p: R.Project, addr: int, refs, hs) -> Unit:
    pointer_rows = [r for r in refs if r.target == addr and r.kind == "pointer"]
    if not pointer_rows:
        raise Reject("no pointer load reads this address (W4)")
    if any(r.target == addr and r.kind != "pointer" for r in refs):
        raise Reject("code also lands here; lift it as code")
    end = next_edge(addr, hs)
    if end - addr > MAX_TABLE:
        raise Reject(f"no lifted edge within {MAX_TABLE} bytes (table extent unproven)")
    flows_inside = [r for r in refs if addr < r.target < end and r.kind != "pointer"]
    if flows_inside:
        raise Reject(f"code lands inside at ${flows_inside[0].target:06X}")
    bank, _ = R.cpu_of(addr)
    banks = R.unit_banks(p, p.scaffold.read_text())
    if any(banks.get(r.file) not in (bank,) and bank != 0 for r in pointer_rows):
        raise Reject("read from another bank: an asset for a format codec, not a raw table (A1)")
    data = p.rom.read_bytes()
    k = code_inside(p, data, addr, end)
    if k is not None:
        raise Reject(f"bytes at +{k} decode as code with evidence; extent unproven")
    syms_all = R.names(p)
    bank, _ = R.cpu_of(addr)
    marks = sorted({r.target for r in refs if addr <= r.target < end and r.kind == "pointer"})
    labels, defs = {}, []
    for m in marks:
        name, d = table_name(p, m)
        if name in labels.values() or name in syms_all:
            name = f"unk_{m:06X}"
        labels[m] = name
        defs += d
    lines = []
    readers = sorted({f"{r.routine} ({r.file}:{r.line})" for r in refs
                      if addr <= r.target < end and r.kind == "pointer"})
    head = labels[addr]
    lines.append(f"; {head}: {end - addr} bytes of table data in bank ${bank:02X}.")
    lines.append(f"; Read by: {', '.join(readers)}")
    lines.append("; Extent: up to the next lifted byte. Rows are raw until a")
    lines.append("; naming pass gives the fields a meaning (AGENTS.md S4).")
    lines.append("")
    words = (end - addr) % 2 == 0 and (end - addr) >= 4
    word_labels = []
    if words:
        for i in range(addr, end, 2):
            w = data[i] | (data[i + 1] << 8)
            tf = w if w < 0x4000 else (R.file_of(bank, w) if 0x4000 <= w < 0x8000 and bank else None)
            lab = global_label_at(syms_all, tf) if tf is not None else None
            if i != addr and i in labels or not (0x4000 <= w < 0x8000 or (bank == 0 and 0x150 <= w < 0x4000)):
                word_labels = []
                break
            word_labels.append(lab or f"${w:04X}")
        if sum(1 for x in word_labels if not x.startswith("$")) * 4 < len(word_labels) * 3:
            word_labels = []
    pos = addr
    while pos < end:
        if pos in labels:
            if pos != addr:
                lines.append("")
            lines.append(f"{labels[pos]}::")
        stop = min([end] + [m for m in marks if m > pos])
        if word_labels:
            for k in range(pos, stop, 2):
                lines.append(f"    dw {word_labels[(k - addr) // 2]}")
            pos = stop
            continue
        while pos < stop:
            n = min(8, stop - pos)
            lines.append("    db " + ", ".join(f"${b:02X}" for b in data[pos:pos + n]))
            pos += n
    body = "\n".join(lines) + "\n"
    ev = [f"{r.kind} {r.routine} {r.file}:{r.line}" for r in pointer_rows]
    rel = str((p.src / f"{slug(head)}.asm").relative_to(R.ROOT))
    return Unit("table", addr, end, head, body, rel, ev,
                drop_defs=defs, labels=labels)


def code_inside(p: R.Project, data: bytes, start: int, end: int) -> int | None:
    """First offset whose decode is a clean routine touching named RAM or
    calling a known label: such bytes may be code, so a table cannot claim them."""
    rams = R.ram_names(p)
    syms = R.symbols(p)
    bank, cpu0 = R.cpu_of(start)
    base = start - cpu0
    for k in range(end - start):
        instrs, stop = sm83.routine(data, start + k, end - start - k)
        if stop not in ("ret", "jump") or len(instrs) < 4:
            continue
        ev = 0
        for fa, cpu, raw, text, kind, target in instrs:
            if target is None:
                continue
            if kind == "mem" and 0xC000 <= target < 0xE000:
                ev += 1
            if kind == "call" and target >= 0x100 and (target if target < 0x4000 else target + base) in syms:
                ev += 2
        if ev >= 2:
            return k
    return None


def decode_routine(data: bytes, addr: int, end_limit: int, fall_through: bool = False):
    """Follow every internal branch. Returns sorted instruction list.
    fall_through: end_limit is lifted code, so running into it is a
    fall-through into the next routine, not a decode error."""
    bank, cpu0 = R.cpu_of(addr)
    base = addr - cpu0
    todo, seen, instrs = [addr], set(), {}
    while todo:
        pos = todo.pop()
        while True:
            if pos in instrs:
                break
            if fall_through and pos == end_limit:
                break
            if not (addr <= pos < end_limit):
                raise Reject(f"flow leaves the INCBIN at ${pos:06X}")
            n, text, kind, target = sm83.decode(data, pos, pos - base)
            if kind == "invalid":
                raise Reject(f"invalid opcode at ${pos:06X}")
            if text == "stop" and data[pos + 1] != 0:
                raise Reject("stop with a nonzero operand")
            if pos + n > end_limit:
                raise Reject("instruction crosses the INCBIN end")
            instrs[pos] = (pos, pos - base, data[pos:pos + n], text, kind, target)
            if kind in ("jump", "cjump") and target is not None and text.startswith(("jr", "jp")):
                tf = target + base if (bank == 0 or target >= 0x4000) else target
                if addr <= tf < end_limit and target < 0x8000:
                    todo.append(tf)
            if kind in ("ret", "jump"):
                break
            pos += n
    # contiguous coverage only: a gap means two routines or data between
    starts = sorted(instrs)
    covered = starts[0]
    for s in starts:
        if s != covered:
            raise Reject(f"gap at ${covered:06X}: decoded flow is not contiguous")
        covered = s + len(instrs[s][2])
    return [instrs[s] for s in starts], covered


def plan_code(p: R.Project, addr: int, refs, hs) -> Unit:
    flow = [r for r in refs if r.target == addr and r.kind in ("call", "jump", "far")]
    if not flow:
        raise Reject("no call, jump or far call lands here (W3)")
    data = p.rom.read_bytes()
    edge = next_edge(addr, hs)
    end_limit = min(edge, addr + MAX_CODE)
    instrs, end = decode_routine(data, addr, end_limit, fall_through=end_limit == edge)
    starts = {i[0] for i in instrs}
    bank, cpu0 = R.cpu_of(addr)
    base = addr - cpu0
    for r in refs:
        if addr < r.target < end and r.target not in starts:
            raise Reject(f"lifted code lands at ${r.target:06X}, inside an instruction")
    label = f"sub_{addr:06X}"
    lines = [f"; {label}: {end - addr} bytes of code in bank ${bank:02X}.",
             "; Reached from: " + ", ".join(sorted({f'{r.routine} ({r.file}:{r.line}, {r.kind})' for r in flow})),
             "; Name and comments wait for a naming pass (AGENTS.md S4).", ""]
    lines += code_lines(p, addr, instrs, end, label)
    body = "\n".join(lines) + "\n"
    ev = [f"{r.kind} {r.routine} {r.file}:{r.line}" for r in flow]
    rel = str((p.src / f"{label}.asm").relative_to(R.ROOT))
    return Unit("code", addr, end, label, body, rel, ev, labels={addr: label})


def code_lines(p: R.Project, addr: int, instrs, end: int, label: str, symbolic: bool = True) -> list[str]:
    """RGBDS lines for decoded instructions. symbolic=False keeps every
    operand a number (the replay test assembles routines in isolation)."""
    bank, cpu0 = R.cpu_of(addr)
    base = addr - cpu0
    syms_all = R.names(p) if symbolic else {}
    rams = R.ram_names(p) if symbolic else {}
    internal = {}
    for i in instrs:
        if i[4] in ("jump", "cjump", "call") and i[5] is not None:
            tf = i[5] + base if i[5] >= 0x4000 or bank == 0 else i[5]
            if addr <= tf < end:
                internal[tf] = label if tf == addr else f".l_{i[5]:04X}"
    lines = [f"{label}::"]
    for fa, cpu, raw, text, kind, target in instrs:
        if fa in internal and fa != addr:
            lines.append(f"{internal[fa]}:")
        if kind in ("jump", "cjump", "call") and target is not None and not text.startswith("rst"):
            tf = target + base if (target >= 0x4000 or bank == 0) else target
            if target >= 0x4000 and bank == 0:
                tf = None
            name = internal.get(tf) if tf is not None else None
            if name is None and tf is not None and target < 0x8000 and symbolic:
                name = global_label_at(syms_all, tf)
            if name:
                text = re.sub(r"\$[0-9A-F]{4}$", name, text)
        elif kind == "mem" and target is not None and target in rams:
            text = text.replace(f"${target:04X}", rams[target])
        lines.append(f"    {text}")
    return lines


def plan(p: R.Project, addr: int, refs=None, hs=None) -> Unit:
    refs = refs if refs is not None else xref.collect(p)
    hs = hs if hs is not None else R.holes(p.scaffold.read_text())
    if any(r.target == addr and r.kind in ("call", "jump", "far") for r in refs):
        return plan_code(p, addr, refs, hs)
    return plan_table(p, addr, refs, hs)


# ---------------------------------------------------------------- splice

def splice(p: R.Project, u: Unit) -> None:
    """Split the INCBIN holding u around [start, end) in the working scaffold."""
    text = p.scaffold.read_text()
    lines = text.split("\n")
    hs = R.holes(text)
    h = R.hole_for(u.start, hs)
    if h is None or u.end > h["end"]:
        raise Reject("range is no longer inside one INCBIN")
    sec_line = lines[h["section_line"]]
    if h["line"] != h["section_line"] + 1:
        raise Reject("INCBIN is not alone in its section")
    head, tail = [], []
    if u.start > h["start"]:
        head = [sec_line, f'    INCBIN "{p.rom_ref}", ${h["start"]:04X}, ${u.start - h["start"]:04X}', ""]
    mid = [f'SECTION "{u.label}", {R.section_spec(u.start)}', f'INCLUDE "{u.file}"']
    if u.end < h["end"]:
        tail = ["", f'SECTION "ROM from ${u.end:06X}", {R.section_spec(u.end)}',
                f'    INCBIN "{p.rom_ref}", ${u.end:04X}, ${h["end"] - u.end:04X}']
    lines = lines[:h["section_line"]] + head + mid + tail + lines[h["line"] + 1:]
    p.scaffold.write_text("\n".join(lines))
    path = R.ROOT / u.file
    if path.exists():
        raise Reject(f"{u.file} already exists")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(u.body)


def propagate(p: R.Project, u: Unit) -> list[str]:
    """Readers: raw $XXXX and old DEF names become the unit's labels (byte-identical)."""
    touched = set()
    bank = u.start >> 14
    for fa, label in u.labels.items():
        _, cpu = R.cpu_of(fa)
        for f, name in [d for d in u.drop_defs if d]:
            if R.cpu_of(fa)[1] != _def_value(f, name):
                continue
            # DEF names are global to the one assembly: drop the DEF, then
            # rename every use in every file (comments included).
            path = R.ROOT / f
            t = path.read_text()
            t2 = re.sub(rf"^\s*DEF\s+{name}\s+EQU\s+\$[0-9A-Fa-f]+[^\n]*\n", "", t, flags=re.M)
            if t2 != t:
                path.write_text(t2)
                touched.add(f)
            if name != label:
                for g in list(R.unit_banks(p, p.scaffold.read_text())) + [
                        str(x.relative_to(R.ROOT)) for x in p.src.rglob("*.inc")]:
                    gp = R.ROOT / g
                    if not gp.exists() or g.startswith("out/"):
                        continue
                    t = gp.read_text()
                    t2 = re.sub(rf"\b{name}\b", label, t)
                    if t2 != t:
                        gp.write_text(t2)
                        touched.add(g)
        for f, b in R.unit_banks(p, p.scaffold.read_text()).items():
            if b != bank and not (bank == 0):
                continue
            if f == u.file:
                continue
            path = R.ROOT / f
            if not path.exists():
                continue
            t = path.read_text()
            rx = re.compile(rf"^(\s*(?:ld\s+(?:hl|de|bc)\s*,|call|jp|jr)\s+(?:(?:nz|z|nc|c)\s*,\s*)?)\${cpu:04X}\b",
                            re.M | re.I)
            if u.kind == "table":
                rx = re.compile(rf"^(\s*ld\s+(?:hl|de|bc)\s*,\s*)\${cpu:04X}\b", re.M | re.I)
            else:
                rx = re.compile(rf"^(\s*(?:call|jp|jr)\s+(?:(?:nz|z|nc|c)\s*,\s*)?)\${cpu:04X}\b", re.M | re.I)
            t2 = rx.sub(lambda m: m.group(1) + label, t)
            if t2 != t:
                path.write_text(t2)
                touched.add(f)
    return sorted(touched)


def _def_value(f: str, name: str) -> int | None:
    m = re.search(rf"^\s*DEF\s+{name}\s+EQU\s+\$([0-9A-Fa-f]+)", (R.ROOT / f).read_text(), re.M)
    return int(m.group(1), 16) if m else None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["plan"])
    ap.add_argument("address")
    ap.add_argument("--project", default="magination")
    args = ap.parse_args()
    p = R.project(args.project)
    try:
        u = plan(p, int(args.address.lstrip("$"), 16))
    except Reject as e:
        print(f"reject: {e}")
        return 1
    print(f"# {u.kind} ${u.start:06X}-${u.end:06X} -> {u.file}\n{u.body}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
