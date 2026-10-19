; Copy three script bytes from BC into the record at HL, plant
; DispatchScriptOpcode as the next word, and jump there.
;
; Each script byte is stored with the auto-increment form, so HL then points
; at the handler word. That word is written little-endian as the address of
; DispatchScriptOpcode ($0A66). BC ends three bytes past the first read.
; Control leaves through jp DispatchScriptOpcode, which reads the opcode at
; the new BC. Callers point HL at a script record ($C706, $C70D, or $C71B)
; before the jump. What the three copied fields mean is still unknown.
;
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

CopyThreeScriptBytesThenDispatch::
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, [bc]
    ld [hl+], a
    inc bc
    ld a, LOW(DispatchScriptOpcode)
    ld [hl+], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hl+], a
    jp DispatchScriptOpcode
