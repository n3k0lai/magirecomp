; Bank 1 at $46CF. BlankTwoWindowSpans calls this twice, once for each
; window-map span. HL is the first cell. WINDOW_TILE ($80) is written
; through [hl+] fifteen times, then the routine returns. A stays $80
; and HL sits one cell past the span.
;
; WINDOW_TILE is the name from setup_window.asm.

WriteFifteenWindowTiles::
    ld a, WINDOW_TILE
    REPT 15
        ld [hl+], a
    ENDR
    ret
