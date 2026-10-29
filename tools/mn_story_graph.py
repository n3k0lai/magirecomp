#!/usr/bin/env python3
"""Static Magi-Nation story graph (deterministic, no emulation).

Reads the ROM at runtime (path argument); embeds no ROM bytes. Opcode sizes
come from src/mn/Opcodes.lua (metadata generated from the decomp), parsed here
so this tool and the port's ScriptVM agree on instruction lengths.

What it walks
  * map-entry scripts: every `65 lo hi 4F` (LoadFiveBankedMapSources) in banks
    02-7F, the same scan as MnRom:findEntries
  * per entry: `64` trigger list (bank 21: count, {kind, bank, ptr}; cell $C0+i,
    kind 1 up / 2 down / 3 right / 4 left), `69` A list (bank 21: count, then
    {kind, bank, ptr}; index = cell - $40), `05` object records (script at
    operand 12-14), `09` slot scripts, `5A`/`5B`/`59` record fills
  * every reachable script, following far targets (`45`, `43`, `49`, `4B`,
    `9C`, `47`, `8E`, `A0`-`A3`) and `46` (in-bank jump) to END ops.

What it records per op (with bank:addr)
  story word: `A9` stores, expr kind 4 reads (in `43`/`49`/`4B`/`A5`-`A7`)
  flag bytes $A100-$A3FF: expr kind 0/1/2 reads, `AF`/`AE`/`AC`/`AD`/`A5`-`A7`
     writes, `A0`-`A4` tests-and-sets
  cells: `7E`/`7F` rects (src, w, h, dst), `80`/`81` absolute cell writes,
     `03`/`04`/`0D`/`0E` record-relative writes (unresolved base), `A0`-`A4`
     cell stores, `67`/`68` overlay unpacks
  warps: `65` map loads, `02` pair rebase, `01` pair; items: `87`, `A4`
Usage: mn_story_graph.py ROM [--json out.json] [--map N] [--cells MAP x0 y0 x1 y1]
"""
import json, os, re, sys
from collections import defaultdict, deque

HERE = os.path.dirname(os.path.abspath(__file__))
OPCODES_LUA = os.path.join(HERE, "..", "src", "mn", "Opcodes.lua")


def load_opcodes(path=OPCODES_LUA):
    s = open(path).read()
    LEN = {}
    blk = s[s.index("M.LEN={"):s.index("}", s.index("M.LEN={"))]
    for k, v in re.findall(r"\[0x([0-9A-F]{2})\]=([0-9]+|\"[a-z0-9_]+\")", blk):
        LEN[int(k, 16)] = int(v) if v[0] != '"' else v.strip('"')
    END = {int(k, 16) for k in re.findall(r"\[0x([0-9A-F]{2})\]=true", s[s.index("M.END="):s.index("\n", s.index("M.END="))])}
    eb = s[s.index("M.EXPR="):s.index("\n", s.index("M.EXPR="))]
    EXPR = {int(k): (int(a), int(b)) for k, a, b in re.findall(r"\[(\d+)\]=\{(\d+),(\d+)\}", eb)}
    nb = s[s.index("M.NAMES="):]
    NAMES = {int(k, 16): v for k, v in re.findall(r"\[0x([0-9A-F]{2})\]=\"(\w+)\"", nb)}
    return LEN, END, EXPR, NAMES


def off(ptr, bank):
    return bank * 0x4000 + ptr - 0x4000


