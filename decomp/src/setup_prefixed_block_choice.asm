; Bank 3 at $66BE. CopyPrefixedBlockThenCall66BE copies the prefixed
; block to $D000, maps this bank, and calls here.
;
; PaintMapAttrsSeedSlot fills the attribute map and plants the slot
; record. PlaceWindowCopyMap then copies the 18-by-20 tilemap at $4B4B.
; $CCC6 and $CCFB are cleared. $CCC8 is $08. $CCCB and $CCE3 are 3.
; $CCEB is $04 and $CD81 is 0. WRAM bank 6 is stored at
; wCurrentWRAMBank and selected with rSVBK, and [$D000] is saved at
; $CCCC. The choice list is $A3A7 at $CCE4, the group base is $5DFF at
; $CCE6, the stride at $CCE8 is $22, the skip at $CCE9 is $0C, and the
; count at $CCEA is $0D.
;
; TurnOffLCD runs. The block destination at $CC45 is $8860, and
; CopyRepeatedTileIndex stages $68 copies of tile $20. $77F3 then copies
; the $0D tiles at $52E5. $6B43 plants a one-entry list at $CCEC and
; $6C1A walks it.
;
; The arm stores $06 in $CCB4 and $F3 in $CCA9, copies the WRAM bank to
; $CCB8, points $CCB6 at $CCD6, and stores $6B77 at $CCB0 and $42E3 at
; $CCB2. $CD81 is written back to itself. $CCB9 is 1 and $CCBA is 0, so
; LoadArmedSlotRecord returns before ReloadSlotPosition. CallBankedHL
; maps bank 3 and runs that routine. $CCA7 is $FF, TurnOnLCDIfOff runs,
; and control leaves through the choice loop at $65D9.
;
; $65D9, $6B43, $6C1A, and $77F3 are still INCBIN. wCurrentWRAMBank and
; rSVBK are the names from timer_overflow.asm. RECORD_LEN, RECORD_STEP,
; PTR_LO, and PTR_HI are the names from stage_copied_block_arm_slot.asm.
; TILE_DEST_8860, TILE_CALL_A, SLOT_MARK_F3, SLOT_PTR_CCD6,
; SLOT_WORD_6B77, SLOT_WORD_42E3, SLOT_FLAG_ONE, CHOICE_WAIT, and
; BANK3_ARMED are the names from stage_tiles_arm_slot.asm. $CC42, $CC43,
; and $CC45 are named in handle_start_press.asm, which is included
; later, so this file uses those addresses. PaintMapAttrsSeedSlot,
; PlaceWindowCopyMap, CopyRepeatedTileIndex, TurnOffLCD, TurnOnLCDIfOff,
; CallBankedHL, and LoadArmedSlotRecord are already source.

; Still INCBIN in this bank.
DEF Bank3_6B43 EQU $6B43
DEF Bank3_6C1A EQU $6C1A

DEF TILEMAP_4B4B EQU $4B4B
DEF CHOICE_ROW_08 EQU $08
DEF MODE_BOTH_03 EQU $03
DEF MARK_CCEB_04 EQU $04
DEF STRIDE_22 EQU $22
DEF SKIP_0C EQU $0C
DEF COUNT_0D EQU $0D
DEF GROUP_BASE_5DFF EQU $5DFF
DEF LIST_A3A7 EQU $A3A7
DEF TILES_52E5 EQU $52E5
DEF SLOT_TABLE_06 EQU $06
DEF SLOT_BANK_PTR EQU $CCB8
DEF SLOT_FLAG_CCB9 EQU $CCB9
DEF SLOT_FLAG_CCBA EQU $CCBA
DEF CHOICE_MODE EQU $CCCB
DEF CHOICE_ROW EQU $CCC8
DEF LIST_MARK EQU $CCFB
DEF LIST_PTR_LO EQU $CCE4
DEF LIST_PTR_HI EQU $CCE5
DEF STRIDE_BYTE EQU $CCE8
DEF SKIP_BYTE EQU $CCE9
DEF COUNT_BYTE EQU $CCEA

SetupPrefixedBlockChoice::
    call PaintMapAttrsSeedSlot
    ld bc, TILEMAP_4B4B
    call PlaceWindowCopyMap
    xor a
    ld [RECORD_STEP], a
    ld [LIST_MARK], a
    ld a, CHOICE_ROW_08
    ld [CHOICE_ROW], a
    ld a, MODE_BOTH_03
    ld [CHOICE_MODE], a
    ld [FLAG_CCE3], a
    ld a, MARK_CCEB_04
    ld [$CCEB], a
    ld a, $00
    ld [$CD81], a
    ld a, COPIED_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [COPIED_BLOCK_BASE]
    ld [RECORD_LEN], a
    ld a, STRIDE_22
    ld [STRIDE_BYTE], a
    ld a, SKIP_0C
    ld [SKIP_BYTE], a
    ld hl, GROUP_BASE_5DFF
    ld a, h
    ld [PTR_HI], a
    ld a, l
    ld [PTR_LO], a
    ld hl, LIST_A3A7
    ld a, h
    ld [LIST_PTR_HI], a
    ld a, l
    ld [LIST_PTR_LO], a
    ld a, COUNT_0D
    ld [COUNT_BYTE], a
    call TurnOffLCD
    ld de, TILE_DEST_8860
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld a, TILE_CALL_A
    call CopyRepeatedTileIndex
    ld bc, TILES_52E5
    ld a, COUNT_0D
    call CopyFixedThenCallerTiles
    call Bank3_6B43
    call Bank3_6C1A
    ld a, SLOT_TABLE_06
    ld [$CCB4], a
    ld a, SLOT_MARK_F3
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [SLOT_BANK_PTR], a
    ld bc, SLOT_PTR_CCD6
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_6B77
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_42E3
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$CD81]
    ld [$CD81], a
    ld a, SLOT_FLAG_ONE
    ld [SLOT_FLAG_CCB9], a
    ld a, $00
    ld [SLOT_FLAG_CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, BANK3_ARMED
    call CallBankedHL
    ld a, CHOICE_WAIT
    ld [$CCA7], a
    call TurnOnLCDIfOff
    jp DispatchPrefixedBlockChoice

SetupPrefixedBlockChoiceEnd:
