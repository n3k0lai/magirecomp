; Glide command with a 4-byte operand block at BC: B, C, D, E in order. The
; cursor is saved past it; slot 3 returns. The word BC is added to the slot's
; wSlideSumA word, that word is replaced by the slot's wFoldedPeriod word, and
; ArmChannelGlide is tail-called with A = slot, BC = the sum and DE = operand
; bytes 2-3.

SoundCommandGlide::
    ld l, c
    ld h, b
    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld e, a
    ld a, l
    ld [wSoundStreamCursor], a
    ld a, h
    ld [wSoundStreamCursor + 1], a
    ld a, [wSlotStreamIndex]
    cp $03
    ret nc
    push de
    push bc
    ld e, a
    sla e
    ld d, $00
    ld hl, wSlideSumA
    add hl, de
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    pop hl
    add hl, bc
    ld c, l
    ld b, h
    push bc
    ld hl, wFoldedPeriod
    add hl, de
    ld a, [hl+]
    ld b, [hl]
    ld hl, wSlideSumA
    add hl, de
    ld [hl+], a
    ld [hl], b
    pop bc
    pop de
    ld a, [wSlotStreamIndex]
    jp ArmChannelGlide
