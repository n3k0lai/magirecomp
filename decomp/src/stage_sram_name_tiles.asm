; Bank 3 at $7103. StageSramListNames calls this after TurnOffLCD.
; This routine does not write rROMB0. Bank changes go through CallBankedHL.
;
; rVBK is set to 1 with the 3-byte form. $CCC6 is cleared and the block
; destination at $CC45 is $8860. CopyIndexedBlocks advances that
; destination, so each pass continues after the tiles already written.
;
; Each of the eight bytes at $CCCD is a name id. The id is multiplied by
; the stride at $CCE8 and added to the name base at $CCE6. That sum is
; stored at $CD8D. $CD91 is set to tile index $10 and $CD8F points at
; $CD92. $5A87 in bank 6 copies $22 bytes from the word at $CD8D to the
; word at $CD8F, so the name follows that leading index. The block source
; at $CC43 is $CD91 plus the skip at $CCE9. The count at $CC42 is the
; byte at $CCEA plus one, which is the leading index plus a ten-byte name
; when that byte is $0A. CallBankedHL maps bank 6 and runs
; CopyIndexedBlocks. $CCD6 at (step + 3) becomes $01. $CCC6 advances.
; Eight steps return.
;
; An id of $FF leaves that loop. [$CCEA] plus one is passed to
; CopyRepeatedTileIndex, which stages that many copies of tile $20, and
; $CCD6 at (step + 3) is cleared. The remaining steps do the same and
; do not read $CCCD again.
;
; RECORD_STEP, PTR_LO, and PTR_HI are the names from
; stage_copied_block_arm_slot.asm. CHOICE_BYTES, CHOICE_SLOT_COUNT, and
; CHOICE_PAD are the names from fill_choice_table_from_records.asm.
; SLOT_PTR_CCD6 and TILE_DEST_8860 are the names from
; stage_tiles_arm_slot.asm. rVBK is the name from setup_window.asm.
; $CC42, $CC43, and $CC45 are named in handle_start_press.asm, which is
; included later, so this file uses the addresses. $CCE8, $CCE9, $CCEA,
; $CD8D, $CD8E, and $CD8F are named in stage_indexed_choice_tiles.asm,
; which is included later. MulCByB, CallBankedHL, CopyIndexedBlocks, and
; CopyRepeatedTileIndex are already source. $5A87 is still INCBIN.

; Still INCBIN in bank 6. Copies $22 bytes from [$CD8D] to [$CD8F].
DEF Bank6_5A87 EQU $5A87

DEF SRAM_NAME_STRIDE EQU $CCE8
DEF SRAM_NAME_SKIP EQU $CCE9
DEF SRAM_NAME_COUNT EQU $CCEA
DEF SRAM_NAME_PTR_LO EQU $CD8D
DEF SRAM_NAME_PTR_HI EQU $CD8E
DEF SRAM_NAME_DEST EQU $CD8F
DEF SRAM_NAME_LIST EQU $CD91
DEF SRAM_NAME_BANK EQU $06
DEF SRAM_NAME_LEAD EQU $10
DEF SRAM_NAME_MARK_AT EQU $03
DEF SRAM_NAME_PRESENT EQU $01

StageSramNameTiles::
    ld a, $01
    ld [rVBK], a
    xor a
    ld [RECORD_STEP], a
    ld de, TILE_DEST_8860
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d

.nextId:
    ld hl, CHOICE_BYTES
    ld a, [RECORD_STEP]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp CHOICE_PAD
    jr z, .padRest

    ld b, a
    ld a, [SRAM_NAME_STRIDE]
    ld c, a
    call MulCByB
    ld a, [PTR_HI]
    ld b, a
    ld a, [PTR_LO]
    ld c, a
    add hl, bc
    ld a, h
    ld [SRAM_NAME_PTR_HI], a
    ld a, l
    ld [SRAM_NAME_PTR_LO], a
    ld bc, SRAM_NAME_LIST
    ld a, SRAM_NAME_LEAD
    ld [bc], a
    inc bc
    ld hl, SRAM_NAME_DEST
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, Bank6_5A87
    ld e, SRAM_NAME_BANK
    call CallBankedHL
    ld hl, SRAM_NAME_LIST
    ld a, [SRAM_NAME_SKIP]
    ld e, a
    ld d, $00
    add hl, de
    ld a, h
    ld [$CC44], a
    ld a, l
    ld [$CC43], a
    ld a, [SRAM_NAME_COUNT]
    inc a
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, SRAM_NAME_BANK
    call CallBankedHL
    ld a, [RECORD_STEP]
    add SRAM_NAME_MARK_AT
    ld hl, SLOT_PTR_CCD6
    ld d, $00
    ld e, a
    add hl, de
    ld a, SRAM_NAME_PRESENT
    ld [hl], a
    ld hl, RECORD_STEP
    inc [hl]
    ld a, [hl]
    cp CHOICE_SLOT_COUNT
    jr nz, .nextId

    ret

.padRest:
    ld a, [SRAM_NAME_COUNT]
    inc a
    call CopyRepeatedTileIndex
    ld a, [RECORD_STEP]
    add SRAM_NAME_MARK_AT
    ld hl, SLOT_PTR_CCD6
    ld d, $00
    ld e, a
    add hl, de
    ld [hl], d
    ld hl, RECORD_STEP
    inc [hl]
    ld a, [hl]
    cp CHOICE_SLOT_COUNT
    jr nz, .padRest

    ret
