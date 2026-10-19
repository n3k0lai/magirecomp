; Script opcode $02. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; Four script bytes rewrite the pair at wScriptPairLo and wScriptPairHi.
; The low byte is ($C18E - byte 0) + byte 1. The high byte is
; ($C18F - byte 2) + byte 3. What those two bases hold is still unknown.
; BC is left on the following opcode. wScriptPairLo and wScriptPairHi are
; the names from opcode_01.asm.

DEF wScriptBaseLo EQU $C18E
DEF wScriptBaseHi EQU $C18F

Opcode02::
    ld a, [bc]
    inc bc
    ld l, a
    ld a, [wScriptBaseLo]
    sub l
    ld l, a
    ld a, [bc]
    inc bc
    add l
    ld [wScriptPairLo], a
    ld a, [bc]
    inc bc
    ld l, a
    ld a, [wScriptBaseHi]
    sub l
    ld l, a
    ld a, [bc]
    inc bc
    add l
    ld [wScriptPairHi], a
    jp DispatchScriptOpcode
