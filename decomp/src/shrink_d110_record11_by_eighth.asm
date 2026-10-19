; ShrinkD110Record11ByEighth. Bank 2 at $5BD0.
;
; Record+11 of the $D110 record is reduced through
; SubScaledFloorByteAtDe. B = $04 is the scale, so the subtracted
; amount is the byte times 4, shifted right by 5 (one eighth), and a
; zero product becomes $01. The result is floored at $01, so the byte
; never lands on zero. A returns the stored byte.
;
; D110_RECORD is the name from halve_d110_record_word7_min1.asm.
; RECORD_PLUS_11_BYTE is the name from write_record11_two_digits.asm.
; No call or jump in the notes names this entry.

ShrinkD110Record11ByEighth::
    ld hl, D110_RECORD
    ld de, RECORD_PLUS_11_BYTE
    ld b, $04
    call SubScaledFloorByteAtDe
    ret
