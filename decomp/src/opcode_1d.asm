; Script opcode $1D. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes no operand, so BC is left
; where it was.
;
; wSoundRequest ($C91F) is set to $02. SelectSoundCommand treats bit 1 of
; that byte as a request for the sound command at $06FC (SoundRequestBit1),
; which also writes $FF to wSoundIndex. Control returns through
; jp DispatchScriptOpcode.
;
; wSoundRequest is the name from select_sound_command.asm.

Opcode1D::
    ld a, $02
    ld [wSoundRequest], a
    jp DispatchScriptOpcode
