; Bank 6 at $5636. PaintIndexedEntryNames and StageEntryNameMaskColumn
; both jump here after staging a name strip. wStripRoutine ($2B8F) is
; called through JumpHL, FinishFrame runs, and wStripPasses is decremented
; until it is zero.
;
; $D063 is incremented. A mask byte of $02 jumps to $56F8. Otherwise the
; same SRAM name lookup is staged at map cell $9C43 with VRAM pointer
; $89A0 and tile bytes $9A $8F $A4, and this slice jumps to the next pass
; loop at $5793.
;
; stage_entry_name_strip, wStripRoutine, wStripPasses, JumpHL, FinishFrame,
; wUnknownD063, wEntryMask, and ENTRY_MASK_CLEAR are already defined.
; $56F8 and $5793 are still INCBIN.

; Third row, left column. One row below the second-row left cell $9C23.
DEF ENTRY_ROW2_TILES EQU $89A0
DEF ENTRY_ROW2_MAP EQU $43
DEF ENTRY_ROW2_LO EQU $9A
DEF ENTRY_ROW2_HI EQU $A4

PassEntryNameStrip::
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
    ld hl, wUnknownD063
    inc [hl]
    ld a, [hl]
    ld c, a
    ld b, $00
    ld hl, wEntryMask
    add hl, bc
    ld a, [hl]
    cp ENTRY_MASK_CLEAR
    jp z, EntryNameRow2MaskColumn
    stage_entry_name_strip ENTRY_ROW2_TILES, ENTRY_ROW2_MAP, ENTRY_ROW2_LO, ENTRY_ROW2_HI
    jp EntryNamePassAfterRow2
