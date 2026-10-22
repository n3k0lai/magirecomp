import re, sys, json, subprocess
from srclib import Src
S = Src(sys.argv[1])
def h(x): return int(x.replace("$", ""), 16)
LAB = S.labels()
def norm(l):
    m = re.fullmatch(r"(ld (?:bc|hl|de), )([A-Za-z_]\w*)", l)
    if m and m.group(2) in LAB: return m.group(1) + "$%04X" % LAB[m.group(2)][1]
    return l
def translate(ins):
    ins = [norm(x) for x in ins]
    ops, i, rest = [], 0, []
    def at(j, pat):
        return j < len(ins) and re.fullmatch(pat, ins[j])
    while i < len(ins):
        l = ins[i]
        if l == "ret z": ops.append("z"); i += 1; continue
        if l == "ld a, $02" and at(i+1, r"ld \[\$D071\], a"): ops.append("two"); i += 2; continue
        m = at(i+1, r"ld bc, \$([0-9A-F]{4})")
        if l == "ld a, $4C" and m and at(i+2, "call StagePointerUnlessD0B6Matches"):
            ops.append(["anim", h(m.group(1))]); i += 3; continue
        if l == "ld a, $4C" and at(i+1, "call StagePointer5A32"):
            ops.append(["anim", 0x5A32]); i += 2; continue
        if l == "call AddDividerStep" and (m := at(i+1, r"cp \$([0-9A-F]{2})")) and at(i+2, "ret nc"):
            t = h(m.group(1))
            if at(i+3, r"ld hl, \$4B45") and at(i+4, r"ld e, \$05") and at(i+5, "call CallBankedHL"):
                ops.append(["kill", t]); i += 6; continue
            ops.append(["chance", t]); i += 3; continue
        if l == "ld hl, $D110" and (m := at(i+1, r"ld bc, \$00([0-9A-F]{2})")):
            j = i + 2; cap = False
            if at(j, r"ld e, \$63"): cap = True; j += 1
            n = at(j, r"ld a, \$([0-9A-F]{2})")
            call = at(j+1, r"call (AddACapByteAtBc|SubAFloorByteAtBc)")
            if n and call:
                # message: ld a,[$D112]; cp $58; ret nc; ld [$D0C7],a; ld a,N; ld [$D0C8],a; ld hl,$C71B; ld a,$4C; [hl+]; ld a,LO;[hl+]; ld a,HI ...
                k = j + 2
                seg = ins[k:k+18]
                lo = re.fullmatch(r"ld a, \$([0-9A-F]{2})", seg[9]).group(1); hi = re.fullmatch(r"ld a, \$([0-9A-F]{2})", seg[11]).group(1)
                assert seg[0] == "ld a, [$D112]" and seg[1] == "cp $58" and seg[2] == "ret nc", seg
                assert seg[-1] == "call Run560EThenWaitC71D", seg
                ops.append(["up" if "Add" in call.group(1) else "dn", h(m.group(1)), h(n.group(1)), h(hi + lo)])
                ops.append("stopmagi")
                i = k + 18; continue
        if (m := re.fullmatch(r"ld a, \$([0-9A-F]{2})", l)) and at(i+1, r"ld hl, \$D110") and at(i+2, "call TrySetBitPairAtPlus14"):
            b = h(m.group(1)); j = i + 3
            assert ins[j:j+2] == ["and a", "ret z"], ins[j:j+3]; j += 2
            if ins[j:j+4] == ["ld a, $30", "ld hl, $D0DA", "or [hl]", "ld [hl], a"]:
                ops.append("ignite"); j += 4
            else: ops.append(["bit", b])
            assert ins[j] == f"ld a, ${b:02X}" and ins[j+1] == "call StageNameTextAndScript41C1", ins[j:j+2]
            i = j + 2; continue
        if l == "ld c, $07" and at(i+1, "call MaskDivByC") and at(i+2, "inc a"):
            j = i + 3; k = 1
            while ins[j] == "add a, a": k *= 2; j += 1
            assert ins[j:j+4] == ["ld [$D077], a", "ld a, $01", "ld [$D070], a", "ld [$D076], a"], ins[j:j+4]
            ops.append(["heal", k]); i = j + 4; continue
        if l == "ld a, $10" and ins[i+1:i+6] == ["ld [$D0C5], a", "ld [$D0C6], a", "ld hl, $4595", "ld e, $05", "call CallBankedHL"]:
            ops.append("drain"); i += 6; continue
        if l == "ld hl, $66D2" and ins[i+1:i+3] == ["ld e, $07", "call CallBankedHL"]:
            ops.append("cure"); i += 3; continue
        if l == "ret": i += 1; continue
        rest.append(l); i += 1
    return ops, rest
out = {}
for a in [int(x, 16) for x in sys.argv[2:]]:
    ins = S.routine(2, a)
    ops, rest = translate(ins)
    out["%04X" % a] = {"ops": ops, "unparsed": rest}
json.dump(out, sys.stdout, indent=None)
