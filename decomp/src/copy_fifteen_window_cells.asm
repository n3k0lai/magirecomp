; Bank 1 at $46E1. CopyWindowSpanRow2ToRow1 calls this with HL at
; columns 5-19 of window-map row 2 and BC at the same columns of row 1.
;
; Each step reads one cell with ld a, [hl+], writes it through [bc],
; and increments BC. That runs fifteen times, then the routine returns.
; A holds the last cell. HL and BC sit one cell past those spans.
;
; CopyFifteenWindowCells in copy_window_span_row2_to_row1.asm is the
; numeric name of this entry.

CopyFifteenCellsHLToBC::
    REPT 15
        ld a, [hl+]
        ld [bc], a
        inc bc
    ENDR
    ret
