#!/usr/bin/env python3
"""Static inventory of Magi-Nation cutscenes and transitions (no emulation).

Reads the ROM at runtime and prints addresses, map ids and opcode ids only
(no ROM bytes or strings). Built on mn_secrets' reachable block graph.

A *cutscene* is a reachable script block that drives the camera ($82 $83 $84
$86), scripted sprite motion ($15 $16 $4C $4D $4F $99 $9B) or palette/screen
effects ($30 $6C), with at least MIN_OPS ops. A *transition* is every reachable
map load ($65), typed by what precedes it in its block: `startup` ($93 before
it: LCD-off door), `spiral` ($30 wipe), `live` (LCD on, no $93 in block).

Port status per block comes from the opcode parity table (docs/mn-parity.md):
  matches  every op has a port handler with a decomp-read implementation
  diverges uses an op on the documented divergence list (mailbox latching
           $53-$62, $16 camera-ride) -> see docs/mn-parity.md
  missing  uses an op the port only logs ($29)
Handler parity is not a per-scene run check; per-scene confirmation is the
headless audit queue (docs/mn-inventory.md).

Usage: mn_inventory.py ROM [--tsv OUT_DIR]
"""
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn_story_graph as G  # noqa: E402
import mn_secrets as S  # noqa: E402

CAMERA = {0x82, 0x83, 0x84, 0x86}
MOTION = {0x15, 0x16, 0x4C, 0x4D, 0x4F, 0x99, 0x9B}
SCREEN = {0x30, 0x6C}
SOUND = set(range(0x1B, 0x25))
WAITS = {0x00, 0x40, 0x41, 0x1A, 0x5D, 0x5E, 0x5F, 0x60, 0x61, 0x62, 0x9A}
DIVERGE = {0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x5D, 0x5E, 0x5F, 0x60, 0x61, 0x62, 0x16}
MISSING = {0x29}
MIN_OPS = 4


def status(ops):
    s = set(ops)
    if s & MISSING:
        return "missing"
    if s & DIVERGE:
        return "diverges"
    return "matches"


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    rom = G.Rom(open(argv[1], "rb").read())
    g = S.Graph(*S.build_blocks(rom))
    out = argv[argv.index("--tsv") + 1] if "--tsv" in argv else None
    cut, trans, seen = [], [], set()
    for s, b in sorted(g.blocks.items()):
        ops = [rom.u8(o) for o in b["ops"]]
        st = set(ops)
        maps = ",".join(map(str, g.maps(s, maxd=10, limit=3))) or "-"
        if len(ops) >= MIN_OPS and st & (CAMERA | MOTION | SCREEN):
            kinds = "+".join(k for k, ks in (("camera", CAMERA), ("motion", MOTION),
                                              ("screen", SCREEN), ("sound", SOUND), ("wait", WAITS)) if st & ks)
            cut.append((G.loc(s), maps, len(ops), kinds, status(ops),
                        " ".join("%02X" % o for o in sorted(st & DIVERGE)) or "-"))
        seen93 = False
        for o, op in zip(b["ops"], ops):
            if op == 0x93:
                seen93 = True
            if op == 0x65 and o not in seen:
                seen.add(o)
                kind = "spiral" if 0x30 in ops[:ops.index(op) + 1] else ("startup" if seen93 else "live")
                tgt = "%02X:%04X" % (rom.u8(o + 3), rom.u16(o + 1))
                trans.append((G.loc(o), maps, kind, tgt))
    hdr_c = ("block", "maps", "ops", "kinds", "status", "divergent_ops")
    hdr_t = ("op", "maps", "type", "map_source")
    if out:
        os.makedirs(out, exist_ok=True)
        for name, h, rows in (("cutscenes.tsv", hdr_c, cut), ("transitions.tsv", hdr_t, trans)):
            with open(os.path.join(out, name), "w") as f:
                f.write("\t".join(h) + "\n")
                for r in rows:
                    f.write("\t".join(map(str, r)) + "\n")
    print("cutscenes", len(cut), dict(Counter(r[4] for r in cut)))
    print("transitions", len(trans), dict(Counter(r[2] for r in trans)))
    print("divergent ops in cutscenes", dict(Counter(x for r in cut for x in r[5].split() if x != "-")))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
