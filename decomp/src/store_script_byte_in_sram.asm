; Script tail at $282C. BC is the script pointer.
;
; The first word is an SRAM address in HL. SRAM bank wSRAMBank is
; selected with `add a, $00` (the flags are unused) and enabled. The
; next script byte is stored at HL. SRAM is then disabled. BC is left
; one past that byte, and control jumps to DispatchScriptOpcode ($0A66).
;
; $283F is the store, entered with HL already the SRAM address and SRAM
; already enabled. rRAMG is the name from reset.asm. rRAMB, wSRAMBank,
; and SRAM_ENABLE are the names from handle_start_press.asm.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

StoreScriptByteInSram::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a

StoreEnabledSramByte::
    ld a, [bc]
    ld [hl], a
    inc bc
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode

StoreScriptByteInSramEnd:
