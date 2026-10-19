; Bank 3 at $6ED7. SyncSramListSlotDigits calls here with HL on the
; next byte of the one-entry list at $CCEC. FormatStartDigits has
; already stored the hundreds, tens, and ones at $C92F, $C92E, and
; $C92D.
;
; Each place is passed in A. E is $DE, the glyph for digit 0. $77E7
; adds A to E, writes that byte at [HL], and advances HL. Hundreds is
; stored first, then tens, then ones. This returns with HL on the byte
; after those three glyphs.
;
; wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes are the
; names from format_start_digits.asm. $77E7 is still INCBIN in this
; bank. This routine does not write rROMB0.

; Still INCBIN. Adds A to E, stores the sum at [HL], and increments HL.
DEF Bank3_77E7 EQU $77E7

; Glyph written when the digit is zero. Digit N is stored as $DE+N.
DEF PLACE_GLYPH_ZERO EQU $DE

AppendThreeDigitPlaces::
    ld e, PLACE_GLYPH_ZERO
    ld a, [wStartDigitHundreds]
    call Bank3_77E7
    ld e, PLACE_GLYPH_ZERO
    ld a, [wStartDigitTens]
    call Bank3_77E7
    ld e, PLACE_GLYPH_ZERO
    ld a, [wStartDigitOnes]
    call Bank3_77E7
    ret
