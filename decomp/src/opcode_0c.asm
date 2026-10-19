; Script opcode $0C. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The first operand is a slot index. LookupScriptIndexPointer returns that
; record in HL and leaves BC on the following opcode. Bit 7 of the first
; record byte is set. What that bit means is still unknown.
;
; BC is then stored at hScriptPtr with the 3-byte form, high byte first.
; hScriptHandler is set to DispatchScriptOpcode ($0A66), also with the
; 3-byte form. This returns to the caller of the handler instead of jumping
; back into the dispatcher. The next pass through that handler starts at
; the opcode after this one.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.

Opcode0C::
    call LookupScriptIndexPointer
    set 7, [hl]
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
