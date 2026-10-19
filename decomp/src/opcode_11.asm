; Script opcode $11. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes no operand, so BC is left
; where it was.
;
; $FF8D is set to the little-endian word $63CE. What that word is used for
; is still unknown. hScriptHandler is then set to $0C8F, the byte after this
; ret, with the 3-byte form. That address is still INCBIN. This returns to
; the caller of the handler instead of jumping back into the dispatcher. The
; next pass through hScriptHandler starts at $0C8F.
;
; hScriptHandler is the name from reset.asm.

Opcode11::
    ld a, $CE
    ldh [$ff8d], a
    ld a, $63
    ldh [$ff8e], a
    ld a, LOW($0C8F)
    ldh [hScriptHandler], a
    ld a, HIGH($0C8F)
    ldh [hScriptHandler + 1], a
    ret
