; Bank 6 at $58F0. EntryNamePassAfterRow2 and EntryNameRow3MaskColumn
; both jump here after staging the fourth-row name strip. wStripRoutine
; ($2B8F) is called through JumpHL, FinishFrame runs, and wStripPasses is
; decremented until it is zero.
;
; $D063 is incremented. A mask byte of $02 jumps to $59B2. Otherwise the
; same SRAM name lookup is staged at map cell $9C83 with VRAM pointer
; $8AE0 and tile bytes $AE $8F $B8, and this slice jumps to the next pass
; loop at $5A4D.
;
; stage_entry_name_strip, wStripRoutine, wStripPasses, JumpHL, FinishFrame,
; wUnknownD063, wEntryMask, and ENTRY_MASK_CLEAR are already defined.
; $59B2 and $5A4D are still INCBIN.

; Fifth row, left column. One row below the fourth-row left cell $9C63.
DEF ENTRY_ROW4_TILES EQU $8AE0
DEF ENTRY_ROW4_MAP EQU $83
DEF ENTRY_ROW4_LO EQU $AE
DEF ENTRY_ROW4_HI EQU $B8

; Mask byte $02 continues at this address. The other column jumps to $5A4D.
DEF EntryNameLoop5 EQU $5A4D

EntryNamePassAfterRow3::
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
    jp z, EntryNameRow4MaskColumn
    stage_entry_name_strip ENTRY_ROW4_TILES, ENTRY_ROW4_MAP, ENTRY_ROW4_LO, ENTRY_ROW4_HI
    jp EntryNameLoop5
