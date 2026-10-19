; Bank 3 at $76CE. RefreshFrameBlankChoiceCells plants this as wCallback
; for one RefreshFrame, with wCallbackBank set to 3.
;
; Tile $80 is written at $9E01, then $9DC1, then $9DE1. The last
; store is issued twice, so $9DE1 receives $80 again. This routine
; does not write rROMB0 and does not call out.
;
; wCallback is the name from default_state.asm. The caller still
; names this address PaintBlankChoiceCells.

PaintBlankChoiceCellsBody::
    ld hl, $9E01
    ld [hl], $80
    ld hl, $9DC1
    ld [hl], $80
    ld hl, $9DE1
    ld [hl], $80
    ld [hl], $80
    ret
