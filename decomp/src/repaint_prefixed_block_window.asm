; Bank 3 at $6796. StepPrefixedBlockChoice0B calls here after it
; shrinks $CCC8. $6784 also falls through here after it refreshes the
; list and fills the choice bytes.
;
; TurnOffLCD runs, then PlaceWindowCopyMap copies the 18-by-20 tilemap
; at $4B4B. StageIndexedChoiceTiles copies the eight choice records.
; $6801 paints those rows onto the window. $6B43 plants a one-entry list
; at $CCEC and $6C1A walks it. TurnOnLCDIfOff runs, $6D1F follows, and
; RefreshFrame updates the screen.
;
; The arm stores $06 in $CCB4 and $F3 in $CCA9, copies wCurrentWRAMBank
; to $CCB8, points $CCB6 at $CCD6, and stores $6B77 at $CCB0 and $42E3
; at $CCB2. $CD81 is written back to itself. $CCB9 is 1 and $CCBA is 0,
; so LoadArmedSlotRecord returns before ReloadSlotPosition. CallBankedHL
; maps bank 3 and runs that routine. $CCA7 is $FF. The latched slot at
; $CCC9 is cleared, and the routine returns.
;
; $6801 is still INCBIN. $6B43, $6C1A, and $6D1F are the names from
; setup_prefixed_block_choice.asm and step_prefixed_block_choice_00.asm.
; TILEMAP_4B4B, SLOT_TABLE_06, SLOT_BANK_PTR, SLOT_FLAG_CCB9, and
; SLOT_FLAG_CCBA are the names from setup_prefixed_block_choice.asm.
; SLOT_MARK_F3, SLOT_PTR_CCD6, SLOT_WORD_6B77, SLOT_WORD_42E3,
; SLOT_FLAG_ONE, CHOICE_WAIT, and BANK3_ARMED are the names from
; stage_tiles_arm_slot.asm. wCurrentWRAMBank is the name from
; timer_overflow.asm. wLatchedSlot is the name from
; dispatch_prefixed_block_choice.asm. $CD81 is named in
; handle_start_press.asm, which is included later, so this file uses
; that address. TurnOffLCD, PlaceWindowCopyMap, StageIndexedChoiceTiles,
; TurnOnLCDIfOff, RefreshFrame, CallBankedHL, and LoadArmedSlotRecord
; are already source.

RepaintPrefixedBlockWindow::
    call TurnOffLCD
    ld bc, TILEMAP_4B4B
    call PlaceWindowCopyMap
    call StageIndexedChoiceTiles
    call PaintPrefixedChoiceRows
    call Bank3_6B43
    call Bank3_6C1A
    call TurnOnLCDIfOff
    call Bank3_6D1F
    call RefreshFrame
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
    xor a
    ld [wLatchedSlot], a
    ret
