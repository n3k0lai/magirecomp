; Bank 3 at $6E56. DispatchSramListChoice jumps here when $CCA7 is $0C.
;
; $CCD5 grows by $08, then StageSramListNames fills the names from SRAM.
; $CCA7 is copied to $CD81 and $7777 runs. $CCE1 becomes 1, leaving HL
; at $CCE2. Another $08 is added to $CCD5 only for the compare with
; [$CCCC]; that sum is not stored. While it stays below the ceiling,
; $7751 runs. Once it reaches [$CCCC], $CCE2 is cleared, $CD81 becomes
; $0B, and $779D runs.
;
; The arm stores $08 in $CCB4 and $F3 in $CCA9, copies wCurrentWRAMBank
; to $CCB8, points $CCB6 at $CCD6, stores $6B77 at $CCB0 and $42E3 at
; $CCB2, writes $CD81 back to itself, sets $CCB9 to 1 and $CCBA to 0,
; and CallBankedHL runs LoadArmedSlotRecord in this bank. $CCA7 is then
; $FF and control returns to DispatchSramListChoice.
;
; $7751, $7777, and $779D are still INCBIN. wCurrentWRAMBank is the name
; from timer_overflow.asm. CHOICE_ROW_PLUS, CHOICE_CEILING, and
; CHOICE_STEP are the names from step_choice_0c_by_ccc8.asm.
; SLOT_TABLE_INDEX, SLOT_MARK_F3, SLOT_PTR_CCD6, SLOT_WORD_6B77,
; SLOT_WORD_42E3, SLOT_FLAG_ONE, CHOICE_WAIT, and BANK3_ARMED are the
; names from stage_tiles_arm_slot.asm. LIMIT_08 and LONG_MARK are the
; names from stage_copied_block_arm_slot.asm. CHOICE_0B is the name
; from dispatch_armed_choice.asm. Bank3_7751, Bank3_7777, and Bank3_779D
; are the names from the $4FBE and $5400 steps. StageSramListNames,
; CallBankedHL, LoadArmedSlotRecord, and DispatchSramListChoice are
; already source. This routine does not write rROMB0.

StepSramListChoice0C::
    ld a, [CHOICE_ROW_PLUS]
    add LIMIT_08
    ld [CHOICE_ROW_PLUS], a
    call StageSramListNames
    ld a, [$CCA7]
    ld [$CD81], a
    call Bank3_7777
    ld a, LONG_MARK
    ld hl, CHOICE_STEP
    ld [hl+], a
    ld a, [CHOICE_CEILING]
    ld c, a
    ld a, [CHOICE_ROW_PLUS]
    add LIMIT_08
    cp c
    jr c, .underCeiling

    ld a, $00
    ld [hl], a
    ld a, CHOICE_0B
    ld [$CD81], a
    call Bank3_779D
    jr .armSlot

.underCeiling:
    call Bank3_7751

.armSlot:
    ld a, SLOT_TABLE_INDEX
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
    jp DispatchSramListChoice
