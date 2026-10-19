; Bank 3 at $74EF. PrepareChoice012 calls this with C = $F0 and HL
; still holding the SRAM pointer just stored at $CCE4.
;
; wSRAMBank is selected (`add a, $00` leaves the bank byte unchanged)
; and SRAM is enabled. B starts at zero. Each pass decrements C and
; stops when C reaches zero, so the loop reads the C-1 bytes at HL.
; A zero byte is skipped. A nonzero byte increments B. SRAM is then
; disabled and that count is stored at $CCCC.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
; RECORD_LEN is the name from stage_copied_block_arm_slot.asm.

CountNonzeroChoiceBytes::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld b, $00

.scan:
    dec c
    jr z, .store

    ld a, [hl+]
    cp $00
    jr z, .scan

    inc b
    jr .scan

.store:
    xor a
    ld [rRAMG], a
    ld a, b
    ld [RECORD_LEN], a
    ret
