; Sound command with a 2-byte operand at BC: the phase step. The slot's
; wTagChannelFlags low nibble becomes 1 with bits 5-4 set, its wPhaseLevel
; and wPhaseValue word are cleared, and the operand word (low byte first) is
; stored as its wPhaseStep. The stream cursor advances by 2.

SoundCommandStartPhaseDown::
    ld a, [wSlotStreamIndex]
    ld e, a
    ld d, $00
    ld hl, wTagChannelFlags
    add hl, de
    ld a, [hl]
    and $F0
    or $31
    ld [hl], a
    xor a
    ld hl, wPhaseLevel
    add hl, de
    ld [hl], $00
    sla e
    ld hl, wPhaseValue
    add hl, de
    ld [hl+], a
    ld [hl], a
    ld l, c
    ld h, b
    ld a, [hl+]
    ld c, [hl]
    ld hl, wPhaseStep + 1
    add hl, de
    ld [hl-], a
    ld [hl], c
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $02
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
