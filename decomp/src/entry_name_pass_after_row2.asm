; Bank 6 at $5793. PassEntryNameStrip jumps here after staging the third-row
; name strip. wStripRoutine ($2B8F) is called through JumpHL, FinishFrame
; runs, and wStripPasses is decremented until it is zero.
;
; $D063 is incremented. A mask byte of $02 jumps to $5855. Otherwise the
; same SRAM name lookup is staged at map cell $9C63 with VRAM pointer
; $8A40 and tile bytes $A4 $8F $AE, and this slice jumps to the next pass
; loop at $58F0.
;
; stage_entry_name_strip, wStripRoutine, wStripPasses, JumpHL, FinishFrame,
; wUnknownD063, wEntryMask, and ENTRY_MASK_CLEAR are already defined.
; $5855 and $58F0 are still INCBIN.

; Fourth row, left column. One row below the third-row left cell $9C43.
DEF ENTRY_ROW3_TILES EQU $8A40
DEF ENTRY_ROW3_MAP EQU $63
DEF ENTRY_ROW3_LO EQU $A4
DEF ENTRY_ROW3_HI EQU $AE

EntryNamePassAfterRow2::
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
    jp z, EntryNameRow3MaskColumn
    stage_entry_name_strip ENTRY_ROW3_TILES, ENTRY_ROW3_MAP, ENTRY_ROW3_LO, ENTRY_ROW3_HI
    jp EntryNamePassAfterRow3
