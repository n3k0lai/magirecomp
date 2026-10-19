"""Minimal SM83 (Game Boy CPU) linear disassembler for task packets.

Packets only. Its text is a reading aid for the model, never pasted into src/
by the tool (AGENTS.md W3/O3: mgbdis-style dumps stay out of the tree).
"""

from __future__ import annotations

R8 = ["b", "c", "d", "e", "h", "l", "[hl]", "a"]
R16 = ["bc", "de", "hl", "sp"]
R16S = ["bc", "de", "hl", "af"]
CC = ["nz", "z", "nc", "c"]
ALU = ["add a,", "adc a,", "sub", "sbc a,", "and", "xor", "or", "cp"]
ROT = ["rlc", "rrc", "rl", "rr", "sla", "sra", "swap", "srl"]
INVALID = {0xD3, 0xDB, 0xDD, 0xE3, 0xE4, 0xEB, 0xEC, 0xED, 0xF4, 0xFC, 0xFD}

# kinds: "ret" (unconditional return), "jump" (unconditional jump),
# "call"/"cjump" (has target), "" otherwise.


def decode(rom: bytes, pos: int, cpu: int):
    """Return (length, text, kind, target_cpu or None)."""
    op = rom[pos]
    b1 = rom[pos + 1] if pos + 1 < len(rom) else 0
    b2 = rom[pos + 2] if pos + 2 < len(rom) else 0
    w = b1 | (b2 << 8)
    rel = cpu + 2 + (b1 - 256 if b1 > 127 else b1)
    if op in INVALID:
        return 1, f"db ${op:02X} ; invalid opcode", "invalid", None
    if op == 0xCB:
        x, y, z = b1 >> 6, (b1 >> 3) & 7, b1 & 7
        if x == 0:
            return 2, f"{ROT[y]} {R8[z]}", "", None
        return 2, f"{['', 'bit', 'res', 'set'][x]} {y}, {R8[z]}", "", None
    x, y, z = op >> 6, (op >> 3) & 7, op & 7
    p, q = y >> 1, y & 1
    if x == 1:
        if op == 0x76:
            return 1, "halt", "", None
        return 1, f"ld {R8[y]}, {R8[z]}", "", None
    if x == 2:
        return 1, f"{ALU[y]} {R8[z]}", "", None
    if x == 0:
        if z == 0:
            if y == 0: return 1, "nop", "", None
            if y == 1: return 3, f"ld [${w:04X}], sp", "", None
            if y == 2: return 2, "stop", "", None
            if y == 3: return 2, f"jr ${rel:04X}", "jump", rel
            return 2, f"jr {CC[y-4]}, ${rel:04X}", "cjump", rel
        if z == 1:
            if q == 0: return 3, f"ld {R16[p]}, ${w:04X}", "imm16", w
            return 1, f"add hl, {R16[p]}", "", None
        if z == 2:
            dst = ["[bc]", "[de]", "[hl+]", "[hl-]"][p]
            return 1, (f"ld {dst}, a" if q == 0 else f"ld a, {dst}"), "", None
        if z == 3: return 1, f"{'inc' if q == 0 else 'dec'} {R16[p]}", "", None
        if z == 4: return 1, f"inc {R8[y]}", "", None
        if z == 5: return 1, f"dec {R8[y]}", "", None
        if z == 6: return 2, f"ld {R8[y]}, ${b1:02X}", "", None
        return 1, ["rlca", "rrca", "rla", "rra", "daa", "cpl", "scf", "ccf"][y], "", None
    # x == 3
    if z == 0:
        if y < 4: return 1, f"ret {CC[y]}", "", None
        if y == 4: return 2, f"ldh [$FF{b1:02X}], a", "", None
        if y == 5: return 2, f"add sp, {b1 - 256 if b1 > 127 else b1}", "", None
        if y == 6: return 2, f"ldh a, [$FF{b1:02X}]", "", None
        return 2, f"ld hl, sp{'+' if b1 < 128 else '-'}{abs(b1 - 256 if b1 > 127 else b1)}", "", None
    if z == 1:
        if q == 0: return 1, f"pop {R16S[p]}", "", None
        return 1, ["ret", "reti", "jp hl", "ld sp, hl"][p], ("ret" if p < 2 else "jump" if p == 2 else ""), None
    if z == 2:
        if y < 4: return 3, f"jp {CC[y]}, ${w:04X}", "cjump", w
        return ([1, 3, 1, 3][y - 4],
                ["ldh [c], a", f"ld [${w:04X}], a", "ldh a, [c]", f"ld a, [${w:04X}]"][y - 4],
                "mem" if y in (5, 7) else "", w if y in (5, 7) else None)
    if z == 3:
        if y == 0: return 3, f"jp ${w:04X}", "jump", w
        if y == 6: return 1, "di", "", None
        if y == 7: return 1, "ei", "", None
    if z == 4 and y < 4: return 3, f"call {CC[y]}, ${w:04X}", "call", w
    if z == 5:
        if q == 0: return 1, f"push {R16S[p]}", "", None
        if p == 0: return 3, f"call ${w:04X}", "call", w
    if z == 6: return 2, f"{ALU[y]} ${b1:02X}", "", None
    if z == 7: return 1, f"rst ${y*8:02X}", "call", y * 8
    return 1, f"db ${op:02X}", "invalid", None


def routine(rom: bytes, file_addr: int, limit: int, stop_at_end: bool = True):
    """Decode from file_addr until an unconditional ret/jump (or limit bytes).

    Returns list of (file_addr, cpu, raw_bytes, text, kind, target) and why it stopped.
    Note: an unconditional exit may be followed by more of the same routine if a
    forward branch skips over it; we continue past an exit when an earlier branch
    targets an address beyond it (within limit).
    """
    bank = file_addr >> 14
    base = 0 if bank == 0 else bank * 0x4000 - 0x4000
    out = []
    pos = file_addr
    furthest = file_addr
    stop = "limit"
    while pos < file_addr + limit and pos < len(rom):
        cpu = pos - base
        n, text, kind, target = decode(rom, pos, cpu)
        out.append((pos, cpu, rom[pos:pos + n], text, kind, target))
        if kind in ("cjump", "jump") and target is not None:
            tf = target + base
            if file_addr <= tf < file_addr + limit:
                furthest = max(furthest, tf)
        pos += n
        if kind == "invalid":
            stop = "invalid"
            break
        if kind in ("ret", "jump") and stop_at_end and pos > furthest:
            stop = kind
            break
    return out, stop


def data_score(rom: bytes, start: int, n: int = 64) -> float:
    """Heuristic 0..1: how much a span looks like data rather than code."""
    chunk = rom[start:start + n]
    if not chunk:
        return 1.0
    bad = sum(1 for b in chunk if b in INVALID)
    zeros = chunk.count(0) + chunk.count(0xFF)
    # 2bpp tiles: many repeated pairs (lo, hi) and long zero runs.
    pairs = sum(1 for i in range(0, len(chunk) - 1, 2) if chunk[i] == chunk[i + 1])
    score = 0.0
    score += min(1.0, bad * 0.34)
    score += 0.5 * (zeros / len(chunk))
    score += 0.3 * (pairs / max(1, len(chunk) // 2))
    return min(1.0, score)
