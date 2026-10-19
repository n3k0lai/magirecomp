; Bank 1 at $5D81. WalkTwoCellsDown plants this little-endian word at
; hRecordHead + 1. rROMB0 is left alone.
;
; wSRAMBank ($C727) is selected with `add $00`, which keeps that bank,
; and SRAM is enabled. [$A3A3] is copied to $C9A6. $C9A6 has no name.
; XOR A then the store to rRAMG disables SRAM. Control jumps to $5E10,
; still INCBIN in this bank. That entry reloads the record and script,
; then dispatches on the direction bits of $c9a3.
;
; hRecordHead is the name from write_record_head.asm. wSRAMBank, rRAMB,
; and SRAM_ENABLE are the names from handle_start_press.asm. rRAMG is
; the name from reset.asm.

CopySRAMMarkThenHead5E10::
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [$a3a3]
    ld [$c9a6], a
    xor a
    ld [rRAMG], a
    jp DispatchHeldDirectionFromHead
