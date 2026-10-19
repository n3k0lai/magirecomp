; Bank 7 at $47D1. Complements BC little-endian words at HL, then returns.
; Each pass inverts both bytes and advances HL by two. BC is the word
; count and is left at zero. DE is not read, so a caller may load it
; without this routine using it.
;
; ComplementPanelSlotPalettes calls this with BC = 3 at color 1 of a
; background palette, and with BC = 1 at color 0. That caller still
; names this address with DEF ComplementColorWordsAtHl.

ComplementColorWords::
    ld a, [hl]
    cpl
    ld [hli], a
    ld a, [hl]
    cpl
    ld [hli], a
    dec bc
    ld a, c
    or b
    jr nz, ComplementColorWords
    ret
