; Bank 3 at $6653. DispatchPrefixedBlockChoice jumps here when the
; choice at $CCA7 is $0B.
;
; $CCFB is cleared. $6B25 then refreshes the list: a zero mode at $CCCB
; copies [$D000] to $CCCC in WRAM bank 6, and any other mode calls $74EF
; with the list at $A3A7. A zero mode decrements $CCD5 and $68E8 refills
; the choice bytes from that record. A nonzero mode calls $7512, which
; walks the SRAM list using $CCD5 minus one.
;
; $CCC8 is reduced by $08. $6796 repaints the window and rearms the slot,
; and control returns to DispatchPrefixedBlockChoice.
;
; $6B25, $68E8, and $6796 are still INCBIN. $7512 is the name from
; step_choice_0b_by_ccc8.asm. RECORD_INDEX and LIMIT_08 are the names
; from stage_copied_block_arm_slot.asm. CHOICE_00 is the name from
; dispatch_armed_choice.asm. $CCFB, $CCCB, and $CCC8 are named in
; setup_prefixed_block_choice.asm, which is included later, so this file
; uses those addresses. DispatchPrefixedBlockChoice is already source.

StepPrefixedBlockChoice0B::
    xor a
    ld [$CCFB], a
    call RefreshRecordLenFromMode
    ld a, [$CCCB]
    cp CHOICE_00
    jr nz, .nonzeroMode

    ld a, [RECORD_INDEX]
    dec a
    ld [RECORD_INDEX], a
    call RefillChoiceBytesBackward
    jr .shrinkRow

.nonzeroMode:
    call Bank3_7512

.shrinkRow:
    ld a, [$CCC8]
    sub LIMIT_08
    ld [$CCC8], a
    call RepaintPrefixedBlockWindow
    jp DispatchPrefixedBlockChoice
