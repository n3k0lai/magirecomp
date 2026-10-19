; Unsigned divide of HL by BC.
; The quotient returns in HL and the remainder in BC.
; Equal operands return quotient 1 and remainder 0.
; A zero divisor returns quotient 0 and remainder 0.
;
; Otherwise $DFF9 holds the dividend, $DFFB the divisor, and $DFFD a one-bit
; place value. Those two words shift left together while HL is still at least
; BC, at most 16 times. The loop back reloads C from A, and A is the shift
; count, so later compares do not use the stored divisor. The words then shift
; back right. Whenever the stored dividend is at least the stored divisor, the
; divisor is subtracted and the current place is added into DE. HL is that sum
; and BC is the leftover dividend. If all 16 left shifts run, HL is 0 and BC
; is the original dividend.

DEF wDivDividend EQU $DFF9
DEF wDivDivisor EQU $DFFB
DEF wDivPlace EQU $DFFD

DivideHlByBcWithRemainder:
    call CompareHlWithBc
    jr z, .equal

    ld a, b
    or c
    jr z, .divisorZero

    ld a, l
    ld [wDivDividend], a
    ld a, h
    ld [wDivDividend + 1], a
    ld a, c
    ld [wDivDivisor], a
    ld a, b
    ld [wDivDivisor + 1], a
    ld e, $0F
    ld a, $01
    ld [wDivPlace], a
    xor a
    ld [wDivPlace + 1], a

.align
    ld a, [wDivDividend]
    ld l, a
    ld a, [wDivDividend + 1]
    ld h, a
    ld a, [wDivDivisor]
.reloadDivisorLow
    ld c, a
    ld a, [wDivDivisor + 1]
    ld b, a
    call CompareHlWithBc
    jr c, .shiftRight

    ld a, [wDivDivisor]
    sla a
    ld [wDivDivisor], a
    ld a, [wDivDivisor + 1]
    rla
    ld [wDivDivisor + 1], a
    ld a, [wDivPlace]
    sla a
    ld [wDivPlace], a
    ld a, [wDivPlace + 1]
    rla
    ld [wDivPlace + 1], a
    ld a, e
    dec a
    ld e, a
    bit 7, a
    jr z, .reloadDivisorLow

    ld hl, $0000
    ld a, [wDivDividend]
    ld c, a
    ld a, [wDivDividend + 1]
    ld b, a
    ret

.equal
    ld hl, $0001
    ld bc, $0000
    ret

.divisorZero
    ld hl, $0000
    ld bc, $0000
    ret

.shiftRight
    xor a
    ld e, a
    ld d, a

.placeStep
    ld a, [wDivPlace + 1]
    srl a
    ld [wDivPlace + 1], a
    ld b, a
    ld a, [wDivPlace]
    rra
    ld [wDivPlace], a
    or b
    jr z, .finish

    ld a, [wDivDivisor + 1]
    srl a
    ld [wDivDivisor + 1], a
    ld a, [wDivDivisor]
    rra
    ld [wDivDivisor], a
    ld a, [wDivDividend]
    ld l, a
    ld a, [wDivDividend + 1]
    ld h, a
    ld a, [wDivDivisor]
    ld c, a
    ld a, [wDivDivisor + 1]
    ld b, a
    call CompareHlWithBc
    jr c, .placeStep

    ld a, c
    cpl
    add a, $01
    ld c, a
    ld a, b
    cpl
    adc a, $00
    ld b, a
    add hl, bc
    ld a, l
    ld [wDivDividend], a
    ld a, h
    ld [wDivDividend + 1], a
    ld a, [wDivPlace]
    ld l, a
    ld a, [wDivPlace + 1]
    ld h, a
    add hl, de
    ld e, l
    ld d, h
    jr .placeStep

.finish
    ld l, e
    ld h, d
    ld a, [wDivDividend]
    ld c, a
    ld a, [wDivDividend + 1]
    ld b, a
    ret
