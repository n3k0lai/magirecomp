; Script tail at $2849. BC is the script pointer.
;
; The first word is an SRAM address in HL. SRAM bank wSRAMBank is
; selected with `add a, $00` (the flags are unused) and enabled. The
; next script word is stored at HL, low byte first. SRAM is then
; disabled. BC is left one past that word, and control jumps to
; DispatchScriptOpcode ($0A66).
;
; $284C still has the high address byte in the script; L is already set.
; $284F enters with HL already the SRAM address and SRAM still disabled.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE
; are the names from handle_start_press.asm. DispatchScriptOpcode is
; the name from dispatch_script_opcode.asm.

StoreScriptWordInSram::
    ld a, [bc]
    ld l, a
    inc bc

LoadSramHighThenStoreWord::
    ld a, [bc]
    ld h, a
    inc bc

EnableSramAndStoreScriptWord::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl], a
    inc bc
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode

StoreScriptWordInSramEnd:
