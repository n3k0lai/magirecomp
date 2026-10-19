; Bank 6 at $59B2. EntryNamePassAfterRow3 jumps here when the mask byte
; after the fourth-row name pass is $02. Stages the right-hand column of
; the fifth entry-name row: map cell $9C84, tile window $8AE0, and tile
; bytes $AE $8F $B8, with the same SRAM name lookup as the left column.
;
; The strip then runs in place: wStripRoutine ($2B8F) is called through
; JumpHL, FinishFrame runs, and wStripPasses is decremented until it is
; zero. The left column at $58F0 jumps to that same loop ($5A4D). This
; copy returns instead of staging another row.
;
; stage_entry_name_strip is defined in paint_indexed_entry_names.asm.
; ENTRY_ROW4_TILES, ENTRY_ROW4_MAP, ENTRY_ROW4_LO, and ENTRY_ROW4_HI are
; defined in entry_name_pass_after_row3.asm. ENTRY_ROW4_MAP + 1 is the cell
; one column to the right of the left-hand fifth row.

EntryNameRow4MaskColumn::
    stage_entry_name_strip ENTRY_ROW4_TILES, ENTRY_ROW4_MAP + 1, ENTRY_ROW4_LO, ENTRY_ROW4_HI
.passes:
    ld hl, wStripRoutine
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    call JumpHL
    call FinishFrame
    ld hl, wStripPasses
    dec [hl]
    jr nz, .passes
    ret
