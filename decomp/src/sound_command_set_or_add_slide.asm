; Sound command with a 3-byte operand block at BC (slot 3 skips it). Sets
; bit 5 of the slot's wChannelFlagBase byte. Operand 0 is a mode; operands
; 1-2 are a word (high, low). Mode 0 stores the word as the slot's
; wPeriodSum. Otherwise wPeriodSum is cleared and the word is added to the
; slot's wSlideSumA, with the high byte wrapped into 0-$53. The stream cursor
; advances by 3.

SoundCommandSetOrAddSlide::
    ld a, [wSlotStreamIndex]
    cp $03
    jr z, .advance
    ld e, a
    ld d, $00
    ld hl, wChannelFlagBase
    add hl, de
    set 5, [hl]
    ld l, c
    ld h, b
    ld a, [hl+]
    and a
    ld a, [hl+]
    ld c, [hl]
    ld b, a
    jr nz, .add_slide
    sla e
    ld hl, wPeriodSum
    add hl, de
    ld a, c
    ld [hl+], a
    ld [hl], b
    jr .advance

.add_slide:
    sla e
    ld hl, wPeriodSum
    add hl, de
    xor a
    ld [hl+], a
    ld [hl], a
    ld hl, wSlideSumA
    add hl, de
    ld a, [hl]
    add a, c
    ld [hl+], a
    ld a, [hl]
    adc a, b
    ld [hl], a
    bit 7, a
    jr z, .check_high
    add a, $54
    ld [hl], a
    jr .advance
.check_high:
    cp $54
    jr c, .advance
    sub $54
    ld [hl], a

.advance:
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $03
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
