; Bank 3 at $5400. Called after a counted block is copied to $D000 in
; WRAM bank 6 and bank 3 is stored to wCurrentROMBank and rROMB0.
;
; WRAM bank 6 is selected. [$D000] is saved at $CCCC. $CCD5 and $CCC6
; are cleared. $CCEB is $0B and $CCC8 is $08. $CCE6 points at $D001.
; $CCCB is $03. $7463 runs, then $76FA with BC = $4CB3.
;
; The block destination at $CC45 is $8860, and $772F runs with A = $68.
; The block source at $CC43 is $5302 and the count at $CC42 is $1E.
; CallBankedHL maps bank 6 and runs CopyIndexedBlocks. $5627,
; TurnOnLCDIfOff, and RefreshFrame run. $CCE3 is 3 and the destination
; is $8860 again. TurnOffLCD, $54F2, and $555E run, then the LCD is
; turned on. $CCE3 is cleared and $77C2 runs. $CCE1 and $CCE2 are
; cleared. When [$CCCC] is above $08, $CCE2 becomes 1 and $7751 runs.
; Otherwise $779D runs.
;
; The choice block matches the $50D0 setup, except $CD81 is 3.
; CallBankedHL maps bank 3 and runs LoadArmedSlotRecord. $CCA7 is $FF.
; Control leaves through $52BC.
;
; $7463, $76FA, $772F, $5627, $54F2, $555E, $77C2, $7751, $779D, and
; $52BC are still INCBIN. wCurrentWRAMBank and rSVBK are the names from
; timer_overflow.asm. CallBankedHL, CopyIndexedBlocks, LoadArmedSlotRecord,
; TurnOffLCD, TurnOnLCDIfOff, and RefreshFrame are already source.
; $CC42, $CC43, and $CC45 are named in handle_start_press.asm, which is
; included later, so this file uses the addresses.

; Still INCBIN in this bank.
DEF Bank3_77C2 EQU $77C2
DEF Bank3_7751 EQU $7751
DEF Bank3_779D EQU $779D

DEF COPIED_BLOCK_BANK EQU $06
DEF COPIED_BLOCK_BASE EQU $D000
DEF COPIED_BLOCK_DATA EQU $D001
DEF RECORD_LEN EQU $CCCC
DEF RECORD_INDEX EQU $CCD5
DEF RECORD_STEP EQU $CCC6
DEF MARK_CCEB EQU $0B
DEF LIMIT_08 EQU $08
DEF PTR_LO EQU $CCE6
DEF PTR_HI EQU $CCE7
DEF MODE_03 EQU $03
DEF TILE_DEST_8860_5400 EQU $8860
DEF TILE_SRC_5302 EQU $5302
DEF TILE_BLOCK_COUNT_1E EQU $1E
DEF TILE_CALL_A_5400 EQU $68
DEF BANK6_COPY_5400 EQU $06
DEF FLAG_CCE3 EQU $CCE3
DEF PAIR_CCE1 EQU $CCE1
DEF LONG_MARK EQU $01
DEF SLOT_INDEX_3 EQU $03
DEF SLOT_TABLE_INDEX_5400 EQU $08
DEF SLOT_MARK_F3_5400 EQU $F3
DEF SLOT_PTR_CCD6_5400 EQU $CCD6
DEF SLOT_WORD_6B77_5400 EQU $6B77
DEF SLOT_WORD_42E3_5400 EQU $42E3
DEF SLOT_FLAG_ONE_5400 EQU $01
DEF CHOICE_WAIT_5400 EQU $FF
DEF BANK3_ARMED_5400 EQU $03

StageCopiedBlockArmSlot::
    ld a, COPIED_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld a, [COPIED_BLOCK_BASE]
    ld [RECORD_LEN], a
    xor a
    ld [RECORD_INDEX], a
    ld [RECORD_STEP], a
    ld a, MARK_CCEB
    ld [$CCEB], a
    ld a, LIMIT_08
    ld [$CCC8], a
    ld hl, COPIED_BLOCK_DATA
    ld a, h
    ld [PTR_HI], a
    ld a, l
    ld [PTR_LO], a
    ld a, MODE_03
    ld [$CCCB], a
    call PaintMapAttrsSeedSlot
    ld bc, $4CB3
    call PlaceWindowCopyMap
    ld de, TILE_DEST_8860_5400
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d
    ld a, TILE_CALL_A_5400
    call CopyRepeatedTileIndex
    ld bc, TILE_SRC_5302
    ld hl, $CC43
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, TILE_BLOCK_COUNT_1E
    ld [$CC42], a
    ld hl, CopyIndexedBlocks
    ld e, BANK6_COPY_5400
    call CallBankedHL
    call PaintCopiedBlockMapStrips
    call TurnOnLCDIfOff
    call RefreshFrame
    ld a, MODE_03
    ld [FLAG_CCE3], a
    ld de, TILE_DEST_8860_5400
    ld hl, $CC45
    ld a, e
    ld [hl+], a
    ld [hl], d
    call TurnOffLCD
    call FillChoiceTableFromRecords
    call CopyChoiceRecordTiles
    call TurnOnLCDIfOff
    xor a
    ld [FLAG_CCE3], a
    call Bank3_77C2
    xor a
    ld hl, PAIR_CCE1
    ld [hl+], a
    ld [hl], a
    ld a, [RECORD_LEN]
    ld c, a
    ld a, LIMIT_08
    ld [$CCC8], a
    cp c
    jr nc, .withinLimit

    ld a, LONG_MARK
    ld [hl], a
    call Bank3_7751
    jr .armSlot

.withinLimit:
    call Bank3_779D

.armSlot:
    ld a, SLOT_INDEX_3
    ld [$CD81], a
    ld a, SLOT_TABLE_INDEX_5400
    ld [$CCB4], a
    ld a, SLOT_MARK_F3_5400
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
    ld bc, SLOT_PTR_CCD6_5400
    ld hl, $CCB6
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_6B77_5400
    ld hl, $CCB0
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld bc, SLOT_WORD_42E3_5400
    ld hl, $CCB2
    ld a, c
    ld [hl+], a
    ld [hl], b
    ld a, [$CD81]
    ld [$CD81], a
    ld a, SLOT_FLAG_ONE_5400
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, BANK3_ARMED_5400
    call CallBankedHL
    ld a, CHOICE_WAIT_5400
    ld [$CCA7], a
    jp DispatchCopiedBlockChoice

StageCopiedBlockArmSlotEnd:
