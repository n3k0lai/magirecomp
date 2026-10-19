; Script opcode $13. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The operand is a little-endian word. Its low byte is stored at $FF8D and
; its high byte at $FF8E, both with the 3-byte form. Opcode $11 and
; MatchWRAM5ScriptByte also write that word. What it is used for is still
; unknown.
;
; BC, now past the operand, is stored at hScriptPtr with the 3-byte form,
; high byte first. hScriptHandler is set to DispatchScriptOpcode ($0A66),
; also with the 3-byte form. This returns to the caller of the handler
; instead of jumping back into the dispatcher. The next pass through that
; handler starts at the opcode after this one.
;
; hScriptPtr and hScriptHandler are the names from reset.asm.

Opcode13::
    ld a, [bc]
    inc bc
    ld [$ff8d], a
    ld a, [bc]
    inc bc
    ld [$ff8e], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(DispatchScriptOpcode)
    ld [hScriptHandler], a
    ld a, HIGH(DispatchScriptOpcode)
    ld [hScriptHandler + 1], a
    ret
