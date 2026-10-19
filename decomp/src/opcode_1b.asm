; Script opcode $1B. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode.
;
; The operand is stored in wSoundSlotA ($C921). SelectSoundCommand treats a
; value other than $FF there as a request for the sound command at $070D.
; BC is left on the following opcode. Control returns through
; jp DispatchScriptOpcode.
;
; wSoundSlotA is the name from select_sound_command.asm.

Opcode1B::
    ld a, [bc]
    inc bc
    ld [wSoundSlotA], a
    jp DispatchScriptOpcode
