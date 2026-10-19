; Bank 1 at $470F. Opcode9ABody stores this as wCallback with bank 1.
;
; VRAM bank 0 is selected. $46CF writes tile $80, the blank window tile
; from SetupWindow, to fifteen cells starting at $9C25 and again at
; $9C65. On the 32-wide $9C00 window map those are columns 5-19 of rows
; 1 and 3. wCallback becomes IdleCallback. That address is in ROM0, so
; the bank byte is left alone.
;
; The rVBK store is the 3-byte form. rVBK, vWindowMap, and WINDOW_TILE
; are the names from setup_window.asm. wCallback and IdleCallback are
; the names from default_state.asm. $46CF is still INCBIN.

; Columns 5-19 of window-map rows 1 and 3.
DEF vWindowSpanRow1 EQU vWindowMap + $25
DEF vWindowSpanRow3 EQU vWindowMap + $65

BlankTwoWindowSpans::
    xor a
    ld [rVBK], a
    ld hl, vWindowSpanRow1
    call WriteFifteenWindowTiles
    ld hl, vWindowSpanRow3
    call WriteFifteenWindowTiles
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
