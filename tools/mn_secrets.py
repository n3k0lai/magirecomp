#!/usr/bin/env python3
"""Static secrets / optional-content report for Magi-Nation (no emulation).

Reads the ROM at runtime (path argument) and prints numbers only (bank:addr,
map ids, species ids, op ids); it embeds and prints no ROM bytes or strings.
Builds on mn_story_graph (same opcode sizes as the port's ScriptVM).

Block graph: every map-entry script (`65 lo hi 4F`) is a root; a block is a
straight run of ops to an END op (or another map's `65`), with edges for far
targets (`45` `43` `49` `4B` `9C` `47` `8E` `A0`-`A3`), `46` jumps, `32` grass
scripts, `64` trigger lists (cells $C0+i) and `69` A lists (cells $40+i).
Backward shortest chains from an op to the map roots tell how it is reached.

Report (--secrets):
  summons   every reachable `2E` (slot, species): Hyren encounters with their
            maps and reaching chain, and species ids no reachable script summons
  gives     `87`/`88` item gives and `A4` chests with their maps
  picks     `47` random picks (count, records)
  weak      reachable uses of ops the port only logs (VM:note)
Usage: mn_secrets.py ROM [--secrets] [--species 9,13,...] [--chain BANK:ADDR]
"""
import os
import sys
from collections import defaultdict, deque

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn_story_graph as G  # noqa: E402

# Hyren species ids (bank 6 $5AA6 name table index, the `2E` species byte)
HYRENS = (9, 13, 16, 18, 21, 27, 45, 46, 48, 71, 72)
# ops the port's ScriptVM still only logs (VM:note); see docs/mn-engines.md
WEAK = (0x11, 0x29, 0x38, 0x39, 0x67)


def far(t):
    return G.off(int(t[3:], 16), int(t[:2], 16))


def build_blocks(rom, entries=None, max_ops=800):
    """-> (blocks {start: {"ops": [off], "edges": [(kind, off)]}}, roots {start: set(map)})"""
    entries = G.find_entries(rom) if entries is None else entries
    blocks, roots = {}, defaultdict(set)

    def block(o, own=None):
        if o in blocks:
            return
        ops, edges, s = [], [], o
        for _ in range(max_ops):
            e, n, op = G.decode(rom, o)
            if n is None:
                edges.append(("bad", o))
                break
            if own is not None and op == 0x65 and o != own:
                break
            ops.append(o)
            for t in e["targets"]:
                edges.append(("op%02X" % op, far(t)))
            if op == 0x32:
                edges.append(("grass", G.off(rom.u16(o + 2), rom.u8(o + 1))))
            if "trig_list" in e:
                for t in G.list21(rom, e["trig_list"]):
                    edges.append(("trig%02X" % (0xC0 + t["i"]), far(t["script"])))
            if "a_list" in e:
                for t in G.alist21(rom, e["a_list"]):
                    edges.append(("a" + t["cell"], far(t["script"])))
            if op == 0x46:
                edges.append(("jr", G.off(rom.u16(o + 1), o // 0x4000)))
                break
            if op in rom.END and op != 0x93:
                break
            o += n
        blocks[s] = {"ops": ops, "edges": edges}

    q = deque()
    for en in entries:
        o = G.off(en["ptr"], en["bank"])
        roots[o].add(en["map"])
        block(o, own=o)
        q.append(o)
    seen = set()
    while q:
        s = q.popleft()
        if s in seen:
            continue
        seen.add(s)
        for k, t in blocks[s]["edges"]:
            if k == "bad" or not (0 < t // 0x4000 < 0x80):
                continue
            if t not in blocks:
                block(t)
            q.append(t)
    return blocks, dict(roots)


class Graph:
    def __init__(self, blocks, roots):
        self.blocks, self.roots = blocks, roots
        self.inb, self.rev = defaultdict(list), defaultdict(list)
        for s, b in blocks.items():
            for o in b["ops"]:
                self.inb[o].append(s)
            for k, t in b["edges"]:
                self.rev[t].append((k, s))

    def ops(self, rom, want):
        """unique reachable ops whose opcode is in want -> [off] (each counted once)"""
        return sorted(o for o, bs in self.inb.items() if rom.u8(o) in want)

    def chains(self, o, maxd=12, limit=6):
        """shortest backward paths from op o to map roots: [(maps, [(edge kind, block loc)])]"""
        starts = self.inb.get(o, [])
        q = deque((s, []) for s in starts)
        seen, out = set(starts), []
        while q and len(out) < limit:
            s, path = q.popleft()
            if s in self.roots:
                out.append((sorted(self.roots[s]), path))
            if len(path) >= maxd:
                continue
            for k, p in self.rev.get(s, []):
                if p not in seen:
                    seen.add(p)
                    q.append((p, path + [(k, G.loc(s))]))
        return out

    def maps(self, o, maxd=12, limit=6):
        ms = set()
        for m, _ in self.chains(o, maxd, limit):
            ms.update(m)
        return sorted(ms)


def summons(rom, g):
    """-> [(off, slot, species, (spends, energy, delay))] for every reachable `2E`"""
    return [(o, rom.u8(o + 1), rom.u8(o + 2), (rom.u8(o + 3), rom.u8(o + 4), rom.u8(o + 5)))
            for o in g.ops(rom, (0x2E,))]


def report(rom, g, species=HYRENS, nspecies=109, out=sys.stdout):
    w = out.write
    sm = summons(rom, g)
    seen = defaultdict(list)
    for o, slot, sp, _ in sm:
        seen[sp].append(o)
    w("summons: %d reachable 2E, %d species\n" % (len(sm), len(seen)))
    for sp in species:
        offs = seen.get(sp, [])
        w("species %d: %d summon(s)\n" % (sp, len(offs)))
        for o in offs:
            for maps, path in g.chains(o, limit=3):
                w("  %s maps %s via %s\n" % (G.loc(o), maps[:8], " <- ".join("%s %s" % kv for kv in path[-4:])))
    never = [i for i in range(nspecies) if i not in seen]
    w("species never summoned by a reachable script: %s\n" % never)
    odd = sorted(sp for sp in seen if sp >= nspecies)
    if odd:
        w("out-of-table species bytes (walker misreads): %s\n" % [(sp, [G.loc(o) for o in seen[sp]]) for sp in odd])
    for name, want in (("gives 87/88", (0x87, 0x88)), ("chests A4", (0xA4,)), ("picks 47", (0x47,))):
        offs = g.ops(rom, want)
        w("%s: %d\n" % (name, len(offs)))
        for o in offs:
            w("  %s op %02X maps %s\n" % (G.loc(o), rom.u8(o), g.maps(o, limit=3)[:8]))
    weak = g.ops(rom, WEAK)
    w("weak ops (port logs only): %d\n" % len(weak))
    for o in weak:
        w("  %s op %02X maps %s\n" % (G.loc(o), rom.u8(o), g.maps(o, limit=3)[:8]))


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    rom = G.Rom(open(argv[1], "rb").read())
    g = Graph(*build_blocks(rom))
    species = HYRENS
    if "--species" in argv:
        species = tuple(int(x) for x in argv[argv.index("--species") + 1].split(","))
    if "--chain" in argv:
        b, a = argv[argv.index("--chain") + 1].split(":")
        for maps, path in g.chains(G.off(int(a, 16), int(b, 16))):
            print(maps, path)
        return 0
    report(rom, g, species)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
