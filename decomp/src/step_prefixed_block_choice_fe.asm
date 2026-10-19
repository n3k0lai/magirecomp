; Bank 3 at $6CA8. DispatchPrefixedBlockChoice jumps here when the
; choice at $CCA7 is $FE.
;
; $CCE3 selects the step. Zero calls $76E0. A zero result falls through
; to the arm. A nonzero result stores 3 in $CD81 and 1 in $CCE3, then
; arms the slot. Any $CCE3 other than 0 or 3 stores 3 in $CCE3 and 0 in
; $CD81, calls $76B1, and arms the slot. When $CCE3 is already 3,
; control leaves through $7637.
;
; The arm stores $06 in $CCB4 and $F3 in $CCA9, copies wCurrentWRAMBank
; to $CCB8, points $CCB6 at $CCD6, stores $6B77 at $CCB0 and $42E3 at
; $CCB2, writes $CD81 back to itself, sets $CCB9 to 1 and $CCBA to 0,
; and CallBankedHL runs LoadArmedSlotRecord in this bank. $CCA7 is then
; $FF and control returns to DispatchPrefixedBlockChoice.
;
; $76E0, $76B1, and $7637 are still INCBIN. wCurrentWRAMBank is the name
; from timer_overflow.asm. FLAG_CCE3 is the name from
; stage_copied_block_arm_slot.asm. CCE3_ZERO, CCE3_STEP, CD81_CLEARED,
; and CD81_BLOCK are the names from step_fe_choice_by_cce3.asm.
; CCE3_VALUE, SLOT_MARK_F3, SLOT_PTR_CCD6, SLOT_WORD_6B77,
; SLOT_WORD_42E3, SLOT_FLAG_ONE, CHOICE_WAIT, and BANK3_ARMED are the
; names from stage_tiles_arm_slot.asm. SLOT_TABLE_06 is the name from
; setup_prefixed_block_choice.asm. Bank3_7637 is the name from
; dispatch_armed_choice.asm. CallBankedHL, LoadArmedSlotRecord, and
; DispatchPrefixedBlockChoice are already source. This routine does not
; write rROMB0.

StepPrefixedBlockChoiceFE::
    ld a, [FLAG_CCE3]
    cp CCE3_ZERO
    jr z, .fromZero

    cp CCE3_VALUE
    jp z, Bank3_7637

    ld a, CCE3_VALUE
    ld [FLAG_CCE3], a
    ld a, CD81_CLEARED
    ld [$CD81], a
    call Bank3_76B1
    jr .armSlot

.fromZero
    call Bank3_76E0
    cp CCE3_ZERO
    jr z, .armSlot

    ld a, CD81_BLOCK
    ld [$CD81], a
    ld a, CCE3_STEP
    ld [FLAG_CCE3], a

.armSlot
    ld a, SLOT_TABLE_06
    ld [$CCB4], a
    ld a, SLOT_MARK_F3
    ld [$CCA9], a
    ld a, [wCurrentWRAMBank]
    ld [$CCB8], a
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
    ld [$CCB9], a
    ld a, $00
    ld [$CCBA], a
    ld hl, LoadArmedSlotRecord
    ld e, BANK3_ARMED
    call CallBankedHL
    ld a, CHOICE_WAIT
    ld [$CCA7], a
    jp DispatchPrefixedBlockChoice
