; Bank 4 at $551A. Callers pass A as the width of the value at HL and DE
; as the first map cell. The known caller uses A = 1 and DE = $9DB0
; while SRAM is already enabled. This routine does not touch rRAMG.
;
; A nonzero selects a little-endian word. A zero selects one byte, with
; the high byte forced to 0. Either value of 0 stores $FA at $C92F,
; $C92E, and $C92D. $FA plus tile base $86 is $180, so the three cells
; become tile $80. A nonzero value goes to FormatStartDigits.
;
; rVBK is cleared before the read, so later map stores hit bank 0.
; The saved DE is the destination. D is then $86 and $5484 adds it to
; the three digit bytes, high place first. $5484 is still INCBIN.
; rVBK is the name from setup_window.asm. The digit bytes and
; FormatStartDigits are the names from format_start_digits.asm.

; $FA + $86 lands on blank tile $80.
DEF DIGIT_BLANK_FOR_86 EQU $FA

; Tile added to the three bytes FormatStartDigits leaves behind.
DEF TILE_DIGIT_BASE_86 EQU $86

; Still INCBIN. Writes [$C92F], [$C92E], and [$C92D] plus D at HL.
DEF WriteDigitTilesBaseD EQU $5484

PaintSRAMWordDigits::
    push de
    and a
    jr z, .readByte

    xor a
    ld [rVBK], a
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, h
    or l
    jr z, .blankDigits

    ld d, h
    ld e, l
    jr .format

.readByte:
    xor a
    ld [rVBK], a
    ld e, [hl]
    cp e
    ld d, $00
    jr nz, .format

.blankDigits:
    ld a, DIGIT_BLANK_FOR_86
    ld [wStartDigitHundreds], a
    ld [wStartDigitTens], a
    ld [wStartDigitOnes], a
    jr .writeTiles

.format:
    call FormatStartDigits

.writeTiles:
    pop hl
    ld d, TILE_DIGIT_BASE_86
    call WriteDigitTilesBaseD
    ret
