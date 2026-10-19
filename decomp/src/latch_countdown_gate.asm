; SoundRequestBit2 calls this at $57CF. The caller at $0709 maps ROM
; bank $30, then calls here. This routine does not write rROMB0.
;
; Bit 4 of $DFA6 is a pending request. xor a makes the early return
; leave 0 in A when that bit is clear. When it is set, clear bit 4,
; set bit 7 (the gate StepSoundCountdowns tests), and return 1 in A.

LatchCountdownGate:
    xor a
    ld hl, $dfa6
    bit 4, [hl]
    ret z
    res 4, [hl]
    set 7, [hl]
    ld a, $01
    ret
