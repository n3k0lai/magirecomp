"""Translate the bank-7 relic routines (7:$6BD5-$6FCE) of the matching decomp into the
engine's relic op lists. Every instruction must be consumed by a pattern."""
import re, sys
from srclib import Src
S = Src(sys.argv[1])
def h(x): return int(x.replace("$", ""), 16)
def translate(ins):
    ops, i = [], 0
    def at(j, pat): return j < len(ins) and re.fullmatch(pat, ins[j])
    lastor = None
    while i < len(ins):
        l = ins[i]
        if l == "ret": i += 1; continue
        m = at(i + 1, r"ld bc, \$00([0-9A-F]{2})")
        if l == "ld hl, $D110" and m:
            if at(i + 2, r"ld e, \$63") and (n := at(i + 3, r"ld a, \$([0-9A-F]{2})")) and at(i + 4, "call AddACapByteAtBc"):
                ops.append(("up", h(m.group(1)), h(n.group(1)))); i += 5; continue
            if (n := at(i + 2, r"ld a, \$([0-9A-F]{2})")) and at(i + 3, "call SubAFloorByteAtBc"):
                ops.append(("dn", h(m.group(1)), h(n.group(1)))); i += 4; continue
        # ld hl,ADDR; ld a,N; or [hl]; ld [hl],a
        if (m := re.fullmatch(r"ld hl, \$([0-9A-F]{4})", l)) and (n := at(i + 1, r"ld a, \$([0-9A-F]{2})")) and ins[i + 2:i + 4] == ["or [hl]", "ld [hl], a"]:
            ops.append(("or", h(m.group(1)), h(n.group(1)))); lastor = h(m.group(1)); i += 4; continue
        # ld a,N; ld hl,ADDR; or [hl]; ld [hl],a
        if (n := re.fullmatch(r"ld a, \$([0-9A-F]{2})", l)) and (m := at(i + 1, r"ld hl, \$([0-9A-F]{4})")) and ins[i + 2:i + 4] == ["or [hl]", "ld [hl], a"]:
            ops.append(("or", h(m.group(1)), h(n.group(1)))); lastor = h(m.group(1)); i += 4; continue
        # ld hl,ADDR2; or [hl]; ld [hl],a with A = the byte just stored
        if (m := re.fullmatch(r"ld hl, \$([0-9A-F]{4})", l)) and ins[i + 1:i + 3] == ["or [hl]", "ld [hl], a"] and lastor:
            ops.append(("orfrom", h(m.group(1)), lastor)); i += 3; continue
        if ins[i:i + 4] == ["ld a, [$D119]", "ld h, a", "ld a, [$D11A]", "ld l, a"] and (n := at(i + 4, r"ld c, \$([0-9A-F]{2})")) and \
           ins[i + 5:i + 13] == ["ld b, $00", "add hl, bc", "ld a, h", "ld [$D119], a", "ld [$D117], a", "ld a, l", "ld [$D11A], a", "ld [$D118], a"]:
            ops.append(("maxe", h(n.group(1)))); i += 13; continue
        if ins[i:i + 2] == ["xor a", "ld [$D120], a"]:
            ops.append(("set", 0xD120, 0)); i += 2; continue
        if ins[i:i + 5] == ["ld hl, $D111", "ld a, [hl]", "and $0F", "or $30", "ld [hl], a"]:
            ops.append(("andor", 0xD111, 0x0F, 0x30)); i += 5; continue
        raise SystemExit("unparsed at %d: %s" % (i, ins[i:]))
    return ops
addrs = sorted({int(a, 16) for a in sys.argv[2:]})
out = []
for a in addrs:
    ops = translate(S.routine(7, a))
    def fmt(o):
        k = o[0]; rest = ", ".join(("0x%X" % v) for v in o[1:])
        return '{ "%s", %s }' % (k, rest) if rest else '{ "%s" }' % k
    out.append("  [0x%04X] = { %s }," % (a, ", ".join(fmt(o) for o in ops)))
print("\n".join(out))
