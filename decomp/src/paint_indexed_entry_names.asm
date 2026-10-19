; Bank 6 at $5385. LoadFiveSramEntryDigits calls this through CallBankedHL
; with bank 6 in E, after the two $C71B scripts and before the digit fill.
;
; WRAM bank 7 is stored at wCurrentWRAMBank and selected with rSVBK.
; [$CDD6], the entry index, is copied to $D063. The byte at $D37A plus that
; index chooses the map column: $02 uses $9C04, any other byte uses $9C03.
; Both columns share the VRAM pointer $8860 and the tile bytes $86 $8F $90.
;
; The id at sEntryIds[index] is read from the SRAM bank at $C727. $FF skips
; the record. Any other id times $25 selects a record in the next SRAM bank,
; and that record's first byte is the name id. $FF selects the ten spaces at
; BlankIndexedName. Any other id times ten selects a name at IndexedNameTable.
; That pointer is stored at wStripText. wStripPasses becomes $0B, and
; wStripRoutine becomes $2B8F. JumpHL then runs that pointer, FinishFrame
; follows, and the pass count is decremented until it is zero.
;
; $D063 is incremented. A mask byte of $02 jumps to $559B. Otherwise the same
; name lookup is staged at map cell $9C23 with VRAM pointer $8900 and tile
; bytes $90 $8F $9A, and this slice jumps to the next pass loop at $5636.
;
; wCurrentWRAMBank, rSVBK, and WRAM_BANK_ENTRY are already defined.
; wEntryIndex, wUnknownD063, wEntryMask, and ENTRY_MASK_CLEAR are the names
; from load_five_sram_entry_digits.asm. rRAMG is the name from reset.asm.
; rRAMB, wSRAMBank, and SRAM_ENABLE are the names from handle_start_press.asm.
; sEntryIds, sEntryBase, and ENTRY_STRIDE are the names from
; indexed_tail_07.asm. BlankIndexedName, IndexedNameTable, and
; INDEXED_NAME_LEN are the names from copy_indexed_name.asm. wUnknownC93D
; and wListTailDest are the names from setup_command_4d.asm. wUnknownC6E9
; is the name from indexed_tail_07.asm. The wStrip* names, STRIP_MAP_HI,
; STRIP_TILE_MID, STRIP_FLAG, and STRIP_ROUTINE are the names from
; run_d0b1_map_strips.asm. JumpHL, FinishFrame, and MulCByB are already
; source. $559B and $5636 are still INCBIN. `add a, $00` keeps the SRAM
; bank byte. The second `ld b, a` after `cp $FF` repeats the copy that
; already followed the compare.

; VRAM pointer and tile bytes for the first row. The middle tile is $8F.
DEF ENTRY_ROW0_TILES EQU $8860
DEF ENTRY_ROW0_LO EQU $86
DEF ENTRY_ROW0_HI EQU $90
; Left column when the mask byte is not $02. Right column is the next cell.
DEF ENTRY_MAP_LEFT EQU $03
DEF ENTRY_MAP_RIGHT EQU $04
; Second row, left column. Reached after $D063 is incremented.
DEF ENTRY_ROW1_TILES EQU $8900
DEF ENTRY_ROW1_MAP EQU $23
DEF ENTRY_ROW1_LO EQU $90
DEF ENTRY_ROW1_HI EQU $9A

; \1 VRAM pointer, \2 map low byte, \3 first tile byte, \4 last tile byte.
; Points wStripText at the indexed name, then sets the $2B8F pass count.
MACRO stage_entry_name_strip
    ld a, LOW(wListTailDest)
    ld [wUnknownC93D], a
    ld a, HIGH(wListTailDest)
    ld [wUnknownC93D + 1], a
    ld a, STRIP_FLAG
    ld [wStripFlag], a
    ld a, LOW(\1)
    ld [wUnknownC6E9], a
    ld [wStripTileEcho], a
    ld a, HIGH(\1)
    ld [wUnknownC6E9 + 1], a
    ld [wStripTileEcho + 1], a
    ld a, \2
    ld [wStripMapCell], a
    ld a, STRIP_MAP_HI
    ld [wStripMapCell + 1], a
    ld a, \3
    ld [wStripTileLo], a
    ld [wStripTileLoCopy], a
    ld a, STRIP_TILE_MID
    ld [wStripTileMid], a
    ld a, \4
    ld [wStripTileHi], a
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [wUnknownD063]
    ld c, a
    ld b, $00
    ld hl, sEntryIds
    add hl, bc
    ld a, [hl]
    cp $ff
    ld b, a
    jr z, .noId\@
    ld b, a
    ld c, ENTRY_STRIDE
    call MulCByB
    ld a, [wSRAMBank]
    add $01
    ld [rRAMB], a
    ld bc, sEntryBase
    add hl, bc
    ld b, [hl]
.noId\@
    xor a
    ld [rRAMG], a
    ld a, b
    cp $ff
    jr nz, .named\@
    ld hl, BlankIndexedName
    jr .store\@
.named\@
    ld c, a
    ld b, INDEXED_NAME_LEN
    call MulCByB
    ld bc, IndexedNameTable
    add hl, bc
.store\@
    ld a, l
    ld [wStripText], a
    ld a, h
    ld [wStripText + 1], a
    ld a, INDEXED_NAME_LEN
    inc a
    ld [wStripPasses], a
    ld a, LOW(STRIP_ROUTINE)
    ld [wStripRoutine], a
    ld a, HIGH(STRIP_ROUTINE)
    ld [wStripRoutine + 1], a
ENDM

PaintIndexedEntryNames::
    ld a, WRAM_BANK_ENTRY
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [wEntryIndex]
    ld hl, wUnknownD063
    ld [hl], a
    ld c, a
    ld b, $00
    ld hl, wEntryMask
    add hl, bc
    ld a, [hl]
    cp ENTRY_MASK_CLEAR
    jp z, .rightColumn
    stage_entry_name_strip ENTRY_ROW0_TILES, ENTRY_MAP_LEFT, ENTRY_ROW0_LO, ENTRY_ROW0_HI
    jp .passes
.rightColumn:
    stage_entry_name_strip ENTRY_ROW0_TILES, ENTRY_MAP_RIGHT, ENTRY_ROW0_LO, ENTRY_ROW0_HI
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
    jp z, StageEntryNameMaskColumn
    stage_entry_name_strip ENTRY_ROW1_TILES, ENTRY_ROW1_MAP, ENTRY_ROW1_LO, ENTRY_ROW1_HI
    jp PassEntryNameStrip
