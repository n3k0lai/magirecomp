; Bank 0 at $2D55. UnpackMapIntoWRAM6AndCopyReverse calls this after
; PrepareMapPlanesAtD000, through the EQU CopyMapRectBothVRAMReverse.
;
; HL is a BG-map address. BC is the prepared rectangle. E is the column
; count and D is the row count. The rectangle is written with rVBK = 0.
; DE and HL are restored, and the same rectangle is written with rVBK = 1.
; $2D69, still INCBIN, copies one rectangle from the end of each source
; row. The stores to rVBK are the 3-byte form. rVBK is the name from
; setup_window.asm.

DEF CopyOneMapRectFromRowEnd EQU $2D69

CopyPreparedMapBothVRAMFromRowEnd::
    push hl
    push de
    xor a
    ld [rVBK], a
    call CopyOneMapRectFromRowEnd
    pop de
    pop hl
    ld a, $01
    ld [rVBK], a
    call CopyOneMapRectFromRowEnd
    ret
