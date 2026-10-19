; Bank 3 at $6B0C. PlantOneMapListEntry and PlantLatchedSlotDigits
; call here with HL on the next byte of the one-entry list at $CCEC.
; FormatStartDigits has already stored the hundreds, tens, and ones
; at $C92F, $C92E, and $C92D.
;
; Each place is passed in A. E is $EE, the glyph for digit 0. $77E7
; adds A to E, writes that byte at [HL], and advances HL. Hundreds is
; stored first, then tens, then ones. This returns with HL on the byte
; after those three glyphs.
;
; wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes are the
; names from format_start_digits.asm. $77E7 is still INCBIN in this
; bank; append_three_digit_places.asm names it Bank3_77E7 and is
; included later, so this file uses the address. This routine does
; not write rROMB0.

; Glyph written when the digit is zero. Digit N is stored as $EE+N.
DEF EE_PLACE_GLYPH_ZERO EQU $EE

AppendEeDigitPlaces::
    ld e, EE_PLACE_GLYPH_ZERO
    ld a, [wStartDigitHundreds]
    call AddAToEStoreAtHL
    ld e, EE_PLACE_GLYPH_ZERO
    ld a, [wStartDigitTens]
    call AddAToEStoreAtHL
    ld e, EE_PLACE_GLYPH_ZERO
    ld a, [wStartDigitOnes]
    call AddAToEStoreAtHL
    ret
