; Sound command with a 4-byte operand block at BC (slot 3 skips it). Sets
; bit 5 of wChannelFlagBase+0, then the first operand byte picks a mode:
;   $00     period from StepDf03ModuloB over [lo, hi), stored at wTagPeriodBaseHigh-1
;   $01-$7F period relative to the slot's current wTagPeriodBaseHigh byte
;   $80     slide from a negated step folded by FoldDf03StepIntoHl into wSlideSumA
;   $81-$FF slide relative to the slot's wSlideSumA word, result in wPeriodSum
; The stream cursor (wSoundStreamCursor) always advances by 4 at the end.
; The exact meaning of each mode is still unknown.

SoundCommandRandomPeriod::
    ld a, [wSlotStreamIndex]
    cp $03
    jp z, .advance
    ld e, a
    ld d, $00
    ld hl, wChannelFlagBase
    set 5, [hl]
    sla e
    ld l, c
    ld h, b
    ld a, [hl+]
    bit 7, a
    jr nz, .slide
    and a
    jr nz, .relative_period
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    sub c
    ld b, a
    call StepDf03ModuloB
    add a, c
    ld c, [hl]
    ld hl, wTagPeriodBaseHigh
    add hl, de
    ld [hl-], a
    ld [hl], c
    jp .advance

.relative_period:
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    push hl
    ld hl, wTagPeriodBaseHigh
    add hl, de
    ld a, [hl]
    add a, c
    bit 7, a
    jr z, .no_floor
    xor a
.no_floor:
    ld c, a
    ld a, b
    add a, [hl]
    sub c
    ld b, a
    call StepDf03ModuloB
    sub [hl]
    pop hl
    ld c, [hl]
    ld hl, $DF24
    add hl, de
    ld [hl-], a
    ld [hl], c
    jr .advance

.slide:
    and $7F
    jr nz, .relative_slide
    ld a, [hl+]
    cpl
    inc a
    ld b, a
    ld c, $00
    ld a, [hl+]
    ld l, [hl]
    ld h, a
    add hl, bc
    call FoldDf03StepIntoHl
    ld a, b
    cpl
    inc a
    ld b, a
    add hl, bc
    ld a, l
    ld b, h
    ld hl, wSlideSumA
    add hl, de
    ld [hl+], a
    ld [hl], b
    jr .advance

.relative_slide:
    ld a, [hl+]
    ld b, a
    ld c, $00
    push hl
    ld hl, wSlideSumA
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    ld c, l
    ld b, h
    pop hl
    push bc
    ld a, [hl+]
    ld c, [hl]
    ld b, a
    ld hl, wSlideSumA
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    add hl, bc
    pop de
    ld c, e
    ld b, d
    ld a, e
    cpl
    add a, $01
    ld e, a
    ld a, d
    cpl
    adc a, $00
    ld d, a
    add hl, de
    call FoldDf03StepIntoHl
    add hl, bc
    ld c, l
    ld b, h
    ld a, [wSlotStreamIndex]
    sla a
    ld e, a
    ld d, $00
    ld hl, wSlideSumA
    add hl, de
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, l
    cpl
    add a, $01
    ld l, a
    ld a, h
    cpl
    adc a, $00
    ld h, a
    add hl, bc
    ld a, l
    ld b, h
    ld hl, wPeriodSum
    add hl, de
    ld [hl+], a
    ld [hl], b

.advance:
    ld hl, wSoundStreamCursor
    ld a, [hl]
    add a, $04
    ld [hl+], a
    ld a, [hl]
    adc a, $00
    ld [hl], a
    ret
