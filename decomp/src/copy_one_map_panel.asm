; Bank 0 at $304E. LoadMapPanels calls this eight times.
;
; HL is a BG-map address. BC is a source in the bank the caller mapped.
; Each panel source is $28 bytes: four columns by five rows of tile IDs,
; then the same rectangle of attributes. E is the column count and D is
; the row count. $2D2C writes the first half into VRAM bank 0 and the
; second half into VRAM bank 1, stepping HL by one map row ($20) after
; each row.
;
; $2D2C is still INCBIN. Call_2D2C is the name from fill_map_panel_tiles.asm.

CopyOneMapPanel::
    ld e, $04
    ld d, $05
    call Call_2D2C
    ret
