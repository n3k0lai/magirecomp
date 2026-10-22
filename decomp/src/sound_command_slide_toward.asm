; Sound command with a 2-byte operand (high, low) at BC. The stream cursor is
; saved past it; slot 3 returns there. Otherwise bit 5 of the slot's
; wChannelFlagBase byte is set and operand minus the slot's wSlideSumA word
; is stored as the word at $DF23 + 2 * slot (wPeriodSum).

SoundCommandSlideToward::
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
SoundCommandSlideTowardFromSlot:: ; $4846, entered only by the unused tail at bank $30 $4FF8
    ld a, [wSlotStreamIndex]
    cp $03
    ret z
    ld c, a
    ld b, $00
    ld hl, wChannelFlagBase
    add hl, bc
    set 5, [hl]
    sla c
    ld hl, wSlideSumA
    add hl, bc
    ld a, e
    sub [hl]
    inc hl
    ld e, a
    ld a, d
    sbc a, [hl]
    ld hl, $DF24
    add hl, bc
    ld [hl-], a
    ld [hl], e
    ret
