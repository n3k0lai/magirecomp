#!/usr/bin/env python3
"""Turn a ROM range of GBC tiles into a committed PNG built by rgbgfx (AGENTS.md S2).

    python3 scripts/gfx/convert.py NAME START END [--bpp 2] [--width 16] [--pad N]

START/END are file addresses (hex with $ or 0x). The range must line up with
scaffold section edges or sit inside INCBIN sections, which are split. Sections
inside the range are replaced by one SECTION that INCLUDEs src/gfx/NAME.asm;
lifted tile .asm files that only that range used are deleted. --pad N leaves
the last N bytes of the range as `ds N, $00` instead of graphics.

Writes gfx/NAME.png (or gfx/NAME.1bpp.png), src/gfx/NAME.asm and a line in
gfx/gfx.mk when the PNG needs trailing tiles trimmed.
"""
from __future__ import annotations
import argparse, re, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCAFFOLD = ROOT / "src/scaffold.asm"
SEC = re.compile(r'^SECTION "([^"]+)", (ROM0|ROMX)\[\$([0-9A-Fa-f]+)\](?:, BANK\[(\d+)\])?')
INC = re.compile(r'^\s*INCLUDE "([^"]+)"')
BIN = re.compile(r'^\s*INCBIN "roms/magination\.gbc", \$([0-9A-Fa-f]+), \$([0-9A-Fa-f]+)')


def num(t: str) -> int:
    t = t.strip()
    return int(t[1:], 16) if t.startswith("$") else int(t, 0)


def blocks(lines):
    """[(file_address, [lines])], first block is the preamble with address -1."""
    out = [(-1, [])]
    for line in lines:
        m = SEC.match(line)
        if m:
            bank = int(m.group(4) or 0)
            org = int(m.group(3), 16)
            addr = org if m.group(2) == "ROM0" else bank * 0x4000 + org - 0x4000
            out.append((addr, [line]))
        else:
            out[-1][1].append(line)
    return out


def section(addr: int, name: str, body: str) -> list[str]:
    bank, org = addr // 0x4000, addr % 0x4000 + (0x4000 if addr >= 0x4000 else 0)
    head = (f'SECTION "{name}", ROM0[${org:04X}]' if bank == 0 else
            f'SECTION "{name}", ROMX[${org:04X}], BANK[{bank}]')
    return [head, body, ""]


def incbin(a: int, b: int) -> list[str]:
    return section(a, f"ROM from ${a:06X}", f'    INCBIN "roms/magination.gbc", ${a:06X}, ${b - a:04X}')


DATA_LINE = re.compile(r"^\s*(d[bsw]\b.*)?$|^\s*\w+::?\s*$")


def data_only(path: Path) -> bool:
    return all(DATA_LINE.match(l.split(";", 1)[0]) for l in path.read_text().splitlines())


