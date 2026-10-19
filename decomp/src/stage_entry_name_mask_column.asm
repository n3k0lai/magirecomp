; Bank 6 at $559B. PaintIndexedEntryNames jumps here when the mask byte
; at the index after the first name pass is $02. Stages the right-hand
; map cell $9C24 with the second-row tile window ($8900, tiles $90 $8F
; $9A) and the same SRAM name lookup as the left column. The strip then
; runs from the pass loop at $5636, which is still INCBIN.
;
; stage_entry_name_strip, ENTRY_ROW1_TILES, ENTRY_ROW1_LO, ENTRY_ROW1_HI,
; and ENTRY_MAP_RIGHT are defined in paint_indexed_entry_names.asm.
; ENTRY_MAP_RIGHT + $20 is the cell one row below the first right column.

StageEntryNameMaskColumn::
    stage_entry_name_strip ENTRY_ROW1_TILES, ENTRY_MAP_RIGHT + $20, ENTRY_ROW1_LO, ENTRY_ROW1_HI
