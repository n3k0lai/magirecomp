; Bank 6 at $5855. EntryNamePassAfterRow2 jumps here when the mask byte
; at the index after the fourth-row name pass is $02. Stages the right-hand
; map cell $9C64 with the row-3 tile window ($8A40, tiles $A4 $8F $AE)
; and the same SRAM name lookup as the left column. The strip then runs
; from the pass loop at $58F0, which is still INCBIN.
;
; stage_entry_name_strip is defined in paint_indexed_entry_names.asm.
; ENTRY_ROW3_TILES, ENTRY_ROW3_MAP, ENTRY_ROW3_LO, and ENTRY_ROW3_HI are
; defined in entry_name_pass_after_row2.asm. ENTRY_ROW3_MAP + 1 is the cell
; one column to the right of the left-hand fourth row.

EntryNameRow3MaskColumn::
    stage_entry_name_strip ENTRY_ROW3_TILES, ENTRY_ROW3_MAP + 1, ENTRY_ROW3_LO, ENTRY_ROW3_HI
