; Bank 1 at $4745. RetargetWindowRow4 stores this as wCallback. The
; bank byte is left alone.
;
; VRAM bank 0 is selected. WriteFifteenWindowTiles writes WINDOW_TILE,
; the blank window tile from SetupWindow, to fifteen cells starting at
; $9C85. On the 32-wide $9C00 window map that is columns 5-19 of row 4.
; wCallback becomes IdleCallback. That address is in ROM0, so the bank
; byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK, vWindowMap, and WINDOW_TILE
; are the names from setup_window.asm. wCallback and IdleCallback are
; the names from default_state.asm. WriteFifteenWindowTiles is the name
; from write_fifteen_window_tiles.asm.

; Columns 5-19 of window-map row 4.
DEF vWindowSpanRow4 EQU vWindowMap + $85

BlankWindowSpanRow4::
    xor a
    ld [rVBK], a
    ld hl, vWindowSpanRow4
    call WriteFifteenWindowTiles
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
