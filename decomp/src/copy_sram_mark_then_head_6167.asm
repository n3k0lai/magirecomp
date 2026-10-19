; Bank 1 at $613A. rROMB0 is left alone. The previous facing jump
; at $6137 does not fall through.
;
; wSRAMBank ($C727) is selected with `add $00`, which keeps that bank,
; and SRAM is enabled. [$A3A3] is copied to $C9A6. $C9A6 has no name.
; XOR A then the store to rRAMG disables SRAM. Control jumps to
; ResumePlantedHead6167. That entry reloads the record and script, then
; dispatches on the direction bits of $c9a3.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
; ResumePlantedHead6167 is the label in resume_planted_head_6167.asm.
; The same SRAM copy, aimed at $5E10, is CopySRAMMarkThenHead5E10.

CopySRAMMarkThenHead6167::
    ld a, [wSRAMBank]
    add $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [$a3a3]
    ld [$c9a6], a
    xor a
    ld [rRAMG], a
    jp ResumePlantedHead6167
