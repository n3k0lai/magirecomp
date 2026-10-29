"""Unit test for tools/mn_story_graph.py on made-up bytes (no ROM).

Run: python3 tests/tools/mn_story_graph_test.py
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "tools"))
import mn_story_graph as M  # noqa: E402

fails = 0


def ok(c, what):
    global fails
    if not c:
        fails += 1
        print("FAIL", what)


def put(d, bank, ptr, bs):
    o = M.off(ptr, bank)
    d[o:o + len(bs)] = bytes(bs)


d = bytearray(0x80 * 0x4000)
# map 3 record in bank $4F: collision source (slot 4) at +12..14 -> 30:5000
put(d, 0x4F, 0x4000 + 15 * 3 + 12, [0x00, 0x50, 0x30])
# block record: w=4, len, then RLE: fill 16 x $08, terminator
put(d, 0x30, 0x5000, [4, 16, 0, 0x90, 0x08, 0x00])
# entry script in bank 31: 65 <map 3> 4F ; 64 <trig list 21:4100> ; 69 <a list 21:4200> ; 94
mrec = 0x4000 + 15 * 3
put(d, 0x31, 0x6000, [0x65, mrec & 0xFF, mrec >> 8, 0x4F, 0x64, 0x00, 0x41, 0x69, 0x00, 0x42, 0x94, 0x42])
# $94 yields a frame and resumes at the next byte (ScriptVM, mark_script_done_21b2.asm),
# so every made-up script here parks with $42 after it
# trigger list: 1 entry, kind 2 (down), script 31:6100
put(d, 0x21, 0x4100, [1, 2, 0x31, 0x00, 0x61])
# A list: 2 entries of 4 bytes (kind, bank, ptr)
put(d, 0x21, 0x4200, [2, 0, 0x31, 0x00, 0x62, 1, 0x31, 0x10, 0x62])
# trigger script: A9 store story $10 ; AF A126 |= $80 ; 94
put(d, 0x31, 0x6100, [0xA9, 0x10, 0x00, 0xAF, 0x26, 0xA1, 0x80, 0x94, 0x42])
# A $40 script: 87 give item ; 94   ($41: 94)
put(d, 0x31, 0x6200, [0x94, 0x42])
put(d, 0x31, 0x6210, [0x94, 0x42])

# bleed: map 4's entry far-jumps (45) to map 5's entry, which sets its own trigger list.
# Map 5's triggers must not be attributed to map 4.
m4, m5 = 0x4000 + 15 * 4, 0x4000 + 15 * 5
put(d, 0x31, 0x6800, [0x65, m4 & 0xFF, m4 >> 8, 0x4F, 0x45, 0x31, 0x00, 0x70])
put(d, 0x31, 0x7000, [0x65, m5 & 0xFF, m5 >> 8, 0x4F, 0x64, 0x00, 0x43, 0x94, 0x42])
put(d, 0x21, 0x4300, [1, 1, 0x31, 0x10, 0x62])

rom = M.Rom(bytes(d))
ents = M.find_entries(rom)
ok(any(e["map"] == 3 and e["at"] == "31:6000" for e in ents), "entry for map 3 found")
g = M.build(rom, maps={3})
m = g["maps"][3]
ok(m["triggers"]["C0"][0]["kind"] == 2, "trigger kind read")
ok(m["triggers"]["C0"][0]["script"] == "31:6100", "trigger script read")
ok(m["alist"]["40"][0]["script"] == "31:6200", "A $40 stride")
ok(m["alist"]["41"][0]["script"] == "31:6210", "A $41 uses the 4-byte stride")
eff = m["scripts"]["31:6100"]
ok(any(e.get("story_store") == 0x10 for e in eff), "A9 story store decoded")
ok(any(w.get("addr") == 0xA126 and w.get("or") == 0x80 for e in eff for w in e.get("writes", [])), "AF flag OR decoded")
stores, _ = M.story_chain(g)
ok(stores[0x10] == [(3, "31:6100", "31:6100")], "story chain store")
w, cells = M.collision(rom, 3)
ok(w == 4 and len(cells) == 16 and all(c == 8 for c in cells), "collision unpack")
ok(M.cell_xy(0xD000 + 2 * 4 + 1, 4) == (1, 2), "cell address -> x,y")

g45 = M.build(rom, maps={4, 5})
ok("C0" not in g45["maps"][4]["triggers"], "no trigger bleed through a 45 jump into another map's entry")
ok(g45["maps"][5]["triggers"]["C0"][0]["kind"] == 1, "map 5 keeps its own trigger")

# $05: operand bytes 9-11 are the record's running script (opcode_05.asm puts them
# next to DispatchScriptOpcode); 12-14 are followed too
r = bytearray(0x80 * 0x4000)
put(r, 0x32, 0x4000, [0x05, 0x01, 0x6B, 0x4A, 3, 4, 0, 0, 0, 0x32, 0x00, 0x41, 0x22, 0x05, 0x40, 0x42])
rr = M.Rom(bytes(r))
n, t = rr.insn(M.off(0x4000, 0x32))
ok(n == 15 and (0x32, 0x4100) in t, "05 follows the running script at operand 9-11")
# $8E: both records, and a pick goes on past the length-prefixed list
put(r, 0x33, 0x4000, [0x8E, 0x33, 0x00, 0x45, 0x33, 0x00, 0x46, 0x02, 0x00, 0x00, 0x00,
                      0xA9, 0x0D, 0x00, 0x42])
put(r, 0x33, 0x4500, [0x42])
put(r, 0x33, 0x4600, [0x42])
eff, bad = M.walk(M.Rom(bytes(r)), 0x33, 0x4000)
ok(any(e.get("story_store") == 0x0D for e in eff), "8E pick path walks past its list")

print("mn_story_graph: %d failed" % fails)
sys.exit(1 if fails else 0)
