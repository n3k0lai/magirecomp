; Bank 1 at $472A. RetargetWindowBlank stores this as wCallback. The
; bank byte is left alone.
;
; VRAM bank 0 is selected. WriteFifteenWindowTiles writes WINDOW_TILE,
; the blank window tile from SetupWindow, to fifteen cells starting at
; $9C05 and again at $9C45. On the 32-wide $9C00 window map those are
; columns 5-19 of rows 0 and 2. wCallback becomes IdleCallback. That
; address is in ROM0, so the bank byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK, vWindowMap, and WINDOW_TILE
; are the names from setup_window.asm. wCallback and IdleCallback are
; the names from default_state.asm.

; Columns 5-19 of window-map rows 0 and 2.
DEF vWindowSpanRow0 EQU vWindowMap + $05
DEF vWindowSpanRow2 EQU vWindowMap + $45

BlankWindowSpanRows02::
    xor a
    ld [rVBK], a
    ld hl, vWindowSpanRow0
    call WriteFifteenWindowTiles
    ld hl, vWindowSpanRow2
    call WriteFifteenWindowTiles
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
