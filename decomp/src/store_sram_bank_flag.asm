; Store wSRAMBank into the save flag, then mirror the save.
;
; Called after the saved script pair is stored and bank 7 is mapped.
; SRAM is enabled and bank 0 is selected. The byte at wSRAMBank is
; written to sSaveBankFlag ($A000). Control then jumps to
; MirrorAcceptedSave, which keeps the save only when that flag is 0 or 2.
;
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE
; are the names from handle_start_press.asm. sSaveBankFlag is the name
; from mirror_accepted_save.asm. MirrorAcceptedSave is local to that file.

StoreSramBankFlagThenMirror::
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    xor a
    ld [rRAMB], a
    ld a, [wSRAMBank]
    ld [sSaveBankFlag], a
    jp MirrorAcceptedSave
