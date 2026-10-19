; Bank 3 at $6A4D. DispatchPrefixedBlockChoice jumps here when $CCCB
; is zero and the choice at $CCA7 is not $FF, $FE, $0B, $0C, $00, $01,
; or $02. This routine writes the SRAM bank register, not rROMB0.
;
; The record index is ($CCA7 - 3) + ($CCC8 - 8). $CCC8 is $08 on the
; first page and steps by $08, so choice $03 is record 0. MultiplyCByB
; with B = 3 turns that index into a byte offset. WRAM bank 6 is stored
; at wCurrentWRAMBank and selected. The three-byte record at $D001 plus
; that offset is read: the first byte is stored at $C9FD, and the next
; two are a little-endian cost (C low, B high).
;
; SRAM bank wSRAMBank is selected with `add a, $00`, which keeps that
; bank byte and sets flags nobody reads. SRAM is enabled, the word at
; $A3A5 is loaded into HL, and SRAM is disabled. The cost is compared
; with that word. A smaller high byte, or equal highs whose low byte is
; not greater, means the word covers the cost.
;
; The covered path stores 0 at $C9FC and 1 at $C9FE, then CallBankedHL
; runs bank 7 at $7350. If $C9FD is zero afterwards, control jumps to
; $6B03 with the cost still pushed. Otherwise the cost is subtracted
; from $A3A5, borrowing from the high byte when the low byte wraps.
; SRAM is disabled. PlantOneMapListEntry rebuilds the digit list, $6AE6
; runs, $CCC9 becomes $FF, and control returns to the choice loop.
;
; $6B03, still INCBIN, pops the cost, stores 2 at $C921, and jumps to
; the same loop. $6AE6 is still INCBIN. MultiplyCByB is the name from
; draw_cgb_notice.asm. CHOICE_INDEX_BASE is the name from
; commit_copied_block_choice.asm. CHOICE_ROW is the name from
; setup_prefixed_block_choice.asm. LIMIT_08, COPIED_BLOCK_BANK, and
; COPIED_BLOCK_DATA are the names from stage_copied_block_arm_slot.asm.
; wCurrentWRAMBank and rSVBK are the names from timer_overflow.asm.
; wBank7ArgC9FC and CopyThreeBank7 are the names from
; copy_three_c9fc_bank7.asm. sDigitWordA3A5 is the name from
; plant_one_map_list_entry.asm. wSRAMBank, rRAMB, and SRAM_ENABLE are
; the names from handle_start_press.asm. rRAMG is the name from
; reset.asm. Bank3_6AE6 is the name from plant_latched_slot_digits.asm.
; wLatchedSlot is the name from dispatch_prefixed_block_choice.asm.
; CallBankedHL, PlantOneMapListEntry, and DispatchPrefixedBlockChoice
; are already source.

; Three bytes per record at $D001: a flag byte, then the cost word.
DEF PREFIXED_RECORD_STRIDE EQU $03

; Bank 7, passed to CallBankedHL with HL = CopyThreeBank7.
DEF PREFIXED_RECORD_BANK EQU $07

; No slot latched, so the next choice pass treats the index as new.
DEF LATCH_NONE EQU $FF

SpendPrefixedBlockRecord::
    ld a, [$CCA7]
    sub CHOICE_INDEX_BASE
    ld c, a
    ld a, [CHOICE_ROW]
    ld b, LIMIT_08
    sub b
    add c
    ld c, a
    ld b, PREFIXED_RECORD_STRIDE
    call MultiplyCByB
    ld b, h
    ld c, l
    ld a, COPIED_BLOCK_BANK
    ld [wCurrentWRAMBank], a
    ldh [rSVBK], a
    ld hl, COPIED_BLOCK_DATA
    add hl, bc
    ld a, [hl+]
    ld [wBank7ArgC9FC + 1], a
    ld a, [hl+]
    ld c, a
    ld b, [hl]
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sDigitWordA3A5
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    xor a
    ld [rRAMG], a
    push bc
    ld a, b
    cp h
    jr c, .costFits

    jr nz, RejectPrefixedRecordCost

    ld a, l
    cp c
    jp c, RejectPrefixedRecordCost

.costFits:
    ld a, $00
    ld [wBank7ArgC9FC], a
    ld a, $01
    ld [wBank7ArgC9FC + 2], a
    ld hl, CopyThreeBank7
    ld e, PREFIXED_RECORD_BANK
    call CallBankedHL
    ld a, [wBank7ArgC9FC + 1]
    cp $00
    jp z, RejectPrefixedRecordCost

    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, sDigitWordA3A5
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    ld a, e
    pop bc
    sub c
    ld e, a
    jr nc, .noBorrow

    dec d

.noBorrow:
    ld a, d
    sub b
    ld d, a
    ld hl, sDigitWordA3A5
    ld a, e
    ld [hl+], a
    ld [hl], d
    xor a
    ld [rRAMG], a
    call PlantOneMapListEntry
    call Bank3_6AE6
    ld a, LATCH_NONE
    ld [wLatchedSlot], a
    jp DispatchPrefixedBlockChoice
