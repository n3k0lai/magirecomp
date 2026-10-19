; Bank 6 at $56F8. PassEntryNameStrip jumps here when the mask byte
; at the index after the third-row name pass is $02. Stages the right-hand
; map cell $9C44 with the row-2 tile window ($89A0, tiles $9A $8F $A4)
; and the same SRAM name lookup as the left column. The strip then runs
; from the pass loop at $5793, which is still INCBIN.
;
; stage_entry_name_strip is defined in paint_indexed_entry_names.asm.
; ENTRY_ROW2_TILES, ENTRY_ROW2_MAP, ENTRY_ROW2_LO, and ENTRY_ROW2_HI are
; defined in pass_entry_name_strip.asm. ENTRY_ROW2_MAP + 1 is the cell
; one column to the right of the left-hand third row.

EntryNameRow2MaskColumn::
    stage_entry_name_strip ENTRY_ROW2_TILES, ENTRY_ROW2_MAP + 1, ENTRY_ROW2_LO, ENTRY_ROW2_HI
