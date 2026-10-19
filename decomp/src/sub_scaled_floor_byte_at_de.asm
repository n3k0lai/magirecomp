; SubScaledFloorByteAtDe. Bank 0 at $38A6.
;
; HL is a base and DE is an offset. B is a scale. The byte at HL+DE
; is multiplied by B and shifted right by 5 (MulLByBShift5). A zero
; product is replaced with $01. That amount is subtracted from the
; original byte. A zero result and an underflow are both stored as
; $01, so the byte never lands on zero. A is the stored value. What
; the byte counts is still unknown.

SubScaledFloorByteAtDe::
    add hl, de
    push hl
    ld a, [hl]
    ld l, b
    ld b, a
    call MulLByBShift5
    jr nz, .haveScale

    ld a, $01

.haveScale:
    pop hl
    cpl
    inc a
    add [hl]
    jr z, .floor

    jr c, .store

.floor:
    ld a, $01

.store:
    ld [hl], a
    ret
