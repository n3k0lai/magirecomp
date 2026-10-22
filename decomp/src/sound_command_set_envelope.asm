; Sound command with a 1-byte operand at BC: the new low nibble of the
; slot's envelope register. The cursor is saved past it; the wave slot (2)
; returns. Otherwise wTagChannelFlags gets low nibble 0 with bit 5 set, and
; the value (wChannelLevels << 4) | operand is written straight to the slot's
; envelope register through EnvelopeRegisterBySlot. When bit 3 of that value
; (envelope increase) is set, the slot's wTagEnvelopeParam is cleared.

SoundCommandSetEnvelope::
    ld a, [bc]
    ld e, a
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [wSlotStreamIndex]
    cp $02
    ret z
    ld c, e
    ld e, a
    ld d, $00
    ld hl, wTagChannelFlags
    add hl, de
    ld a, [hl]
    and $F0
    or $20
    ld [hl], a
    ld hl, wChannelLevels
    add hl, de
    ld a, [hl]
    swap a
    or c
    bit 3, a
    jr z, .write
    ld hl, wTagEnvelopeParam
    add hl, de
    ld [hl], $00
.write:
    ld hl, EnvelopeRegisterBySlot
    add hl, de
    ld c, [hl]
    ldh [c], a
    ret

; Low bytes of the envelope register for slots 0, 1 and 2. Slot 3 reads the
; next byte, $21 (rNR42), which is the opcode of the routine that follows.
EnvelopeRegisterBySlot:
    INCBIN "roms/magination.gbc", $C09A9, $3
