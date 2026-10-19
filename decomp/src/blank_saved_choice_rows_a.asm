; Bank 3 at $653A. RefreshFrameBlankSavedChoiceRows plants this as
; wCallback for one RefreshFrame.
;
; VRAM bank 0 is selected with the 3-byte store. Tile $80 is written
; across 18 cells at $9DA1, then 18 cells at $9DC1. On the $9C00 window
; map those are row 13 and row 14, columns 1 through 18. wCallback is
; restored to IdleCallback before the return.
;
; rVBK, vWindowMap, and WINDOW_TILE are the names from setup_window.asm.
; wCallback and IdleCallback are the names from default_state.asm.
; This routine does not write rROMB0 and does not call out.

; Window-map row 13, column 1.
DEF SAVED_CHOICE_ROW_A EQU vWindowMap + 13 * $20 + 1

; Window-map row 14, column 1.
DEF SAVED_CHOICE_ROW_B EQU vWindowMap + 14 * $20 + 1

DEF SAVED_CHOICE_ROW_CELLS EQU 18

BlankSavedChoiceWindowRows::
    xor a
    ld [rVBK], a
    ld a, WINDOW_TILE
    ld hl, SAVED_CHOICE_ROW_A
    REPT SAVED_CHOICE_ROW_CELLS
        ld [hl+], a
    ENDR
    ld hl, SAVED_CHOICE_ROW_B
    REPT SAVED_CHOICE_ROW_CELLS
        ld [hl+], a
    ENDR
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
