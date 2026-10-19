; Bank 3 at $6B7A. DispatchPrefixedBlockChoice jumps here when the
; choice at $CCA7 is $00 or $01.
;
; $CD81 becomes 3. The mode at $CCCB is compared with that choice.
;
; When they match, $CCE3 becomes 1 and $CD81 is stored as 3 again.
; $6D1F runs, then the slot is armed: $CCB4 is $06, $CCA9 is $F3,
; $CCB8 copies wCurrentWRAMBank, $CCB6 points at $CCD6, $CCB0 holds
; $6B77, and $CCB2 holds $42E3. $CD81 is written back to itself.
; $CCB9 is 1 and $CCBA is 0, so LoadArmedSlotRecord returns before
; ReloadSlotPosition. CallBankedHL runs that routine in this bank.
; $CCA7 becomes $FF and control returns to the choice loop.
;
; When they differ, $CCFB and $CCC6 are cleared and $CCC8 becomes $08.
; $CCE3 becomes $09. $CCE1, $0B bytes after $CCD6, is cleared and the
; next byte $CCE2 becomes 1. A choice of $00 stores $00 at $CCCB; $01
; stores $01. $CCD5 is cleared. $6784 refreshes the list, fills the
; choice bytes, and rearms the slot. Control returns to the choice loop.
;
; $6D1F is still INCBIN. $6784 is the name from the $0C step.
; wCurrentWRAMBank is the name from timer_overflow.asm. SLOT_INDEX_3,
; RECORD_STEP, RECORD_INDEX, FLAG_CCE3, PAIR_CCE1, LONG_MARK, and
; LIMIT_08 are the names from stage_copied_block_arm_slot.asm.
; SLOT_MARK_F3, SLOT_PTR_CCD6, SLOT_WORD_6B77, SLOT_WORD_42E3,
; SLOT_FLAG_ONE, CHOICE_WAIT, and BANK3_ARMED are the names from
; stage_tiles_arm_slot.asm. CCE3_STEP is the name from
; step_fe_choice_by_cce3.asm. CHOICE_00 and CHOICE_01 are the names
; from dispatch_armed_choice.asm. SLOT_TABLE_06, SLOT_BANK_PTR,
; SLOT_FLAG_CCB9, SLOT_FLAG_CCBA, CHOICE_MODE, CHOICE_ROW, and
; LIST_MARK are the names from setup_prefixed_block_choice.asm.
; $CD81 is named in handle_start_press.asm, which is included later,
; so this file uses that address. CallBankedHL, LoadArmedSlotRecord,
; and DispatchPrefixedBlockChoice are already source.

; Still INCBIN. Called when the mode already equals the choice.
DEF Bank3_6D1F EQU $6D1F

; Bytes from $CCD6 to the pair at $CCE1.
DEF PAIR_FROM_CCD6 EQU $0B

StepPrefixedBlockChoice00::
    ld a, SLOT_INDEX_3
    ld [$CD81], a
    ld a, [$CCA7]
    ld b, a
    ld a, [CHOICE_MODE]
    cp b
    jr nz, .modeDiffers

    ld a, CCE3_STEP
    ld [FLAG_CCE3], a
    ld a, SLOT_INDEX_3
    ld [$CD81], a
    call Bank3_6D1F
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
    jp DispatchPrefixedBlockChoice

.modeDiffers:
    xor a
    ld [LIST_MARK], a
    ld [RECORD_STEP], a
    ld a, LIMIT_08
    ld [CHOICE_ROW], a
    inc a
    ld [FLAG_CCE3], a
    ld hl, SLOT_PTR_CCD6
    ld d, $00
    ld e, PAIR_FROM_CCD6
    add hl, de
    ld [hl], d
    inc hl
    ld [hl], LONG_MARK
    ld a, [$CCA7]
    cp CHOICE_00
    jr z, .storeZeroMode

    ld a, CHOICE_01
    ld [CHOICE_MODE], a
    jr .clearIndex

.storeZeroMode:
    ld a, CHOICE_00
    ld [CHOICE_MODE], a

.clearIndex:
    xor a
    ld [RECORD_INDEX], a
    call Bank3_6784
    jp DispatchPrefixedBlockChoice
