; Script opcode $01. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; Copies the next two script bytes to $C9A1 and $C9A2, then jumps back to
; the dispatcher. BC is left on the following opcode. What reads the two
; stored bytes is still unknown.

DEF wScriptPairLo EQU $C9A1
DEF wScriptPairHi EQU $C9A2

Opcode01::
    ld a, [bc]
    inc bc
    ld [wScriptPairLo], a
    ld a, [bc]
    inc bc
    ld [wScriptPairHi], a
    jp DispatchScriptOpcode
