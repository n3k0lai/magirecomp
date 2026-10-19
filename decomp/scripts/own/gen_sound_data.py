#!/usr/bin/env python3
"""Generate src/sound_data.asm: bank $30 $5A75-$7FFF from the ROM.

Streams are decoded with the command lengths of the handlers in the word
table at $4DA6 (see scripts/own/music-format.md). Everything else is
written as labeled db/dw. Rerun after changing the macro names; make
verify checks the bytes.
"""
import collections

ROM = "roms/magination.gbc"
d = open(ROM, "rb").read()
BANKOFF = 0x30 * 0x4000 - 0x4000
START, END = 0x5A75, 0x8000
BASE = 0x5A88
NSTREAMS = 50


def r(a):
    return d[BANKOFF + a]


def w(a):
    return r(a) | r(a + 1) << 8


# opcode: (macro, operand kinds). kinds: b = byte, W = big-endian target
# from SoundStreamTable, R = big-endian target relative to the next command,
# w = little-endian word, h = big-endian word (not an address)
CMD = {
    0x00: ("snd_end", ""), 0x01: ("snd_cmd01", "bbb"), 0x02: ("snd_cmd02", "bbbbb"),
    0x03: ("snd_cmd03", "bbbbb"), 0x04: ("snd_wait", "bbbb"), 0x05: ("snd_loop", "bR"),
    0x06: ("snd_jump", "W"), 0x07: ("snd_slide_toward", "h"), 0x08: ("snd_slide", "bh"),
    0x09: ("snd_env_mix", "b"), 0x0A: ("snd_output", "b"), 0x0B: ("snd_random_period", "bbbb"),
    0x0C: ("snd_duty", "b"), 0x0D: ("snd_release", ""), 0x0E: ("snd_skip", "b"),
    0x0F: ("snd_phase_script", "b"), 0x10: ("snd_noise", "b"), 0x11: ("snd_phase_up", "w"),
    0x12: ("snd_countdown", "b"), 0x13: ("snd_envelope", "b"), 0x14: ("snd_slide_rel", "h"),
    0x15: ("snd_if_period", "bW"), 0x16: ("snd_if_random", "bW"), 0x17: ("snd_if_envelope", "bW"),
    0x18: ("snd_loop_point", "W"), 0x19: ("snd_clear_loop", ""), 0x1A: ("snd_df33_bit", "b"),
    0x1B: ("snd_glide", "bbbb"), 0x1C: ("snd_priority", "bb"), 0x1D: ("snd_wave_sweep", "bbbb"),
    0x1E: ("snd_load_wave_sweep", "bbbb"), 0x1F: ("snd_clear_fx", ""), 0x20: ("snd_clear_fx_slide", ""),
    0x21: ("snd_select_wave", "b"), 0x22: ("snd_step_wave", ""), 0x23: ("snd_end_23", ""),
    0x24: ("snd_reset_wave", "b"), 0x25: ("snd_restart_wave", ""), 0x26: ("snd_trigger_tag", "bb"),
    0x27: ("snd_phase_down", "w"), 0x28: ("snd_env_level", "b"), 0x29: ("snd_priority_29", "bb"),
}
SIZE = {"b": 1, "W": 2, "R": 2, "w": 2, "h": 2}


def oplen(c):
    return sum(SIZE[k] for k in CMD[c][1])


def walk():
    starts = [BASE + w(BASE + 2 * i) for i in range(NSTREAMS)]
    seen, targets, todo = {}, set(starts), list(starts)
    while todo:
        a = todo.pop()
        while a not in seen:
            c = r(a)
            n = oplen(c)
            seen[a] = c
            nxt = a + 1 + n
            o = 1
            for k in CMD[c][1]:
                if k == "W":
                    t = BASE + (r(a + o) << 8 | r(a + o + 1))
                    targets.add(t)
                    todo.append(t)
                elif k == "R":
                    t = (nxt + (r(a + o) << 8 | r(a + o + 1))) & 0xFFFF
                    targets.add(t)
                    todo.append(t)
                o += SIZE[k]
            if c in (0x00, 0x23, 0x0D, 0x06):
                break
            a = nxt
    return starts, seen, targets


