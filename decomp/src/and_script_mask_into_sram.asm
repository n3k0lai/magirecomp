; Script tail at $2869. BC is the script pointer.
;
; The first word is an SRAM address in HL. The next script byte is a
; mask in E. SRAM bank wSRAMBank is selected with `add a, $00` (the
; flags are unused) and enabled. The SRAM byte at HL is ANDed with E.
; SRAM is then disabled, and control jumps to DispatchScriptOpcode
; ($0A66). BC is left one past the mask.
;
; The following tail at $2889 ORs a mask the same way and is still
; INCBIN. rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and
; SRAM_ENABLE are the names from handle_start_press.asm.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

AndScriptMaskIntoSram::
    ld a, [bc]
    ld l, a
    inc bc
    ld a, [bc]
    ld h, a
    inc bc
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE
    ld [rRAMG], a
    ld a, [hl]
    and e
    ld [hl], a
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode

AndScriptMaskIntoSramEnd:
