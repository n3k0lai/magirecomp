; Script opcode $10. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The operand is a little-endian word. The first byte is stored at $C186
; and the second at $C187. What that word is used for is still unknown.
; BC is left on the following opcode. Control returns through
; jp DispatchScriptOpcode.

Opcode10::
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld a, d
    ld [$c187], a
    ld a, e
    ld [$c186], a
    jp DispatchScriptOpcode
