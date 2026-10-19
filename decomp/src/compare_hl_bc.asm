; Unsigned 16-bit compare of HL with BC.
; Carry is set when HL is below BC.
; When the high bytes differ and H is above B, A is 1 and carry is clear.
; When the high bytes match, the low-byte compare sets the flags.

CompareHlWithBc:
    ld a, h
    cp b
    ret c

    jr z, .lowByte

    xor a
    inc a
    ret

.lowByte
    ld a, l
    cp c
    ret
