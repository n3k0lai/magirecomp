; GrowD110Record11ByEighth. Bank 2 at $5BC2.
;
; Record+11 of the $D110 record is grown through
; AddScaledFloorCapByteAtDe. B = $04 is the scale, so the added amount
; is the byte times 4, shifted right by 5 (one eighth), and a zero
; product becomes $01. The sum is capped at C = $63, the same cap
; SampleRecord11Contribution uses. A returns the stored byte.
;
; D110_RECORD is the name from halve_d110_record_word7_min1.asm.
; RECORD_PLUS_11_BYTE is the name from write_record11_two_digits.asm.
; No call or jump in the notes names this entry.

GrowD110Record11ByEighth::
    ld hl, D110_RECORD
    ld de, RECORD_PLUS_11_BYTE
    ld b, $04
    ld c, $63
    call AddScaledFloorCapByteAtDe
    ret
