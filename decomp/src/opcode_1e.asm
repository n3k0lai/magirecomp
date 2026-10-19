; Script opcode $1E. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes no operand, so BC is left
; where it was.
;
; wSoundRequest ($C91F) is set to $04. SelectSoundCommand treats bit 2 of
; that byte as a request for the sound command at $0709 (SoundRequestBit2).
; Control returns through jp DispatchScriptOpcode.
;
; wSoundRequest is the name from select_sound_command.asm.

Opcode1E::
    ld a, $04
    ld [wSoundRequest], a
    jp DispatchScriptOpcode
