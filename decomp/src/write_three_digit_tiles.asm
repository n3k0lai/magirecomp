; Bank 4 at $5484. PaintSRAMWordDigits leaves HL on the first map
; cell and D as the tile base ($86 for that caller). FormatStartDigits
; has already stored hundreds, tens, and ones at $C92F, $C92E, and
; $C92D. This adds D to each byte, high place first, and writes the
; three tiles. HL advances one cell per digit.
;
; wStartDigitHundreds, wStartDigitTens, and wStartDigitOnes are the
; names from format_start_digits.asm. The label is not
; WriteDigitTilesBaseD: that name is still the $5484 constant in
; paint_sram_word_digits.asm.

WriteThreeDigitTiles::
    ld a, [wStartDigitHundreds]
    add d
    ld [hl+], a
    ld a, [wStartDigitTens]
    add d
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add d
    ld [hl+], a
    ret
