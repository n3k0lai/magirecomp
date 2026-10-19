; Bank 3 at $6D1F. StepPrefixedBlockChoice00 calls here when the
; mode at $CCCB already equals the $00 or $01 choice.
;
; $CCE2 is $CCD6 + $0C. While the row at $CCC8 is still below the
; length at $CCCC, $CCE2 becomes 1 and RefreshFrameMarkPair runs with
; A = [$CCEB]. Once the row reaches that length, $CCE2 is cleared.
;
; $CCE1 is $CCD6 + $0B. The row is reduced by one only for the compare
; with $08; that difference is not stored. While it stays below $08,
; $CCE1 is cleared. Once it reaches $08, $CCE1 becomes 1 and
; RefreshFrameMarkWindowPair runs. Both stores use ld [hl-], so HL
; lands on $CCE0 and is not read again.
;
; ScanArmedSlotMarks then walks the ten marks at $CCD9-$CCE2. A copied
; mark refreshes the choice cell and returns. A miss blanks those
; cells, clears $CD81, stores 3 in $CCE3, and returns.
;
; CHOICE_ROW is the name from setup_prefixed_block_choice.asm.
; RECORD_LEN, LIMIT_08, LONG_MARK, and FLAG_CCE3 are the names from
; stage_copied_block_arm_slot.asm. PAIR_FROM_CCD6 is the name from
; step_prefixed_block_choice_00.asm. SLOT_PTR_CCD6 is the name from
; stage_tiles_arm_slot.asm. CCE3_VALUE is the name from
; stage_tiles_arm_slot.asm. CD81_CLEARED and CCE3_ZERO are the names
; from step_fe_choice_by_cce3.asm. RefreshFrameMarkPair,
; RefreshFrameMarkWindowPair, ScanArmedSlotMarks,
; RefreshFrameChoiceCell, and RefreshFrameBlankChoiceCells are already
; source. This routine does not write rROMB0.

; $CCD6 + $0C is the long-list mark at $CCE2.
DEF ROW_MARK_FROM_CCD6 EQU $0C

SyncRowEndMarksThenScan::
    ld hl, SLOT_PTR_CCD6
    ld c, ROW_MARK_FROM_CCD6
    ld b, $00
    add hl, bc
    ld a, [RECORD_LEN]
    ld b, a
    ld a, [CHOICE_ROW]
    cp b
    jr nc, .clearLongMark

    ld a, LONG_MARK
    ld [hl], a
    ld a, [$CCEB]
    call RefreshFrameMarkPair
    jr .checkShortMark

.clearLongMark:
    xor a
    ld [hl], a

.checkShortMark:
    ld hl, SLOT_PTR_CCD6
    ld c, PAIR_FROM_CCD6
    ld b, $00
    add hl, bc
    ld a, [CHOICE_ROW]
    ld b, LIMIT_08
    dec a
    cp b
    jr c, .clearShortMark

    ld a, LONG_MARK
    ld [hl-], a
    call RefreshFrameMarkWindowPair
    jr .scanMarks

.clearShortMark:
    xor a
    ld [hl-], a

.scanMarks:
    call ScanArmedSlotMarks
    cp CCE3_ZERO
    jr z, .noCopiedMark

    call RefreshFrameChoiceCell
    ret

.noCopiedMark:
    call RefreshFrameBlankChoiceCells
    ld a, CD81_CLEARED
    ld [$CD81], a
    ld a, CCE3_VALUE
    ld [FLAG_CCE3], a
    ret

SyncRowEndMarksThenScanEnd:
