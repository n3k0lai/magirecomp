; Sets hScriptHandler to Opcode11 and returns.
;
; MatchWRAM5ScriptByte jumps here when the word at $C190 equals the word at
; $FF93, and when the WRAM bank 5 byte at that pointer does not match the
; next script byte. Opcode11 is $0C7E. hScriptHandler is written with the
; 3-byte form.
;
; hScriptHandler is the name from reset.asm.

InstallOpcode11Handler::
    ld a, LOW(Opcode11)
    ldh [hScriptHandler], a
    ld a, HIGH(Opcode11)
    ldh [hScriptHandler + 1], a
    ret
