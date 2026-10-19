; Bank 3 at $555E. StageCopiedBlockArmSlot calls this after
; FillChoiceTableFromRecords and before the LCD is turned back on.
; The choice bytes are already in $CCCD. $CCC6 is reset here and walks
; those eight slots. The tile destination at $CC45 starts at $8860.
;
; rVBK is set to 1 with the 3-byte store, so the copies land in VRAM
; bank 1. A slot whose choice byte is not $FF is record
; [$CCD5] + slot. Its $0D tile indexes sit one byte after the id at
; $CCE6 plus that record times $0E. Those indexes and a count of $0D
; are handed to CopyIndexedBlocks in bank 6. The byte at
; $CCD6 + slot + 3 becomes 1.
;
; A slot whose choice byte is $FF skips the copy. $772F runs with
; A = $0D, and the byte at $CCD6 + slot + 3 becomes 0. What $772F
; writes is still unknown. Once either path has visited all eight
; slots, the routine returns. A is 8 and $CCC6 is 8.
;
; RECORD_INDEX, RECORD_STEP, PTR_LO, PTR_HI, and the $8860 destination
; are defined in stage_copied_block_arm_slot.asm. CHOICE_BYTES,
; CHOICE_PAD, CHOICE_SLOT_COUNT, and RECORD_STRIDE_0E are defined in
; fill_choice_table_from_records.asm. Bank3_772F is defined in
; stage_tiles_arm_slot.asm. $CC42, $CC43, and $CC44 are the block
; count and source used by CopyIndexedBlocks; handle_start_press.asm
; names the count and the low source byte later, so this file uses
; the addresses. rVBK is the name from setup_window.asm. MulCByB and
; CallBankedHL are already source. $772F is still INCBIN.

DEF TILE_ROM_BANK EQU $06
DEF VRAM_BANK_1 EQU $01
DEF RECORD_BODY_SKIP EQU $01
DEF RECORD_TILE_COUNT EQU $0D
DEF SLOT_MARK_BASE EQU $CCD6
DEF SLOT_MARK_BIAS EQU $03
DEF SLOT_MARK_COPIED EQU $01
DEF BLOCK_COUNT EQU $CC42
DEF BLOCK_SRC_LO EQU $CC43
DEF BLOCK_SRC_HI EQU $CC44

CopyChoiceRecordTiles::
    ld a, VRAM_BANK_1
    ld [rVBK], a
    xor a
    ld [RECORD_STEP], a
    ld de, TILE_DEST_8860_5400
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d

.nextSlot:
    ld hl, CHOICE_BYTES
    ld a, [RECORD_STEP]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp CHOICE_PAD
    jr z, .padSlot

    ld a, [RECORD_INDEX]
    add a, c
    ld b, a
    ld a, RECORD_STRIDE_0E
    ld c, a
    call MulCByB
    ld a, [PTR_HI]
    ld b, a
    ld a, [PTR_LO]
    ld c, a
    add hl, bc
    ld a, RECORD_BODY_SKIP
    ld e, a
    ld d, $00
    add hl, de
    ld a, h
    ld [BLOCK_SRC_HI], a
    ld a, l
    ld [BLOCK_SRC_LO], a
    ld a, RECORD_TILE_COUNT
    ld [BLOCK_COUNT], a
    ld hl, CopyIndexedBlocks
    ld e, TILE_ROM_BANK
    call CallBankedHL
    ld a, [RECORD_STEP]
    add a, SLOT_MARK_BIAS
    ld hl, SLOT_MARK_BASE
    ld d, $00
    ld e, a
    add hl, de
    ld a, SLOT_MARK_COPIED
    ld [hl], a
    ld hl, RECORD_STEP
    inc [hl]
    ld a, [hl]
    cp CHOICE_SLOT_COUNT
    jr nz, .nextSlot

    ret

.padSlot:
    ld a, RECORD_TILE_COUNT
    call Bank3_772F
    ld a, [RECORD_STEP]
    add a, SLOT_MARK_BIAS
    ld hl, SLOT_MARK_BASE
    ld d, $00
    ld e, a
    add hl, de
    ld [hl], d
    ld hl, RECORD_STEP
    inc [hl]
    ld a, [hl]
    cp CHOICE_SLOT_COUNT
    jr nz, .padSlot

    ret
