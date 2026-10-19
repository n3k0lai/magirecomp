; Bank 7 at $40B7. CallScriptBank40B7 calls here with the script bank
; still mapped, and this routine does not write rROMB0.
;
; SRAM bank wSRAMBank is selected with `add a, $00` (the flags are unused)
; and enabled. The little-endian word at SRAM $A123 is read into DE,
; incremented, and written back. Control then jumps to
; ClearSramAfterScriptWord, which zeroes the two $7F-byte runs that start
; two bytes after that word. The incremented word itself is left in place.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
; SRAM_WORD_A123 is the name from store_script_word_at_a123.asm.
; ClearSramAfterScriptWord is local to clear_sram_after_script_word.asm.

IncrementSramScriptWord::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld hl, SRAM_WORD_A123
    ld a, [hl+]
    ld d, [hl]
    ld e, a
    inc de
    ld hl, SRAM_WORD_A123
    ld a, e
    ld [hl+], a
    ld [hl], d
    jp ClearSramAfterScriptWord
