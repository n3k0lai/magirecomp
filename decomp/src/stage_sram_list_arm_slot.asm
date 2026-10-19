; Bank 3 at $7025. RewindCopyThenCall7025 calls this after the counted
; block is copied to $D000 and bank 3 is stored to wCurrentROMBank and
; rROMB0. This routine does not write rROMB0 itself. RefreshFrame
; restores it.
;
; PaintMapAttrsSeedSlot runs, then PlaceWindowCopyMap with BC pointing
; at the tilemap at $4E1B. $CCD5 and $CCE9 are cleared. $CD81 becomes 3.
; $CCE4 points at the ten-byte SRAM list at $A118.
;
; SRAM bank wSRAMBank is selected with `add a, $00`, which keeps that
; bank byte and its flags. Nothing reads them. SRAM is enabled, [$A122]
; is saved at $CCCC, and SRAM is disabled. $70D4 then runs.
;
; The arm stores $08 in $CCB4 and $F3 in $CCA9, copies wCurrentWRAMBank
; to $CCB8, points $CCB6 at $CCD6, stores $6B77 at $CCB0 and $42E3 at
; $CCB2, writes $CD81 back to itself, and sets $CCB9 to 1 and $CCBA to
; 0. CallBankedHL maps bank 3 and runs LoadArmedSlotRecord. $CCA7 is
; $FF. RefreshFrame runs. $CCE3 becomes 3 and $CCEB becomes $F3.
; RefreshFrameWindowPair runs. $CCE1 and $CCE2 are cleared. When
; [$CCCC] is above $08, $CCE2 becomes 1 and RefreshFrameMarkPair runs.
; Otherwise RefreshFrameBlankMarkPair runs. Control leaves through
; $6DA1, which is still INCBIN.
;
; $70D4 is still INCBIN. wSRAMBank, rRAMB, and SRAM_ENABLE are the names
; from handle_start_press.asm. rRAMG is the name from reset.asm.
; wCurrentWRAMBank is the name from timer_overflow.asm. LIST_SRAM is the
; name from resolve_armed_list_choice.asm. WINDOW_SRAM_BYTE is the name
; from stage_window_tiles_arm_slot.asm. RECORD_LEN, RECORD_INDEX,
; LIMIT_08, LONG_MARK, PAIR_CCE1, FLAG_CCE3, MODE_03, SLOT_INDEX_3, and
; the $5400 slot words are the names from stage_copied_block_arm_slot.asm.
; SKIP_AT_CCE9 is the name from stage_indexed_choice_tiles.asm.
; SLOT_MARK_F3 is the name from stage_tiles_arm_slot.asm.
; PaintMapAttrsSeedSlot, PlaceWindowCopyMap, CallBankedHL,
; LoadArmedSlotRecord, RefreshFrame, RefreshFrameWindowPair,
; RefreshFrameMarkPair, and RefreshFrameBlankMarkPair are already source.

; 18-by-20 tilemap in this bank. PlaceWindowCopyMap reads it through BC.
DEF TILEMAP_4E1B EQU $4E1B

StageSramListArmSlot::
    call PaintMapAttrsSeedSlot
    ld bc, TILEMAP_4E1B
    call PlaceWindowCopyMap
    xor a
    ld [RECORD_INDEX], a
    ld [SKIP_AT_CCE9], a
    ld a, SLOT_INDEX_3
    ld [$CD81], a
    ld hl, LIST_SRAM
    ld a, h
    ld [$CCE5], a
    ld a, l
    ld [$CCE4], a
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [WINDOW_SRAM_BYTE]
    ld [RECORD_LEN], a
    xor a
    ld [rRAMG], a
    call StageSramListNames
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
    call RefreshFrame
    ld a, MODE_03
    ld [FLAG_CCE3], a
    ld a, SLOT_MARK_F3
    ld [$CCEB], a
    call RefreshFrameWindowPair
    xor a
    ld hl, PAIR_CCE1
    ld [hl+], a
    ld [hl], a
    ld a, [RECORD_LEN]
    ld c, a
    ld a, LIMIT_08
    cp c
    jr nc, .atMostEight

    ld a, LONG_MARK
    ld [hl], a
    call RefreshFrameMarkPair
    jr .joinWait

.atMostEight:
    call RefreshFrameBlankMarkPair

.joinWait:
    jp DispatchSramListChoice
