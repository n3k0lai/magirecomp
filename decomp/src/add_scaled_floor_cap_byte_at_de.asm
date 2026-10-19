; AddScaledFloorCapByteAtDe. Bank 0 at $3892.
;
; HL is a base and DE is an offset. B is a scale. The byte at HL+DE
; is multiplied by B and shifted right by 5 (MulLByBShift5). A zero
; product is replaced with $01, then added to the original byte.
; The unsigned sum is capped at C and written back. A is the stored
; value. What the byte counts is still unknown.

AddScaledFloorCapByteAtDe::
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
    add [hl]
    cp c
    jr c, .store

    ld a, c

.store:
    ld [hl], a
    ret
