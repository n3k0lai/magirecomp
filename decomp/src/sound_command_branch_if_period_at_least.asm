; Conditional branch command. Operand 0 at BC is a threshold. If the slot's
; wTagPeriodBaseHigh byte is at least that, SoundCommand06 handles the rest
; with BC past the threshold. Otherwise the 2-byte branch operand is skipped
; and the stream cursor is saved past it.

SoundCommandBranchIfPeriodAtLeast::
    ld a, [wSlotStreamIndex]
    sla a
    ld e, a
    ld d, $00
    ld hl, wTagPeriodBaseHigh
    add hl, de
    ld a, [bc]
    inc bc
    ld e, a
    ld a, [hl]
    cp e
    jp nc, SoundCommand06
    inc bc
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ret
