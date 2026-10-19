; StepChannelSlides ($53DE). UpdateSound calls this with bank $30
; still mapped, after the stream walk and before the phase walk.
;
; C counts 3, 2, 1 while HL walks $DF0B, $DF0A, $DF09 (channels 2, 1, 0).
; The word index for a channel is (C - 1) * 2. Bit 5 of the flag byte is
; set whenever a slide changes a summand; UpdateSound later sees that bit
; and rewrites the period. The first set bit below wins, except bit 3,
; which still falls through into the bit 4 test.
;
; Bit 2 counts down the word at $DF3A + index. While it is nonzero, the
; word at $DF34 is added into $DF15. When the count reaches zero, $DF46
; is copied into $DF15 and bit 2 is cleared.
; Bit 0 adds $DF34 into $DF46, then adds that sum into $DF1D. The byte at
; $DF3A is the remaining half-period: at zero it is reloaded from the low
; byte of $DF40 and the $DF34 step is negated.
; Bit 3 calls $54B6 and adds the returned word into $DF1D.
; Bit 4 calls $54B6 with word index (C + 3) * 2, then adds the returned
; word into $DF1D at index C * 2.

DEF wChannelSlideFlags EQU $DF09
DEF wSlideSumA EQU $DF15
DEF wSlideSumB EQU $DF1D
DEF wSlideStep EQU $DF34
DEF wSlideCount EQU $DF3A
DEF wSlideReload EQU $DF40
DEF wSlideLatch EQU $DF46

StepChannelSlides:
    ld bc, $0003
    ld hl, wChannelSlideFlags + 2

.next_channel:
    bit 2, [hl]
    jr nz, .glide_to_latch

    bit 0, [hl]
    jr nz, .vibrato

    bit 3, [hl]
    jp nz, .ramp_sum

.check_second_ramp:
    bit 4, [hl]
    jp nz, .ramp_shifted

.next:
    dec hl
    dec c
    jr nz, .next_channel

    ret

.glide_to_latch:
    push bc
    push hl
    dec c
    sla c
    set 5, [hl]
    ld hl, wSlideCount + 1
    add hl, bc
    ld a, [hl-]
    or [hl]
    jr nz, .glide_step

    ld hl, wSlideLatch
    add hl, bc
    ld a, [hl+]
    ld d, [hl]
    ld hl, wSlideSumA
    add hl, bc
    ld [hl+], a
    ld [hl], d
    pop hl
    pop bc
    res 2, [hl]
    jr .next

.glide_step:
    dec [hl]
    ld a, [hl+]
    cp $ff
    jr nz, .glide_add

    dec [hl]

.glide_add:
    ld hl, wSlideStep
    add hl, bc
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld hl, wSlideSumA
    add hl, bc
    ld a, [hl]
    add e
    ld [hl+], a
    ld a, [hl]
    adc d
    ld [hl], a
    pop hl
    pop bc
    jr .next

.vibrato:
    push bc
    push hl
    set 5, [hl]
    dec c
    sla c
    ld hl, wSlideStep
    add hl, bc
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld hl, wSlideLatch
    add hl, bc
    ld a, [hl]
    add e
    ld [hl+], a
    ld a, [hl]
    adc d
    ld [hl-], a
    ld d, a
    ld a, [hl]
    ld hl, wSlideSumB
    add hl, bc
    add [hl]
    ld [hl+], a
    ld a, [hl]
    adc d
    ld [hl], a
    ld hl, wSlideCount
    add hl, bc
    dec [hl]
    jr nz, .vibrato_done

    ld e, l
    ld d, h
    ld hl, wSlideReload
    add hl, bc
    ld a, [hl]
    ld [de], a
    ld hl, wSlideStep
    add hl, bc
    ld a, [hl]
    cpl
    add $01
    ld [hl+], a
    ld a, [hl]
    cpl
    adc $00
    ld [hl], a

.vibrato_done:
    pop hl
    pop bc
    jp .next

.ramp_sum:
    push bc
    push hl
    dec c
    sla c
    call $54b6
    ld hl, wSlideSumB
    add hl, bc
    ld a, [hl]
    add e
    ld [hl+], a
    ld a, [hl]
    adc d
    ld [hl], a
    pop hl
    pop bc
    set 5, [hl]
    jp .check_second_ramp

.ramp_shifted:
    push bc
    push hl
    ld a, c
    add $03
    sla a
    ld c, a
    call $54b6
    ld a, c
    sub $06
    ld c, a
    ld hl, wSlideSumB
    add hl, bc
    ld a, [hl]
    add e
    ld [hl+], a
    ld a, [hl]
    adc d
    ld [hl], a
    pop hl
    pop bc
    set 5, [hl]
    jp .next
