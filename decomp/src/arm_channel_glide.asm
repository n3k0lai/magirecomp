; ArmChannelGlide ($52D6). SoundCommand02 calls this for stream indexes
; below 3, with bank $30 still mapped. A is that index ORed with the
; command's fifth operand. BC is the command word and DE is its duration.
;
; `sla a` drops bit 7 into carry and leaves bits 0-6 doubled in A. That
; doubled value indexes the slide words. The flag byte is chosen from the
; shifted low bits: bit 1 selects $DF0A, otherwise bit 2 selects $DF0B,
; otherwise $DF09. With a zero fifth operand those are channels 1, 2, and 0.
;
; Bits 0, 2, 3, and 4 of that flag are cleared. DE is stored as the glide
; count at $DF3A. Carry from bit 7 picks how BC meets the sum at $DF15:
; carry clear stores BC at the latch $DF46 and replaces BC with
; BC - sum; carry set stores sum + BC at the latch and keeps BC.
; $40AA then divides that signed distance by the count. The quotient is
; stored as the step at $DF34, and bit 2 is set so StepChannelSlides
; glides toward the latch.

ArmChannelGlide:
    sla a
    push af

.pick_flag:
    bit 1, a
    jr z, .not_low

    ld hl, $DF0A
    jr .clear_mode

.not_low:
    bit 2, a
    jr z, .flag_base

    ld hl, $DF0B

.flag_high:
    jr .clear_mode

.flag_base:
    ld hl, $DF09

.clear_mode:
    res 0, [hl]
    res 2, [hl]
    res 3, [hl]
    res 4, [hl]
    ld hl, $DF3A
    add a, l
    ld l, a
    ld a, h
    adc a, $00
    ld h, a
    ld a, e
    ld [hl+], a
    ld [hl], d
    pop af
    ld d, $00
    ld e, a
    jr nc, .target_word

    push bc
    ld hl, $DF15
    add hl, de
    ld a, c
    add a, [hl]
    ld c, a
    ld a, b
    inc hl
    adc a, [hl]
    ld hl, $DF47
    add hl, de
    ld [hl-], a
    ld [hl], c
    pop bc
    jr .signed_step

.target_word:
    ld hl, $DF46
    add hl, de
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, $DF15
    add hl, de
    ld a, c
    sub a, [hl]
    ld c, a
    ld a, b
    inc hl
    sbc a, [hl]
    ld b, a

.signed_step:
    ld hl, $DF3A
    add hl, de
    bit 7, b
    jr nz, .negate_distance

    ld a, [hl+]
    push bc
    ld b, [hl]
    ld c, a
    pop hl
    call $40AA
    jr .store_step

.negate_distance:
    ld a, c
    cpl
    add a, $01
    ld c, a
    ld a, b
    cpl
    adc a, $00
    ld b, a
    ld a, [hl+]
    push bc
    ld b, [hl]
    ld c, a
    pop hl
    call $40AA
    ld a, l
    cpl
    add a, $01
    ld l, a
    ld a, h
    cpl
    adc a, $00
    ld h, a

.store_step:
    ld a, l
    ld b, h
    ld hl, $DF34
    add hl, de
    ld [hl+], a
    ld [hl], b
    srl e
    ld hl, $DF09
    add hl, de
    set 2, [hl]
    ret
