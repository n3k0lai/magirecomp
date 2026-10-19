; Bank 3 at $7512. StepChoice0BByCcc8 calls this before TurnOffLCD.
;
; DE starts at $CCCD+$07. HL is the word at $CCE4 plus [$CCD5] minus
; one. SRAM bank wSRAMBank is selected (`add a, $00` leaves the bank
; byte unchanged) and then enabled.
;
; The loop reads that SRAM byte and steps backward. A zero is skipped.
; A nonzero byte stores its index at DE, and DE moves down one byte.
; Eight stores leave the loop. $CCD5 becomes that last index, SRAM is
; disabled, and the routine returns.
;
; CHOICE_BYTES and CHOICE_SLOT_COUNT are the names from
; fill_choice_table_from_records.asm. RECORD_INDEX is the name from
; stage_copied_block_arm_slot.asm. rRAMG is the name from reset.asm.
; rRAMB, wSRAMBank, and SRAM_ENABLE are the names from
; handle_start_press.asm.

DEF CHOICE_TAIL_OFFSET EQU $0007
DEF CHOICE_LIST_PTR EQU $CCE4

CollectChoiceIndicesBackward::
    ld hl, CHOICE_BYTES
    ld de, CHOICE_TAIL_OFFSET
    add hl, de
    ld d, h
    ld e, l
    ld hl, CHOICE_LIST_PTR
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [RECORD_INDEX]
    dec a
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a

.scan:
    dec c
    ld a, [hl-]
    cp $00
    jr z, .scan

    ld a, c
    inc a
    ld [de], a
    dec de
    inc b
    ld a, b
    cp CHOICE_SLOT_COUNT
    jr nz, .scan

    ld a, c
    inc a
    ld [RECORD_INDEX], a
    xor a
    ld [rRAMG], a
    ret
