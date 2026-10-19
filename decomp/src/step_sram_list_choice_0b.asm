; Bank 3 at $6DDC. DispatchSramListChoice jumps here when $CCA7 is $0B.
;
; $CCD5 is reduced by $08, then StageSramListNames fills the names from
; SRAM. A is [$CCEB] for RefreshFrameMarkPair. $CCE2 becomes 1, leaving
; HL at $CCE1. When the new $CCD5 is below $08, $CCE1 is cleared and
; RefreshFrameWindowPair runs. Any other value calls
; RefreshFrameMarkWindowPair instead.
;
; $CCA7 is copied to $CD81. The arm stores $08 in $CCB4 and $F3 in
; $CCA9, copies wCurrentWRAMBank to $CCB8, points $CCB6 at $CCD6,
; stores $6B77 at $CCB0 and $42E3 at $CCB2, writes $CD81 back to
; itself, sets $CCB9 to 1 and $CCBA to 0, and CallBankedHL runs
; LoadArmedSlotRecord in this bank. $CCA7 is then $FF and control
; returns to DispatchSramListChoice.
;
; wCurrentWRAMBank is the name from timer_overflow.asm. CHOICE_ROW_PLUS
; is the name from step_choice_0c_by_ccc8.asm. SLOT_TABLE_INDEX,
; SLOT_MARK_F3, SLOT_PTR_CCD6, SLOT_WORD_6B77, SLOT_WORD_42E3,
; SLOT_FLAG_ONE, CHOICE_WAIT, and BANK3_ARMED are the names from
; stage_tiles_arm_slot.asm. LIMIT_08 and LONG_MARK are the names from
; stage_copied_block_arm_slot.asm. StageSramListNames,
; RefreshFrameMarkPair, RefreshFrameWindowPair,
; RefreshFrameMarkWindowPair, CallBankedHL, LoadArmedSlotRecord, and
; DispatchSramListChoice are already source. This routine does not
; write rROMB0.

StepSramListChoice0B::
    ld a, [CHOICE_ROW_PLUS]
    sub LIMIT_08
    ld [CHOICE_ROW_PLUS], a
    call StageSramListNames
    ld a, [$CCEB]
    call RefreshFrameMarkPair
    ld hl, $CCE2
    ld a, LONG_MARK
    ld [hl-], a
    ld a, [CHOICE_ROW_PLUS]
    cp LIMIT_08
    jr nc, .notBelow

    ld a, $00
    ld [hl], a
    call RefreshFrameWindowPair
    jr .armSlot

.notBelow:
    call RefreshFrameMarkWindowPair

.armSlot:
    ld a, [$CCA7]
    ld [$CD81], a
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
