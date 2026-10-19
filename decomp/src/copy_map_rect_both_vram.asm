; Bank 0 at $2D2C. FillMapPanelTiles and CopyOneMapPanel call this.
;
; HL is a BG-map address. BC is a source in the bank the caller mapped.
; E is the column count and D is the row count. The first rectangle is
; written with rVBK = 0. DE and HL are restored, BC is left where the
; copy stopped, and the next rectangle is written with rVBK = 1.
; $2D40, still INCBIN, copies one rectangle and steps HL by one map row.
; $2D3C is the second copy. The stores to rVBK are the 3-byte form.
; rVBK is the name from setup_window.asm.

DEF CopyMapRect EQU $2D40

CopyMapRectToBothVRAMBanks::
    push hl
    push de
    xor a
    ld [rVBK], a
    call CopyMapRect
    pop de
    pop hl
    ld a, $01
    ld [rVBK], a

CopyMapRectIntoVRAMBank1::
    call CopyMapRect
    ret
