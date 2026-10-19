; Bank 3 at $76FA. Called with BC pointing at an 18-by-20 tilemap in this
; bank. StageTilesArmSlot and StageCopiedBlockArmSlot pass BC = $4CB3
; before they store the tile-block destination.
;
; The window is pulled on screen: Y is 0 and X is 7, the left edge.
; VRAM bank 0 is selected. $CCC9 is the rows still to copy ($12, a full
; screen). $CCCA is the columns per row ($14). Each row is written at HL,
; then HL advances by $0C. Twenty columns plus that pad is one 32-byte
; row of the $9C00 map. The row counter is decremented after each row
; and the copy returns when it reaches 0. The jump back to the row loop
; is unconditional, and the ret after it is the next byte.
;
; rWY, rWX, rVBK, and vWindowMap are the names from setup_window.asm.
; WINDOW_X is 7, the same left-edge value. Every store to a high address
; is the 3-byte form.

DEF wMapRowsLeft EQU $CCC9
DEF wMapCols EQU $CCCA
DEF WINDOW_MAP_ROWS EQU $12
DEF WINDOW_MAP_COLS EQU $14
; 32-byte map stride minus the 20 columns written above.
DEF WINDOW_MAP_ROW_PAD EQU $0C

PlaceWindowCopyMap::
    xor a
    ld [rWY], a
    ld a, WINDOW_X
    ld [rWX], a
    xor a
    ld [rVBK], a
    ld hl, vWindowMap
    ld a, WINDOW_MAP_ROWS
    ld [wMapRowsLeft], a
    ld a, WINDOW_MAP_COLS
    ld [wMapCols], a
    ld d, a
    ld e, WINDOW_MAP_ROW_PAD
.row:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec d
    jr nz, .row
    ld a, [wMapRowsLeft]
    dec a
    ret z
    ld [wMapRowsLeft], a
    ld d, $00
    add hl, de
    ld a, [wMapCols]
    ld d, a
    jr .row
    ret
