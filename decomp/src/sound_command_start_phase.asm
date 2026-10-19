; Sound command with a 2-byte operand at BC. For the current slot it sets
; the low nibble of wTagChannelFlags to $8 with bit 5 set (keeping the high
; nibble), sets wPhaseLevel to $0F, sets the slot's wPhaseValue word to
; $0F00, and stores the operand word (low byte first) at $DF68 + 2 * slot.
; The stream cursor advances by 2.

SoundCommandStartPhase::
    ld a, [wSlotStreamIndex]
    ld e, a
    ld d, $00
    ld hl, wTagChannelFlags
    add hl, de
    ld a, [hl]
    and $F0
    or $28
    ld [hl], a
    ld hl, wPhaseLevel
    add hl, de
    ld [hl], $0F
    sla e
    ld hl, wPhaseValue
    add hl, de
    xor a
    ld [hl+], a
    ld [hl], $0F
    ld l, c
    ld h, b
    ld a, [hl+]
    ld c, [hl]
    ld hl, $DF69
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
