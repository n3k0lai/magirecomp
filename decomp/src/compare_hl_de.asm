; Unsigned 16-bit compare of HL with DE.
; Carry is set when HL is below DE.
; When the high bytes differ and H is above D, A is 1 and carry is clear.
; When the high bytes match, the low-byte compare sets the flags.

CompareHlWithDe:
    ld a, h
    cp d
    ret c

    jr z, .lowByte

    xor a
    inc a
    ret

.lowByte
    ld a, l
    cp e
    ret
