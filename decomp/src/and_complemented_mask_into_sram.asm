; Zero-word tail of the $2747 lookup. E still holds the mask and HL
; the SRAM address. Complement the mask, AND it into the SRAM byte,
; disable SRAM, and jump to DispatchScriptOpcode ($0A66).
;
; The nonzero path ORs the same mask in OrSramMaskWhenLookup. rRAMG is
; the name from reset.asm. DispatchScriptOpcode is the name from
; dispatch_script_opcode.asm.

AndComplementedMaskIntoSram::
    ld a, e
    cpl
    ld e, [hl]
    and e
    ld [hl], a
    xor a
    ld [rRAMG], a
    jp DispatchScriptOpcode
