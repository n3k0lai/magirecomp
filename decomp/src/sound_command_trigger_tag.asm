; Sound command with a 2-byte operand (E then D) at BC that triggers another
; tag. The cursor is saved past it. For the current slot it gathers the
; slot's wExpirySlotHigh byte (D), wInstalledPriority (B) and
; wTagEnvelopeParam (E), with C = the first operand and A = the second.
; When bit 1 of the slot's wChannelFlagBase byte is set, $4F15 is used and a
; nonzero result sets that bit again on the slot it returns in C; otherwise
; PrimeChannelFromTag. A zero result returns. When the returned slot is the
; current one, wSoundStreamCursor is reloaded from its wSoundStreamPointers.

SoundCommandTriggerTag::
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [wSlotStreamIndex]
    ld c, a
    ld b, $00
    ld hl, wExpirySlotHigh
    add hl, bc
    ld a, d
    ld d, [hl]
    ld hl, wChannelFlagBase
    add hl, bc
    bit 1, [hl]
    push af
    ld hl, wInstalledPriority
    add hl, bc
    ld a, [hl]
    ld hl, wTagEnvelopeParam
    add hl, bc
    ld c, e
    ld b, a
    pop af
    ld e, [hl]
    jr z, .prime
    call $4F15
    ret z
    ld hl, wChannelFlagBase
    add hl, bc
    set 1, [hl]
    jr .check_slot
.prime:
    call PrimeChannelFromTag
    ret z
.check_slot:
    ld a, [wSlotStreamIndex]
    cp c
    ret nz
    sla c
    ld hl, wSoundStreamPointers
    add hl, bc
    ld a, [hl+]
    ld e, [hl]
    ld hl, wSoundStreamCursor
    ld [hl+], a
    ld [hl], e
    ret