def leftover(rom: bytes, a: int, b: int, old: str, new_files: dict) -> list[str]:
    """Bytes of a lifted data file that fall outside the converted range, kept as source."""
    stem = Path(old).stem
    bank = a // 0x4000
    org = a % 0x4000 + (0x4000 if bank else 0)
    name = re.sub(r"_at_[0-9a-f]+$", "", stem) + f"_at_{org:04x}"
    rel = f"src/{name}.asm"
    if rel in new_files or (rel != old and (ROOT / rel).exists()):
        rel = f"src/{name}_rest.asm"
    label = "".join(w.capitalize() for w in name.split("_"))
    head = [l for l in (ROOT / old).read_text().splitlines() if l.startswith(";")][:2]
    body = [f"; Bank {bank} ${org:04X}-${org + b - a - 1:04X} (file ${a:06X}). The part of",
            f"; {Path(old).name} outside the graphics converted next to it. Its header was:"]
    body += [";   " + l.lstrip("; ") for l in head] + ["", f"{label}::"]
    chunk = rom[a:b]
    for i in range(0, len(chunk), 8):
        body.append("    db " + ", ".join(f"${x:02X}" for x in chunk[i:i + 8]))
    new_files[rel] = "\n".join(body) + "\n"
    return section(a, f"ROM from ${a:06X}", f'INCLUDE "{rel}"')


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("name"); ap.add_argument("start"); ap.add_argument("end")
    ap.add_argument("--bpp", type=int, default=2, choices=(1, 2))
    ap.add_argument("--width", type=int, default=16)
    ap.add_argument("--pad", type=int, default=0)
    ap.add_argument("--label", default=None)
    ap.add_argument("--note", default="")
    ap.add_argument("--source", default=None,
                    help="INCLUDE this hand-written src/ file for the range instead of graphics")
    a = ap.parse_args()
    start, end = num(a.start), num(a.end)
    gend = end - a.pad
    tsize = 8 * a.bpp
    if (gend - start) % tsize:
        sys.exit(f"graphics length {gend - start} is not a whole number of {tsize}-byte tiles")
    if start // 0x4000 != (end - 1) // 0x4000:
        sys.exit("range crosses a bank")
    rom = (ROOT / "roms/magination.gbc").read_bytes()
    if a.pad and any(rom[gend:end]):
        sys.exit("pad bytes are not all zero")

    lines = SCAFFOLD.read_text().splitlines()
    bl = blocks(lines)
    addrs = [b[0] for b in bl[1:]] + [len(rom)]
    keep, removed_files, placed, new_files = [bl[0][1]], [], False, {}
    for i, (addr, body) in enumerate(bl[1:]):
        nxt = addrs[i + 1]
        if nxt <= start or addr >= end:
            keep.append(body); continue
        payload = [l for l in body[1:] if l.strip() and not l.strip().endswith(":")]
        m = BIN.match(payload[0]) if payload else None
        inc = INC.match(payload[0]) if payload else None
        if not (m or inc):
            sys.exit(f"cannot replace {body[0]}")
        straddle = not (addr >= start and nxt <= end)
        if inc:
            if straddle and not data_only(ROOT / inc.group(1)):
                sys.exit(f"{body[0]} straddles the range and is not plain data")
            removed_files.append(inc.group(1))
        if addr < start:
            keep.append(incbin(addr, start) if m else leftover(rom, addr, start, inc.group(1), new_files))
        if not placed:
            label = a.label or "".join(p.capitalize() for p in a.name.split("_"))
            target = a.source or f"src/gfx/{a.name}.asm"
            keep.append(section(start, a.name, f'INCLUDE "{target}"'))
            placed = True
        if nxt > end:
            keep.append(incbin(end, nxt) if m else leftover(rom, end, nxt, inc.group(1), new_files))
    if not placed:
        sys.exit("range not found")

    # A lifted tile file may only be removed if nothing else includes it.
    text_after = "\n".join("\n".join(b) for b in keep)
    for f in removed_files:
        if f in text_after and f not in new_files:
            sys.exit(f"{f} still included elsewhere")
        lab = re.findall(r"^(\w+)::", (ROOT / f).read_text(), re.M)
        for l in lab:
            hit = subprocess.run(["rg", "-lw", l, "src", "--glob", f"!{Path(f).name}"],
                                 cwd=ROOT, capture_output=True, text=True).stdout.split()
            hit = [h for h in hit if h not in removed_files]
            if hit:
                sys.exit(f"label {l} from {f} is used by {hit}")

    for f in removed_files:
        (ROOT / f).unlink()
    for f, body in new_files.items():
        (ROOT / f).write_text(body)
    if a.source:
        write_scaffold(keep)
        print(f"{a.name}: {end - start} bytes from {a.source}, removed {len(removed_files)} files")
        return 0
    gfx = ROOT / "gfx"; gfx.mkdir(exist_ok=True)
    (ROOT / "src/gfx").mkdir(exist_ok=True)
    ext = "1bpp" if a.bpp == 1 else "2bpp"
    pngname = f"{a.name}.1bpp.png" if a.bpp == 1 else f"{a.name}.png"
    tiles = (gend - start) // tsize
    width = min(a.width, tiles)
    trim = (-tiles) % width
    raw = Path(f"/tmp/{a.name}.{ext}")
    raw.write_bytes(rom[start:gend])
    cmd = ["rgbgfx", "-d", str(a.bpp), "-r", str(width), *(["-x", str(trim)] if trim else []), "-o", str(raw), str(gfx / pngname)]
    subprocess.run(["nix", "develop", "--command", *cmd], cwd=ROOT, check=True)
    mk = gfx / "gfx.mk"
    mk_lines = [l for l in (mk.read_text().splitlines() if mk.exists() else [])
                if not l.startswith(f"out/gfx/{a.name}.")]
    if trim:
        mk_lines.append(f"out/gfx/{a.name}.{ext}: RGBGFX_FLAGS := -x {trim}")
    mk.write_text("\n".join(["# Per-asset rgbgfx flags. Written by scripts/gfx/convert.py."] +
                            [l for l in mk_lines if not l.startswith("#")]) + "\n")
    bank = start // 0x4000
    org = start % 0x4000 + (0x4000 if bank else 0)
    asm = [f"; Bank {bank} ${org:04X}-${org + (end - start) - 1:04X} (file ${start:06X}). "
           f"{tiles} 8x8 {'1bpp' if a.bpp == 1 else 'GBC 2bpp'} tiles built from {gfx.name}/{pngname} by rgbgfx."]
    if a.note:
        asm += [f"; {l}" for l in a.note.split("\\n")]
    asm += ["", f"{label}::", f'    INCBIN "out/gfx/{a.name}.{ext}"']
    if a.pad:
        asm += [f"{label}End::", f"    ds {a.pad}, $00 ; zero fill to the end of the range"]
    else:
        asm += [f"{label}End::"]
    (ROOT / f"src/gfx/{a.name}.asm").write_text("\n".join(asm) + "\n")
    write_scaffold(keep)
    print(f"{a.name}: {tiles} tiles, {gend - start} gfx bytes, pad {a.pad}, removed {len(removed_files)} files")
    return 0


def write_scaffold(keep):
    out = []
    for b in keep:
        out.extend(b)
    # collapse runs of blank lines
    final = []
    for l in out:
        if l == "" and final and final[-1] == "":
            continue
        final.append(l)
    SCAFFOLD.write_text("\n".join(final).rstrip("\n") + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
