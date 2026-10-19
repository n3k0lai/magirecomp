; Sound command with a 2-byte operand (high, low) at BC: a slide target
; relative to the slot's wExpirySlotHighPrev byte. The cursor is saved past
; it; slot 3 returns. Otherwise the slot's flag bit 5 is set and
; (target + offset<<8) minus the slot's wSlideSumA word is stored as its
; wPeriodSum word.

SoundCommandSlideRelative::
    ld a, [bc]
    inc bc
    ld d, a
    ld a, [bc]
    inc bc
    ld e, a
    ld hl, wSoundStreamCursor
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [wSlotStreamIndex]
    cp $03
    ret z
    ld c, a
    ld b, $00
    ld hl, wChannelFlagBase
    add hl, bc
    set 5, [hl]
    ld hl, wExpirySlotHighPrev
    add hl, bc
    ld a, d
    add a, [hl]
    ld d, a
    sla c
    ld hl, wSlideSumA
    add hl, bc
    ld a, e
    sub [hl]
    inc hl
    ld e, a
    ld a, d
    sbc a, [hl]
    ld hl, wPeriodSum + 1
    add hl, bc
    ld [hl-], a
    ld [hl], e
    ret
