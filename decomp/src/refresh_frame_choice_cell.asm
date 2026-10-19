; Bank 3 at $7679. StepFeChoiceByCce3 calls this when ScanArmedSlotMarks
; returns nonzero.
;
; wCallbackBank becomes 3 and wCallback becomes $7696 for one RefreshFrame.
; That body, still INCBIN, reads $CCCB. Zero writes tile $82 at $9DC1, one
; writes it at $9DE1, and any other value writes it at $9E01. IdleCallback
; is stored at wCallback again before the return.
;
; wCallback, wCallbackBank, and IdleCallback are the names from
; default_state.asm. RefreshFrame is already source. This routine does not
; write rROMB0. $CCCB holds the choice copied from $CCA7.

; Writes tile $82 at $9DC1, $9DE1, or $9E01 from $CCCB, then returns.
; Still INCBIN.
DEF PaintChoiceCell EQU $7696

RefreshFrameChoiceCell::
    ld a, $03
    ld [wCallbackBank], a
    ld a, LOW(PaintChoiceCell)
    ld [wCallback], a
    ld a, HIGH(PaintChoiceCell)
    ld [wCallback + 1], a
    call RefreshFrame
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
