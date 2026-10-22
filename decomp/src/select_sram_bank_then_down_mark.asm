; Bank 1 at $5B41. rROMB0 is left alone. CopySRAMMarkThenResumeDown
; begins with two nops. Those nops are also the address operand of
; the store this entry starts and does not finish.
;
; The SRAM bank number at wSRAMBank ($C727) is loaded, then `add a, $00`
; leaves that number in A. It is stored to rRAMB. A becomes
; SRAM_ENABLE ($0A). The last byte is the opcode of `ld [rRAMG], a`.
; Falling through uses the two nops as address $0000, so the store
; enables SRAM and then CopySRAMMarkThenResumeDown copies [$A3A3]
; to $C9A6, disables SRAM, and jumps to ResumeDownClearHead.
;
; wSRAMBank, rRAMB, and SRAM_ENABLE are the names from
; handle_start_press.asm. rRAMG is the name from reset.asm.
; CopySRAMMarkThenResumeDown is the label in
; copy_sram_mark_then_resume_down.asm.

SelectSRAMBankThenDownMark::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    INCBIN "roms/magination.gbc", $5B4B, $1
