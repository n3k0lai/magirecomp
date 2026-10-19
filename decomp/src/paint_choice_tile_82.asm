; Bank 3 at $7696. RefreshFrameChoiceCell plants this as wCallback
; for one RefreshFrame, with wCallbackBank set to 3.
;
; [$CCCB] selects the cell that becomes tile $82. Zero writes $9DC1,
; one writes $9DE1, and any other value writes $9E01. $CCCB holds the
; choice copied from $CCA7. This routine does not write rROMB0 and
; does not call out.
;
; wCallback is the name from default_state.asm.

PaintChoiceTile82::
    ld a, [$CCCB]
    cp $00
    jr z, .cell9DC1
    cp $01
    jr z, .cell9DE1
    ld hl, $9E01
    jr .write
.cell9DC1
    ld hl, $9DC1
    jr .write
.cell9DE1
    ld hl, $9DE1
.write
    ld [hl], $82
    ret
