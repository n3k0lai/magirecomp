; Bank 3 at $667E. DispatchPrefixedBlockChoice jumps here when the
; choice at $CCA7 is $0C.
;
; A nonzero mark at $CCFB skips the row step. A zero mode at $CCCB
; copies $CCC8 into $CCD5, then adds $08 to $CCC8. Any other mode reads
; the last of the eight choice bytes at $CCCD ($CCD4), stores that value
; plus one at $CCD5, and adds $08 to $CCC8.
;
; $CCFB is cleared either way. $CCA7 is copied to $CD81. $6784 refreshes
; the list from the mode at $CCCB, fills the choice bytes, repaints the
; window, and rearms the slot. Control returns to
; DispatchPrefixedBlockChoice.
;
; $6784 is still INCBIN. RECORD_INDEX and LIMIT_08 are the names from
; stage_copied_block_arm_slot.asm. CHOICE_00 is the name from
; dispatch_armed_choice.asm. CHOICE_BYTES is the name from
; fill_choice_table_from_records.asm. LIST_MARK, CHOICE_MODE, and
; CHOICE_ROW are the names from setup_prefixed_block_choice.asm.
; wUnknownCD81 is the name from handle_start_press.asm.
; DispatchPrefixedBlockChoice is already source.

; Still INCBIN. Refreshes the list, fills the choice bytes, and rearms.
DEF Bank3_6784 EQU $6784

; Index of the last byte in the eight-byte table at $CCCD.
DEF LAST_CHOICE_OFFSET EQU $07

StepPrefixedBlockChoice0C::
    ld a, [LIST_MARK]
    cp CHOICE_00
    jr nz, .clearMark

    ld a, [CHOICE_MODE]
    cp CHOICE_00
    jr nz, .fromLastByte

    ld a, [CHOICE_ROW]
    ld [RECORD_INDEX], a
    add LIMIT_08
    ld [CHOICE_ROW], a
    jr .clearMark

.fromLastByte:
    ld hl, CHOICE_BYTES
    ld e, LAST_CHOICE_OFFSET
    ld d, $00
    add hl, de
    ld a, [hl]
    inc a
    ld [RECORD_INDEX], a
    ld a, [CHOICE_ROW]
    add LIMIT_08
    ld [CHOICE_ROW], a

.clearMark:
    xor a
    ld [LIST_MARK], a
    ld a, [$CCA7]
    ld [wUnknownCD81], a
    call Bank3_6784
    jp DispatchPrefixedBlockChoice
