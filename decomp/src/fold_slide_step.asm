; FoldSlideStep ($54B6). StepChannelSlides calls this with bank $30
; still mapped. BC is a byte offset into the parallel slide words.
; Bit 3 uses (channel) * 2. Bit 4 uses (channel + 3) * 2.
;
; The word at $DF34 is added into the accumulator at $DF4C. The word at
; $DF40 is the fold limit (vibrato reads only its low byte as a reload).
; The sum is returned in DE. $4198 compares HL with DE and sets carry
; when HL is below DE.
;
; A limit whose high bit is clear is an upper bound. The sum is kept
; while it is at or below that limit. One step past it stores
; sum - limit.
;
; A limit whose high bit is set is a lower bound. $4198 then sees
; limit - 1, so a sum still at or above the limit is kept. A sum below
; it stores sum - limit, which adds the magnitude of a negative limit.

DEF wSlideAccum EQU $DF4C

FoldSlideStep:
    ld hl, wSlideStep
    add hl, bc
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld hl, wSlideAccum
    add hl, bc
    ld a, [hl]
    add e
    ld [hl+], a
    ld e, a
    ld a, [hl]
    adc d
    ld [hl], a
    ld d, a
    ld hl, wSlideReload
    add hl, bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    bit 7, h
    jr nz, .lower_bound

    call $4198
    ret nc

.fold:
    ld a, e
    sub l
    ld e, a
    ld a, d
    sbc h
    ld hl, wSlideAccum + 1
    add hl, bc
    ld [hl-], a
    ld [hl], e
    ret

.lower_bound:
    dec hl
    call $4198
    ret c

    inc hl
    jr .fold
