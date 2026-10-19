; Multiply HL by BC (16 x 16 -> 32 bits). DE is preserved. The 32-bit
; product is built in HL (low word) plus wDivDividend/wSeedActionByte (high
; word); the shifted multiplicand's high word lives in wDivDivisor and
; wLowerPointerHigh, and wDivPlace counts the 16 bit steps. On return BC is
; the high word of the product and HL the low word. The RAM names come from
; the divide routine and are reused here as scratch.

MultiplyHlByBc32::
    push de
    ld e, l
    ld d, h
    ld hl, $0000
    xor a
    ld [wDivDividend], a
    ld [wSeedActionByte], a
    ld [wDivDivisor], a
    ld [wLowerPointerHigh], a
    ld a, $10
.bit_loop:
    ld [wDivPlace], a
    rr b
    rr c
    jr nc, .shift
    add hl, de
    push hl
    ld a, [wDivDivisor]
    ld l, a
    ld a, [wDivDividend]
    adc a, l
    ld [wDivDividend], a
    ld a, [wLowerPointerHigh]
    ld l, a
    ld a, [wSeedActionByte]
    adc a, l
    ld [wSeedActionByte], a
    pop hl
    ld a, [wDivDividend]
    adc a, $00
    ld [wDivDividend], a
    ld a, [wSeedActionByte]
    adc a, $00
    ld [wSeedActionByte], a
.shift:
    sla e
    rl d
    ld a, [wDivDivisor]
    rla
    ld [wDivDivisor], a
    ld a, [wLowerPointerHigh]
    rla
    ld [wLowerPointerHigh], a
    ld a, [wDivPlace]
    dec a
    jr nz, .bit_loop
    ld a, [wDivDividend]
    ld c, a
    ld a, [wSeedActionByte]
    ld b, a
    pop de
    ret
