; Script opcode $1C. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The operand is stored in wSoundSlotB ($C922). SelectSoundCommand treats a
; value other than $FF there as a request for the sound command at $071D,
; after it has already skipped wSoundSlotA. BC is left on the following
; opcode. Control returns through jp DispatchScriptOpcode.
;
; wSoundSlotB is the name from select_sound_command.asm.

Opcode1C::
    ld a, [bc]
    inc bc
    ld [wSoundSlotB], a
    jp DispatchScriptOpcode
