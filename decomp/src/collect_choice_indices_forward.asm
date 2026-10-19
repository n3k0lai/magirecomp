; Bank 3 at $7550. PrepareChoice012 and StepChoice0CByCcc8 call this
; before TurnOffLCD.
;
; HL is the word at $CCE4 plus [$CCD5]. DE is $CCCD. SRAM bank
; wSRAMBank is selected (`add a, $00` leaves the bank byte unchanged)
; and then enabled.
;
; The loop steps C forward from that start index and reads the SRAM
; byte at the matching address. A zero is skipped. C becoming $FF ends
; the scan before index $FE is read. A nonzero byte stores its index
; at DE, and DE moves up one byte. Eight stores leave the loop. If the
; scan ends first, the remaining table bytes through that eighth store
; are $FF. SRAM is disabled and the routine returns.
;
; CHOICE_BYTES, CHOICE_SLOT_COUNT, and CHOICE_PAD are the names from
; fill_choice_table_from_records.asm. RECORD_INDEX is the name from
; stage_copied_block_arm_slot.asm. CHOICE_LIST_PTR is the name from
; collect_choice_indices_backward.asm. rRAMG is the name from reset.asm.
; rRAMB, wSRAMBank, and SRAM_ENABLE are the names from
; handle_start_press.asm.

DEF INDEX_STOP EQU $FF

CollectChoiceIndicesForward::
    ld hl, CHOICE_LIST_PTR
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    ld a, [RECORD_INDEX]
    ld c, a
    ld b, $00
    add hl, bc
    ld de, CHOICE_BYTES
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a

.scan:
    inc c
    ld a, c
    cp INDEX_STOP
    jr z, .padRest

    ld a, [hl+]
    cp $00
    jr z, .scan

    ld a, c
    dec a
    ld [de], a
    inc de
    inc b
    ld a, b
    cp CHOICE_SLOT_COUNT
    jr nz, .scan

    xor a
    ld [rRAMG], a
    ret

.padRest:
    ld a, CHOICE_PAD
    ld [de], a
    inc de
    inc b
    ld a, b
    cp CHOICE_SLOT_COUNT
    jr nz, .padRest

    xor a
    ld [rRAMG], a
    ret
