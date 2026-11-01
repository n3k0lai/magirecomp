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
put(d, 0x31, 0x6000, [0x65, m7 & 0xFF, m7 >> 8, 0x4F, 0x64, 0x00, 0x41, 0x94, 0x42])
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
put(d, 0x32, 0x6000, [0x65, m8 & 0xFF, m8 >> 8, 0x4F, 0x32, 0x31, 0x00, 0x64, 0, 0, 0x38, 0, 0, 0, 0x94, 0x42])
put(d, 0x31, 0x6400, [0x2E, 9, 18, 1, 2, 3, 0x27, 0x94])
# $94 resumes at the next byte; $27 does not. Species 72 is reached, 99 is not.
m9 = 0x4000 + 15 * 9
put(d, 0x33, 0x6000, [0x65, m9 & 0xFF, m9 >> 8, 0x4F,
                     0x94, 0x2E, 9, 72, 1, 2, 3, 0x27, 0x2E, 9, 99, 1, 2, 3, 0x94])
# $31's two triples are the post-battle scripts (win, then loss). A $27
# between the $31 and those bytes must not be what reaches them.
m10 = 0x4000 + 15 * 10
put(d, 0x33, 0x6100, [0x65, m10 & 0xFF, m10 >> 8, 0x4F,
                     0x31, 0x33, 0x00, 0x68, 0x33, 0x00, 0x69, 0x27, 0x2E, 9, 98, 1, 2, 3])
put(d, 0x33, 0x6800, [0x2E, 9, 12, 1, 2, 3, 0x27])
put(d, 0x33, 0x6900, [0x2E, 9, 3, 1, 2, 3, 0x27])

rom = G.Rom(bytes(d))
blocks, roots = S.build_blocks(rom)
g = S.Graph(blocks, roots)
sm = {sp: o for o, slot, sp, _ in S.summons(rom, g)}
ok(sm.get(13) == G.off(0x6207, 0x31), "species 13 summon reached through the 47 pick")
ok(4 in sm and 18 in sm, "both pick records and the grass script are walked")
ok(71 not in sm, "an unlinked summon is not reachable")
ok(sm.get(72) == G.off(0x6005, 0x33), "a summon after $94 is reached")
ok(99 not in sm, "a summon after $27 is not reached")
ok(sm.get(12) == G.off(0x6800, 0x33), "$31 win script is reached")
ok(sm.get(3) == G.off(0x6900, 0x33), "$31 loss script is reached")
ok(98 not in sm, "bytes after $27 are not a third summon")
ch31 = g.chains(sm[12])
ok(ch31 and ch31[0][1][0][0] == "op31", "species 12 is reached through $31")
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
ok("never summoned by a reachable script: [0, 1, 2, 5," in txt, "report lists never-summoned ids")

print("mn_secrets: %d failed" % fails)
sys.exit(1 if fails else 0)
