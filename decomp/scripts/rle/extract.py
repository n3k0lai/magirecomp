#!/usr/bin/env python3
"""Write src/tilemaps/bankXX/XXXX.tmap for the items in streams.txt.

With bank arguments only those banks are written; with none, every bank. Each
file is checked to re-encode to the ROM bytes exactly (development only).
"""
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts/rle"))
from rlelib import decode, ops_tokens, write_tmap, read_tmap, MODES  # noqa: E402

HEAD = {"M": 7, "B": 3, "S": 0}


def main():
    rom = (ROOT / "roms/magination.gbc").read_bytes()
    banks = {int(b, 16) for b in sys.argv[1:]}
    for line in (ROOT / "scripts/rle/streams.txt").read_text().splitlines():
        if line.startswith("#"): continue
        f = line.split(); p, e = int(f[0], 16), int(f[1], 16); kind = f[2] if len(f) > 3 else "S"
        bank, addr = p // 0x4000, 0x4000 + p % 0x4000
        if banks and bank not in banks: continue
        q = p + HEAD[kind]
        data, end, _ = decode(rom, q)
        assert end == e, line
        header = {"M": ("map", rom[p], rom[p + 4]), "B": ("block", rom[p])}.get(kind)
        mode = next((m for m, fn in MODES.items() if fn(data) == rom[q:e]), None)
        d = ROOT / f"src/tilemaps/bank{bank:02X}"; d.mkdir(parents=True, exist_ok=True)
        out = d / f"{addr:04X}.tmap"
        write_tmap(out, bank, addr, data, ops_tokens(rom, q), mode, header)
        assert read_tmap(out) == rom[p:e], out


if __name__ == "__main__":
    main()
