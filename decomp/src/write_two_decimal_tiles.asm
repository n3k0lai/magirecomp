; Write the tens and ones tiles for the value in A.
;
; The caller leaves HL on the first map cell. A is the low byte of a
; word with a zero high byte. FormatStartDigits in bank 0 stores the
; hundreds, tens, and ones at $C92F, $C92E, and $C92D. This writes only
; the tens and the ones, each plus $A1 (TILE_DIGIT_BASE in
; draw_start_screen_map.asm). Hundreds is left unused. HL advances two
; cells.
;
; wStartDigitTens and wStartDigitOnes are the names from
; format_start_digits.asm. FormatStartDigits is already source.

WriteTwoDecimalTiles::
    ld e, a
    ld d, $00
    call FormatStartDigits
    ld a, [wStartDigitTens]
    add $A1
    ld [hl+], a
    ld a, [wStartDigitOnes]
    add $A1
    ld [hl+], a
    ret
