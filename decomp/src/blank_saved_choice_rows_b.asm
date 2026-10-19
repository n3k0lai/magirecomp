; Bank 3 at $6575. RefreshFrameBlankSavedChoiceRows plants this as
; wCallback for the second RefreshFrame.
;
; VRAM bank 0 is selected with the 3-byte store. Tile $80 is written
; across 17 cells at $9E02, then 18 cells at $9DE1. On the $9C00 window
; map those are row 16 from column 2, then row 15 from column 1.
; wCallback is restored to IdleCallback before the return.
;
; rVBK, vWindowMap, and WINDOW_TILE are the names from setup_window.asm.
; wCallback and IdleCallback are the names from default_state.asm.
; This routine does not write rROMB0 and does not call out.

; Window-map row 16, column 2. Seventeen cells reach column 18.
DEF SAVED_CHOICE_ROW_C EQU vWindowMap + 16 * $20 + 2

; Window-map row 15, column 1.
DEF SAVED_CHOICE_ROW_D EQU vWindowMap + 15 * $20 + 1

DEF SAVED_CHOICE_ROW_C_CELLS EQU 17
DEF SAVED_CHOICE_ROW_D_CELLS EQU 18

BlankSavedChoiceWindowRowsB::
    xor a
    ld [rVBK], a
    ld a, WINDOW_TILE
    ld hl, SAVED_CHOICE_ROW_C
    REPT SAVED_CHOICE_ROW_C_CELLS
        ld [hl+], a
    ENDR
    ld hl, SAVED_CHOICE_ROW_D
    REPT SAVED_CHOICE_ROW_D_CELLS
        ld [hl+], a
    ENDR
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
