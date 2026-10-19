; Sound command with a 2-byte operand (high, low) at BC: a loop target
; offset from $5A88. The resulting stream address is stored in the slot's
; wStreamLoopWord and the stream cursor advances by 2.

SoundCommandSetLoopPoint::
    ld l, c
    ld h, b
    ld a, [hl+]
    ld e, [hl]
    ld d, a
    ld hl, $5A88
    add hl, de
    ld c, l
    ld b, h
    ld a, [wSlotStreamIndex]
    sla a
    ld e, a
    ld d, $00
    ld hl, wStreamLoopWord
    add hl, de
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $02
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
