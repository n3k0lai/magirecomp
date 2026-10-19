; Bank 4 at $618B. CopiedBlockWindowChoice plants this address at
; wCallback, in this bank, after BlankSlotDigitRows, and calls
; RefreshFrame. This bank stays mapped. The routine does not write
; rROMB0.
;
; rVBK is cleared with the 3-byte form, so the writes land in VRAM
; bank 0. Tile $80 fills four window-map strips on the $9C00 map
; (32 cells a row): row 13 columns 1-14, row 14 columns 1-3, row 15
; columns 1-3, and row 16 columns 2-8. wCallback then becomes
; IdleCallback, low byte first. wCallbackBank is left alone.
;
; wCallback and IdleCallback are the names from default_state.asm.
; rVBK is the name from setup_window.asm.

DEF CHOICE_STRIP_BLANK EQU $80
DEF CHOICE_STRIP_ROW13 EQU $9DA1
DEF CHOICE_STRIP_ROW13_CELLS EQU 14
DEF CHOICE_STRIP_ROW14 EQU $9DC1
DEF CHOICE_STRIP_EDGE_CELLS EQU 3
DEF CHOICE_STRIP_ROW15 EQU $9DE1
DEF CHOICE_STRIP_ROW16 EQU $9E02
DEF CHOICE_STRIP_ROW16_CELLS EQU 7

BlankChoiceWindowStrips::
    xor a
    ld [rVBK], a
    ld a, CHOICE_STRIP_BLANK
    ld hl, CHOICE_STRIP_ROW13
    rept CHOICE_STRIP_ROW13_CELLS
        ld [hl+], a
    endr
    ld hl, CHOICE_STRIP_ROW14
    rept CHOICE_STRIP_EDGE_CELLS
        ld [hl+], a
    endr
    ld hl, CHOICE_STRIP_ROW15
    rept CHOICE_STRIP_EDGE_CELLS
        ld [hl+], a
    endr
    ld hl, CHOICE_STRIP_ROW16
    rept CHOICE_STRIP_ROW16_CELLS
        ld [hl+], a
    endr
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
