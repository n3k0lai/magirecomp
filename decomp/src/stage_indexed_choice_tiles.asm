; Bank 3 at $7596. Called after TurnOffLCD from PrepareChoice012 and
; from the $0B and $0C choice steps.
;
; rVBK is set to 1 with the 3-byte form. $CCC6 is cleared and the block
; destination at $CC45 is $8860. CopyIndexedBlocks advances that
; destination, so each pass continues after the tiles already written.
;
; Each of the eight bytes at $CCCD is a record index. The index is
; multiplied by the stride at $CCE8 ($22 or $13) and added to the word
; at $CCE6. That sum is stored at $CD8D, $CD8F points at $CD91, and
; CallBankedHL maps bank 7 and runs CopyGroupBytes, which copies $22
; bytes to $CD91. The block source at $CC43 is $CD91 plus the skip at
; $CCE9, and the count at $CC42 is the byte at $CCEA. CallBankedHL then
; maps bank 6 and runs CopyIndexedBlocks. $CCD6 at (index + 3) becomes
; $01. $CCC6 advances. Eight steps return.
;
; An index of $FF leaves that loop. [$CCEA] is passed to
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
; included later, so this file uses the addresses. $CD8D, $CD8E, and
; $CD8F are wGroupScaled and wGroupListPtr in scan_group_bytes.asm,
; which is included later. MulCByB, CallBankedHL, CopyGroupBytes,
; CopyIndexedBlocks, and CopyRepeatedTileIndex are already source.

DEF STRIDE_AT_CCE8 EQU $CCE8
DEF SKIP_AT_CCE9 EQU $CCE9
DEF COUNT_AT_CCEA EQU $CCEA
DEF SCALED_LO EQU $CD8D
DEF SCALED_HI EQU $CD8E
DEF LIST_PTR EQU $CD8F
DEF COPIED_LIST EQU $CD91
DEF GROUP_BYTES_BANK EQU $07
DEF INDEXED_BLOCKS_BANK EQU $06
DEF MARK_OFFSET EQU $03
DEF MARK_PRESENT EQU $01

StageIndexedChoiceTiles::
    ld a, $01
    ld [rVBK], a
    xor a
    ld [RECORD_STEP], a
    ld de, TILE_DEST_8860
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d

.nextIndex:
    ld hl, CHOICE_BYTES
    ld a, [RECORD_STEP]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp CHOICE_PAD
    jr z, .padRest

    ld b, a
    ld a, [STRIDE_AT_CCE8]
    ld c, a
    call MulCByB
    ld a, [PTR_HI]
    ld b, a
    ld a, [PTR_LO]
    ld c, a
    add hl, bc
    ld a, h
    ld [SCALED_HI], a
    ld a, l
    ld [SCALED_LO], a
    ld bc, COPIED_LIST
    ld hl, LIST_PTR
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld hl, CopyGroupBytes
    ld e, GROUP_BYTES_BANK
    call CallBankedHL
    ld hl, COPIED_LIST
    ld a, [SKIP_AT_CCE9]
    ld e, a
    ld d, $00
    add hl, de
    ld a, h
    ld [$CC44], a
    ld a, l
    ld [$CC43], a
    ld a, [COUNT_AT_CCEA]
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, INDEXED_BLOCKS_BANK
    call CallBankedHL
    ld a, [RECORD_STEP]
    add MARK_OFFSET
    ld hl, SLOT_PTR_CCD6
    ld d, $00
    ld e, a
    add hl, de
    ld a, MARK_PRESENT
    ld [hl], a
    ld hl, RECORD_STEP
    inc [hl]
    ld a, [hl]
    cp CHOICE_SLOT_COUNT
    jr nz, .nextIndex

    ret

.padRest:
    ld a, [COUNT_AT_CCEA]
    call CopyRepeatedTileIndex
    ld a, [RECORD_STEP]
    add MARK_OFFSET
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
