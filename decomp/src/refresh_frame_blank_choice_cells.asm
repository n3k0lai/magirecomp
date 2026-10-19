; Bank 3 at $76B1. StepFeChoiceByCce3 calls this when it forces $CCE3 to 3.
;
; wCallbackBank becomes 3 and wCallback becomes $76CE for one RefreshFrame.
; That body, still INCBIN, writes tile $80 at $9E01, $9DC1, and $9DE1, then
; writes $80 at $9DE1 again. IdleCallback is stored at wCallback before the
; return.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. RefreshFrame is already source. This routine does not
; write rROMB0.

; Writes tile $80 at $9E01, $9DC1, and $9DE1, then returns. Still INCBIN.
DEF PaintBlankChoiceCells EQU $76CE

RefreshFrameBlankChoiceCells::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(PaintBlankChoiceCells)
    ld [wCallback], a
    ld a, HIGH(PaintBlankChoiceCells)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