def loc(o):
    return "%02X:%04X" % (o // 0x4000, o % 0x4000 + 0x4000)


class Rom:
    def __init__(self, data, ops=None):
        self.d = data
        self.LEN, self.END, self.EXPR, self.NAMES = ops or load_opcodes()

    def u8(self, o):
        return self.d[o] if 0 <= o < len(self.d) else 0

    def u16(self, o):
        return self.u8(o) | (self.u8(o + 1) << 8)

    def expr_size(self, o, depth=0):
        k = self.EXPR.get(self.u8(o))
        if k is None or depth > 16:
            return None
        n = 1 + k[0]
        for _ in range(k[1]):
            m = self.expr_size(o + n, depth + 1)
            if m is None:
                return None
            n += m
        return n

    def expr_refs(self, o, out, depth=0):
        """Collect reads in an expression: ('flag', addr, mask) / ('byte', addr) / ('story',) / consts."""
        i = self.u8(o)
        if depth > 16:
            return
        if i == 0:
            out.append(("flag", self.u16(o + 1), self.u8(o + 3)))
        elif i in (1, 2):
            out.append(("byte" if i == 1 else "word", self.u16(o + 1)))
        elif i == 4:
            out.append(("story",))
        elif i == 5:
            out.append(("const", self.u8(o + 1)))
        elif i == 6:
            out.append(("const", self.u16(o + 1)))
        k = self.EXPR.get(i)
        if not k:
            return
        if i == 10:
            out.append(("not",))
        if i in (15, 16, 17, 18, 19, 20):
            out.append(("cmp", i))
        p = o + 1 + k[0]
        for _ in range(k[1]):
            self.expr_refs(p, out, depth + 1)
            p += self.expr_size(p, depth + 1) or 0

    def insn(self, o):
        """(size, far targets [(bank, ptr)]) mirroring MnRom:insn."""
        op = self.u8(o)
        L = self.LEN.get(op)
        t = []
        if L is None:
            return None, t
        if isinstance(L, int):
            if op == 0x45:
                t.append((self.u8(o + 1), self.u16(o + 2)))
            if op == 0x09:
                t.append((self.u8(o + 2), self.u16(o + 3)))
            if op in (0x59, 0x5A, 0x5B):
                t.append((self.u8(o + 1), self.u16(o + 2)))
            if op == 0x05:
                t.append((self.u8(o + 12), self.u16(o + 13)))
            if op in (0xA0, 0xA1, 0xA2, 0xA3):
                t.append((self.u8(o + 4), self.u16(o + 5)))
            return 1 + L, t
        if L == "pick":
            c = self.u8(o + 1)
            n = 2 + 3 * c
            t = [(self.u8(o + 2 + 3 * i), self.u16(o + 3 + 3 * i)) for i in range(c)]
        elif L in ("range7", "exact5"):
            m = self.expr_size(o + 1)
            if m is None:
                return None, t
            k = 7 if L == "range7" else 5
            e = o + 1 + m
            g = 0
            while self.u8(e) != 0xFF and g < 64:
                t.append((self.u8(e), self.u16(e + k - 2)))
                e += k
                g += 1
            n = e + 1 - o
        elif L == "expr3":
            m = self.expr_size(o + 1)
            if m is None:
                return None, t
            t.append((self.u8(o + 1 + m), self.u16(o + 2 + m)))
            n = 1 + m + 3
        elif L in ("expr_w", "expr_wb"):
            k = 3 if L == "expr_w" else 4
            m = self.expr_size(o + k)
            if m is None:
                return None, t
            n = k + m
        elif L == "strip":
            e = o + 1
            while self.u8(e) != 0xFD and e < len(self.d):
                e += 1
            n = e + 1 - o
        elif L == "blk0":
            n = 3 + self.u16(o + 1)
        elif L == "blk8e":
            n = 9 + self.u16(o + 7)
            t = [(self.u8(o + 1), self.u16(o + 2)), (self.u8(o + 4), self.u16(o + 5))]
        elif L == "blk3":
            n = 6 + self.u16(o + 4)
        elif L == "repeat2":
            n = 2 if self.u8(o + 1) == 0 else 4
        elif L in ("rec3", "rec4", "rec5", "rec6"):
            k = int(L[3:])
            e = o + 1
            while self.u8(e) != 0 and e < len(self.d):
                e += k
            n = e + 1 - o
        elif L == "tab":
            if self.u8(o + 1) & 1:
                return None, t
            n = 5 + self.u8(o + 1)
        else:
            return None, t
        return n, t


def is_flag(a):
    return 0xA100 <= a <= 0xA3FF


def decode(rom, o):
    """One op -> dict of effects (no ROM bytes kept beyond operand values)."""
    op = rom.u8(o)
    n, targets = rom.insn(o)
    e = {"at": loc(o), "op": "%02X" % op, "name": rom.NAMES.get(op, "?")}
    u8, u16 = rom.u8, rom.u16
    reads, writes = [], []
    if op == 0xA9:
        e["story_store"] = u16(o + 1)
    elif op in (0xAF, 0xAE):
        writes.append({"addr": u16(o + 1), ("or" if op == 0xAF else "and"): u8(o + 3)})
    elif op == 0xAC:
        writes.append({"addr": u16(o + 1), "set": u8(o + 3)})
    elif op == 0xAD:
        writes.append({"addr": u16(o + 1), "setw": u16(o + 3)})
    elif op in (0xA6, 0xA7):
        r = []
        rom.expr_refs(o + 3, r)
        writes.append({"addr": u16(o + 1), "expr": r})
    elif op == 0xA5:
        r = []
        rom.expr_refs(o + 4, r)
        writes.append({"addr": u16(o + 1), "or": u8(o + 3), "when": r})
    elif op in (0x43, 0x49, 0x4B):
        r = []
        rom.expr_refs(o + 1, r)
        e["test"] = r
        if op == 0x4B:
            m = rom.expr_size(o + 1)
            q = o + 1 + (m or 0)
            cases = []
            while u8(q) != 0xFF and len(cases) < 64:
                cases.append({"eq": u16(q + 1), "to": "%02X:%04X" % (u8(q), u16(q + 3))})
                q += 5
            e["cases"] = cases
        if op == 0x49:
            m = rom.expr_size(o + 1)
            q = o + 1 + (m or 0)
            cases = []
            while u8(q) != 0xFF and len(cases) < 64:
                cases.append({"lo": u8(q + 1), "hi": u8(q + 2), "to": "%02X:%04X" % (u8(q), u16(q + 5))})
                q += 7
            e["cases"] = cases
        if op == 0x43:
            e["to"] = "%02X:%04X" % targets[0] if targets else None
    elif op in (0xA0, 0xA1):
        e["flagtest"] = {"addr": u16(o + 1), "mask": u8(o + 3), "to": "%02X:%04X" % (u8(o + 4), u16(o + 5))}
        e["cell"] = {"addr": u16(o + 9), "set": u8(o + 7), "clr": u8(o + 8)}
        writes.append({"addr": u16(o + 1), "toggle": u8(o + 3)})
    elif op == 0xA2:
        e["flagtest"] = {"addr": u16(o + 1), "mask": u8(o + 3), "to": "%02X:%04X" % (u8(o + 4), u16(o + 5))}
        e["cell"] = {"addr": u16(o + 8), "set": u8(o + 7)}
        writes.append({"addr": u16(o + 1), "or": u8(o + 3)})
    elif op == 0xA3:
        e["flagtest"] = {"addr": u16(o + 1), "mask": u8(o + 3), "to": "%02X:%04X" % (u8(o + 4), u16(o + 5))}
        e["cell"] = {"addr": u16(o + 8), "set": u8(o + 7)}
        writes.append({"addr": u16(o + 1), "or": u8(o + 3)})
    elif op == 0xA4:
        e["flagtest"] = {"addr": u16(o + 1), "mask": u8(o + 3)}
        e["item"] = {"cat": u8(o + 4), "id": u8(o + 5)}
        e["cell"] = {"addr": u16(o + 6), "set": 0xFF}
        writes.append({"addr": u16(o + 1), "or": u8(o + 3)})
    elif op == 0x87:
        e["item"] = {"cat": u8(o + 1), "id": u8(o + 2), "count": u8(o + 3)}
    elif op in (0x7E, 0x7F):
        e["rect"] = {"src": u16(o + 1), "w": u8(o + 3), "h": u8(o + 4), "dst": u16(o + 5),
                     "layer": "live" if op == 0x7E else "overlay->live"}
    elif op in (0x80, 0x81):
        e["cellw"] = {"addr": u16(o + 3), "col": u8(o + 5), "mt": u8(o + 6)}
    elif op in (0x03,):
        e["relw"] = {"slot": u8(o + 1), "delta": u16(o + 4), "plane": "live", "col": u8(o + 6)}
    elif op in (0x04,):
        e["relw"] = {"slot": u8(o + 1), "delta": u16(o + 2), "plane": "overlay", "col": u8(o + 4)}
    elif op in (0x0D, 0x0E):
        e["relw"] = {"slot": "FF8C", "plane": "live" if op == 0x0D else "overlay"}
    elif op == 0x68:
        e["unpack"] = {"mt": "%02X:%04X" % (u8(o + 3), u16(o + 1)), "col": "%02X:%04X" % (u8(o + 6), u16(o + 4))}
    elif op == 0x67:
        e["unpack67"] = True
    elif op == 0x65:
        if u8(o + 3) == 0x4F:
            e["load_map"] = (u16(o + 1) - 0x4000) // 15
    elif op == 0x64:
        e["trig_list"] = u16(o + 1)
    elif op == 0x69:
        e["a_list"] = u16(o + 1)
    elif op == 0x02:
        e["rebase"] = [u8(o + 1), u8(o + 2), u8(o + 3), u8(o + 4)]
    elif op == 0x01:
        e["pair"] = [u8(o + 1), u8(o + 2)]
    elif op == 0x05:
        e["spawn"] = {"slot": u8(o + 1), "x": u8(o + 4), "y": u8(o + 5), "script": "%02X:%04X" % (u8(o + 12), u16(o + 13))}
    elif op == 0x25:
        e["battle"] = True
    if writes:
        e["writes"] = writes
    if "test" in e:
        for r in e["test"]:
            if r[0] in ("flag", "byte", "word"):
                reads.append(r)
    if reads:
        e["reads"] = reads
    e["targets"] = ["%02X:%04X" % t for t in targets if 0x4000 <= t[1] < 0x8000]
    return e, n, op


def walk(rom, bank, ptr, limit=4000, own_entry=None):
    """BFS over one script and its far targets. Returns ([effects], [unsized ops]).

    With own_entry set (the ROM offset of this map's `65`), the walk stops at any other `65`: that is
    another map's entry, and its triggers / A list belong to that map (no cross-map bleed)."""
    seen_ops = {}
    q = deque([(bank, ptr)])
    seen = set()
    bad = []
    while q and len(seen) < limit:
        b, p = q.popleft()
        if (b, p) in seen or not (0x4000 <= p < 0x8000) or not (0 <= b < 0x80):
            continue
        seen.add((b, p))
        o = off(p, b)
        for _ in range(400):
            if o in seen_ops:
                break
            e, n, op = decode(rom, o)
            if n is None:
                bad.append(loc(o))
                break
            if own_entry is not None and op == 0x65 and o != own_entry:
                break
            seen_ops[o] = e
            for t in e["targets"]:
                tb, tp = int(t[:2], 16), int(t[3:], 16)
                q.append((tb, tp))
            if op == 0x46:
                q.append((b, rom.u16(o + 1)))
                break
            if op in rom.END and op != 0x93:
                break
            o += n
    return [seen_ops[k] for k in sorted(seen_ops)], bad


def find_entries(rom):
    out = []
    for b in range(0x02, 0x80):
        base = b * 0x4000
        for a in range(0, 0x3FFC):
            o = base + a
            if rom.u8(o) == 0x65 and rom.u8(o + 3) == 0x4F:
                p = rom.u16(o + 1)
                if 0x4000 <= p < 0x559E and (p - 0x4000) % 15 == 0:
                    out.append({"bank": b, "ptr": 0x4000 + a, "map": (p - 0x4000) // 15, "at": loc(o)})
    return out


def list21(rom, ptr, cap=64):
    o = off(ptr, 0x21)
    c = rom.u8(o)
    if c < 1 or c > cap:
        return []
    res = []
    for i in range(c):
        q = o + 1 + (4 * i)
        res.append({"i": i, "kind": rom.u8(q), "script": "%02X:%04X" % (rom.u8(q + 1), rom.u16(q + 2))})
    return res


def alist21(rom, ptr, cap=64):
    o = off(ptr, 0x21)
    c = rom.u8(o)
    if c < 1 or c > cap:
        return []
    res = []
    for i in range(c):
        q = o + 1 + (4 * i)
        res.append({"cell": "%02X" % (0x40 + i), "kind": rom.u8(q), "script": "%02X:%04X" % (rom.u8(q + 1), rom.u16(q + 2))})
    return res


def build(rom, maps=None):
    """Map-centric graph: map -> entries -> {triggers, alist, spawns, scripts effects}."""
    entries = find_entries(rom)
    g = {"maps": defaultdict(lambda: {"entries": [], "triggers": {}, "alist": {}, "scripts": {}}), "unsized": []}
    for en in entries:
        if maps is not None and en["map"] not in maps:
            continue
        m = g["maps"][en["map"]]
        # entry script: walk from the 65 back to the start is unknown; walk from the 65 op
        b, p = en["bank"], en["ptr"]
        effs, bad = walk(rom, b, p, limit=200, own_entry=off(p, b))
        g["unsized"] += bad
        ent = {"at": en["at"], "effects": [x for x in effs if interesting(x)]}
        m["entries"].append(ent)
        for x in effs:
            if "trig_list" in x:
                for t in list21(rom, x["trig_list"]):
                    m["triggers"].setdefault("%02X" % (0xC0 + t["i"]), []).append(dict(t, list="21:%04X" % x["trig_list"], via=x["at"]))
            if "a_list" in x:
                for t in alist21(rom, x["a_list"]):
                    m["alist"].setdefault(t["cell"], []).append(dict(t, list="21:%04X" % x["a_list"], via=x["at"]))
    for mid, m in g["maps"].items():
        for col in (m["triggers"], m["alist"]):
            for k, lst in col.items():
                for t in lst:
                    s = t["script"]
                    if s in m["scripts"]:
                        continue
                    effs, bad = walk(rom, int(s[:2], 16), int(s[3:], 16), limit=60)
                    g["unsized"] += bad
                    m["scripts"][s] = [x for x in effs if interesting(x)]
    g["maps"] = dict(g["maps"])
    return g


KEYS = ("story_store", "writes", "reads", "test", "flagtest", "item", "rect", "cellw", "relw",
        "unpack", "load_map", "rebase", "spawn", "cases", "battle", "trig_list", "a_list")


def interesting(e):
    return any(k in e for k in KEYS)


def cell_xy(addr, width):
    d = (addr - 0xD000) & 0xFFFF
    return d % width, d // width


def cell_writers(g, mid, width, box):
    """Every op in a map's scripts whose destination lands in box (x0,y0,x1,y1)."""
    x0, y0, x1, y1 = box
    hits = []
    m = g["maps"].get(mid, {})
    allops = [(s, e) for s, lst in m.get("scripts", {}).items() for e in lst]
    allops += [(en["at"], e) for en in m.get("entries", []) for e in en["effects"]]
    for s, e in allops:
        if "rect" in e:
            r = e["rect"]
            dx, dy = cell_xy(r["dst"], width)
            w, h = r["w"] or 256, r["h"] or 256
            if dx <= x1 and dx + w - 1 >= x0 and dy <= y1 and dy + h - 1 >= y0:
                hits.append((s, e["at"], "rect", dx, dy, w, h))
        for k in ("cellw", "cell"):
            if k in e and "addr" in e[k]:
                cx, cy = cell_xy(e[k]["addr"], width)
                if x0 <= cx <= x1 and y0 <= cy <= y1:
                    hits.append((s, e["at"], k, cx, cy, 1, 1))
        if "relw" in e:
            hits.append((s, e["at"], "relw?", e["relw"].get("slot"), None, None, None))
    return hits


def story_chain(g):
    """story word -> [(map, script, at)] stores and the tests that select it."""
    stores, selects = defaultdict(list), defaultdict(list)
    for mid, m in g["maps"].items():
        src = [(s, lst) for s, lst in m["scripts"].items()] + [(en["at"], en["effects"]) for en in m["entries"]]
        for s, lst in src:
            for e in lst:
                if "story_store" in e:
                    stores[e["story_store"]].append((mid, s, e["at"]))
                if "cases" in e and any(r == ("story",) or (isinstance(r, (list, tuple)) and r[0] == "story") for r in e.get("test", [])):
                    for c in e["cases"]:
                        if "eq" in c:
                            selects[c["eq"]].append((mid, e["at"], c["to"]))
                        else:
                            for v in range(c["lo"], c["hi"] + 1):
                                selects[v].append((mid, e["at"], c["to"]))
    return stores, selects


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    rom = Rom(open(argv[1], "rb").read())
    g = build(rom)
    if "--json" in argv:
        out = argv[argv.index("--json") + 1]
        with open(out, "w") as f:
            json.dump(g, f, indent=0, sort_keys=True, default=str)
    if "--cells" in argv:
        i = argv.index("--cells")
        mid, x0, y0, x1, y1, w = (int(v) for v in argv[i + 1:i + 7])
        for h in cell_writers(g, mid, w, (x0, y0, x1, y1)):
            print("cell", h)
    stores, selects = story_chain(g)
    for w in sorted(stores):
        print("A123 <- $%02X:" % w, stores[w], "| selected by", selects.get(w, [])[:6])
    print("unsized ops:", len(set(g["unsized"])))
    return 0



def unpack(rom, o):
    """UnpackBytes (scripts/rle): $01-3F copy n | $81-BF fill n | $40-7F long copy | $C0-FF long fill."""
    out = []
    p = o
    while True:
        c = rom.u8(p)
        kind, n = c >> 6, c & 0x3F
        if kind in (0, 2) and n == 0:
            return out
        if kind == 0:
            out += [rom.u8(p + i) for i in range(1, n + 1)]
            p += 1 + n
        elif kind == 2:
            out += [rom.u8(p + 1)] * n
            p += 2
        else:
            n = (n << 8) | rom.u8(p + 1)
            if kind == 1:
                out += [rom.u8(p + 1 + i) for i in range(1, n + 1)]
                p += 2 + n
            else:
                out += [rom.u8(p + 2)] * n
                p += 3
        if len(out) > 0x10000:
            return out


def collision(rom, mid):
    """Map mid's base collision plane (block record, source slot 4) -> (w, cells)."""
    o = off(0x4000 + 15 * mid, 0x4F)
    ptr, bank = rom.u16(o + 12), rom.u8(o + 14)
    q = off(ptr, bank)
    return rom.u8(q), unpack(rom, q + 3)


def overlay_collision(rom, bank, ptr):
    """$68's second stream: skips 3 header bytes, unpacks to WRAM 6."""
    return unpack(rom, off(ptr, bank) + 3)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