def main():
    starts, seen, targets = walk()
    sidx = {a: i for i, a in reversed(list(enumerate(starts)))}
    names = {}
    cur = None
    local = collections.Counter()
    for a in sorted(set(seen) | targets):
        if a in sidx:
            cur = f"SfxStream{sidx[a]:02d}"
            names[a] = cur
        elif a in targets:
            local[cur] += 1
            names[a] = f"{cur}.part{local[cur]}"
    hi_stream = max(a + 1 + oplen(c) for a, c in seen.items())
    out = []
    P = out.append
    P(HEADER)
    a = START
    # $5A75-$5A78
    P("SoundDataLead::")
    P("    db " + ", ".join(f"${r(x):02X}" for x in range(0x5A75, 0x5A79)) + "  ; read as part of the nibble table that ends at $5A78")
    P("")
    P("SoundDataHeader::")
    P("    dw PhaseScriptTable - SoundDataHeader    ; $5A79, used by SoundCommandPhaseScript")
    P("    dw SlotEntries - SoundDataHeader         ; $5A7B, used by OpenSlotChannel")
    P(f"    db ${r(0x5A7D):02X}                                ; $5A7D, slot entry count (OpenSlotChannel limit)")
    P("    dw WaveRecords - SoundDataHeader         ; $5A7E, used by LookupWaveRecord")
    P(f"    db ${r(0x5A80):02X}                                ; $5A80, wave limit (StepWaveSlot)")
    P(f"    db ${r(0x5A81):02X}")
    if 0x5A79 + w(0x5A82) < hi_stream:
        P(f"    dw ${w(0x5A82):04X}  ; $5A82, StepWaveSlot's wave index table: ${0x5A79 + w(0x5A82):04X}, inside the last stream command")
    else:
        P("    dw WaveIndexTable - SoundDataHeader      ; $5A82, used by StepWaveSlot")
    P(f"    db ${r(0x5A84):02X}                                ; $5A84, wave index count (StepWaveSlot)")
    P("    dw SongList - SoundDataHeader            ; $5A85, used by InstallSoundIndex")
    P("    db SONG_COUNT                            ; $5A87, InstallSoundIndex limit")
    P("")
    P("; Stream table at $5A88. SoundCommand06 and the branch commands add their")
    P("; big-endian operand to this address, so every stream offset is from here.")
    P("SoundStreamTable::")
    for i, s in enumerate(starts):
        P(f"    dw {names[s]} - SoundStreamTable")
    P("")
    a = BASE + 2 * NSTREAMS
    while a < hi_stream:
        if a in names and "." not in names[a]:
            P("")
            P(f"{names[a]}::")
        elif a in names:
            P("." + names[a].split(".")[1] + ":")
        if a not in seen:
            P(f"    db ${r(a):02X}  ; not reached from any stream")
            a += 1
            continue
        c = r(a)
        mac, kinds = CMD[c]
        args, o = [], 1
        for k in kinds:
            if k == "b":
                args.append(f"${r(a + o):02X}")
            elif k in "WR":
                t = BASE + (r(a + o) << 8 | r(a + o + 1)) if k == "W" else (a + 1 + oplen(c) + (r(a + o) << 8 | r(a + o + 1))) & 0xFFFF
                args.append(names[t])
            elif k == "w":
                args.append(f"${w(a + o):04X}")
            elif k == "h":
                args.append(f"${r(a + o) << 8 | r(a + o + 1):04X}")
            o += SIZE[k]
        P(f"    {mac}" + (" " + ", ".join(args) if args else ""))
        a += 1 + oplen(c)
    assert a == hi_stream
    tables = [
        (0x5A79 + w(0x5A82), "WaveIndexTable", "StepWaveSlot indexes this by $DF1A"),
        (0x5A79 + w(0x5A79), "PhaseScriptTable", "SoundCommandPhaseScript: little-endian offsets from SoundDataHeader"),
        (0x5A79 + w(0x5A7B), "SlotEntries", "OpenSlotChannel: tag, priority, period high byte, envelope nibble"),
        (0x5A79 + w(0x5A7E), "WaveRecords", "LookupWaveRecord: 6-byte records: pointer, frame count, E, bank - $30 (16-byte wave frames in bank $31)"),
        (0x5A79 + w(0x5A85), "SongList", "InstallSoundIndex: wSoundIndex -> (bank - $30, pointer) of a song in banks $32-$3C"),
    ]
    t = len(d[BANKOFF + START:BANKOFF + END].rstrip(b"\0")) + START
    marks = sorted(x for x in tables if x[0] >= hi_stream)
    P("")
    for i, (ta, nm, why) in enumerate(marks):
        if a < ta:
            emit_db(P, a, ta)
            a = ta
        assert a == ta, (hex(a), hex(ta))
        nxt = marks[i + 1][0] if i + 1 < len(marks) else t
        P(f"; {why}")
        P(f"{nm}::")
        step = 4 if nm == "SlotEntries" else 16
        if nm == "SlotEntries":
            for x in range(ta, min(nxt, ta + 4 * r(0x5A7D)), 4):
                P("    db " + ", ".join(f"${r(x + k):02X}" for k in range(4)))
            a = ta + 4 * r(0x5A7D)
            if a < nxt:
                emit_db(P, a, nxt)
        elif nm == "PhaseScriptTable":
            emit_db(P, ta, nxt)
        elif nm == "WaveRecords":
            for x in range(ta, nxt, 6):
                P(f"    dw ${w(x):04X}, ${w(x + 2):04X}\n    db ${r(x + 4):02X}, ${r(x + 5):02X}")
        elif nm == "SongList":
            seen = {}
            for k in range(r(0x5A87)):
                x = ta + 3 * k
                key = (r(x), w(x + 1))
                seen.setdefault(key, k)
                P(f"    db BANK(Song{seen[key]:02d}) - BANK(@)\n    dw Song{seen[key]:02d}")
            P(f"DEF SONG_COUNT EQU {r(0x5A87)}")
            x = ta + 3 * r(0x5A87)
            emit_db(P, x, t)
        else:
            emit_db(P, ta, nxt)
        a = nxt
    P("")
    P(f"    ds ${END - t:X}, $00 ; zero padding to the end of bank $30")
    open("src/sound_data.asm", "w").write("\n".join(out) + "\n")


def emit_db(P, a, b):
    for x in range(a, b, 16):
        P("    db " + ", ".join(f"${r(y):02X}" for y in range(x, min(x + 16, b))))


HEADER = '''; Bank $30 sound data, $5A75-$7FFF. Generated by scripts/own/gen_sound_data.py.
; The format is in scripts/own/music-format.md. Every stream below is
; one or more commands from the table at $4DA6, decoded with the operand
; lengths of those handlers. Jumps and branches are labels, so moving a
; stream moves its offsets too.

INCLUDE "src/sound_macros.inc"
'''

if __name__ == "__main__":
    main()
