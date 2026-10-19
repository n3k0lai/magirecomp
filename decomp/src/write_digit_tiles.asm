; Write three digit tiles onto a map row.
;
; Called from DrawStartScreenMap while this bank stays mapped. HL is the
; first cell. D is the tile base ($A1 on the start screen). The three
; bytes $041A left at $C92F, $C92E, and $C92D are added to D and stored
; in that order. What those bytes count is still unknown. Nothing else
; is called.

; Digits left by $041A, written high place first.
DEF wDigitHigh EQU $C92F
DEF wDigitMid EQU $C92E
DEF wDigitLow EQU $C92D

WriteDigitTiles::
    ld a, [wDigitHigh]
    add d
    ld [hl+], a
    ld a, [wDigitMid]
    add d
    ld [hl+], a
    ld a, [wDigitLow]
    add d
    ld [hl+], a
    ret
