"""Unit test for tools/mn_secrets.py on made-up bytes (no ROM).

Run: python3 tests/tools/mn_secrets_test.py
"""
import io
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "tools"))
import mn_story_graph as G  # noqa: E402
import mn_secrets as S  # noqa: E402

fails = 0


def ok(c, what):
    global fails
    if not c:
        fails += 1
        print("FAIL", what)


def put(d, bank, ptr, bs):
    o = G.off(ptr, bank)
    d[o:o + len(bs)] = bytes(bs)


d = bytearray(0x80 * 0x4000)
m7 = 0x4000 + 15 * 7
# map 7 entry: 65 <map 7> 4F ; 64 <trigger list 21:4100> ; 94
put(d, 0x31, 0x6000, [0x65, m7 & 0xFF, m7 >> 8, 0x4F, 0x64, 0x00, 0x41, 0x94])
put(d, 0x21, 0x4100, [1, 2, 0x31, 0x00, 0x61])
# trigger C0 script: 87 give ; 47 pick of 2 -> 31:6200 / 31:6300
put(d, 0x31, 0x6100, [0x87, 1, 2, 3, 0x47, 2, 0x31, 0x00, 0x62, 0x31, 0x00, 0x63])
# team A: 25 setup ; 2E slot 9 species 13 ; 27
put(d, 0x31, 0x6200, [0x25, 0, 0, 0, 0, 0, 0, 0x2E, 9, 13, 1, 2, 3, 0x27, 0x94])
# team B: 2E species 4 ; A4 chest ; 27
put(d, 0x31, 0x6300, [0x2E, 9, 4, 1, 2, 3, 0xA4, 0, 0, 0, 0, 0, 0, 0, 0x27, 0x94])
# unreachable (cut) team: 2E species 71
put(d, 0x31, 0x7000, [0x2E, 9, 71, 1, 2, 3, 0x27, 0x94])
# map 8 entry with a grass 32 script (bank, ptr, 2 more bytes) -> 31:6400 (species 18) and a weak op 38
m8 = 0x4000 + 15 * 8
put(d, 0x32, 0x6000, [0x65, m8 & 0xFF, m8 >> 8, 0x4F, 0x32, 0x31, 0x00, 0x64, 0, 0, 0x38, 0, 0, 0, 0x94])
put(d, 0x31, 0x6400, [0x2E, 9, 18, 1, 2, 3, 0x27, 0x94])

rom = G.Rom(bytes(d))
blocks, roots = S.build_blocks(rom)
g = S.Graph(blocks, roots)
sm = {sp: o for o, slot, sp, _ in S.summons(rom, g)}
ok(sm.get(13) == G.off(0x6207, 0x31), "species 13 summon reached through the 47 pick")
ok(4 in sm and 18 in sm, "both pick records and the grass script are walked")
ok(71 not in sm, "an unlinked summon is not reachable")
ok(g.maps(sm[13]) == [7], "species 13 is on map 7")
ok(g.maps(sm[18]) == [8], "grass script summon is on map 8")
ch = g.chains(sm[13])
ok(ch and [k for k, _ in ch[0][1]] == ["op47", "trigC0"], "chain: pick <- trigger C0")
ok(g.ops(rom, (0x87,)) == [G.off(0x6100, 0x31)], "87 give found")
ok(g.ops(rom, (0xA4,)) == [G.off(0x6306, 0x31)], "A4 chest found")
ok(g.ops(rom, S.WEAK) == [G.off(0x600A, 0x32)], "weak op 38 found")
out = io.StringIO()
S.report(rom, g, species=(13, 71), nspecies=20, out=out)
txt = out.getvalue()
ok("species 13: 1 summon(s)" in txt and "species 71: 0 summon(s)" in txt, "report counts per species")
ok("never summoned by a reachable script: [0, 1, 2, 3, 5," in txt, "report lists never-summoned ids")

print("mn_secrets: %d failed" % fails)
sys.exit(1 if fails else 0)
