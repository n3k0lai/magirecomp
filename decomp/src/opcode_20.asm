; Script opcode $20. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes one operand: the byte is
; read and BC advances past it.
;
; The high nibble of that byte, plus one, is stored at $C929. $C928 is
; cleared. wSoundSelect ($C92A) is set to $01, which is bit 0.
; SelectSoundCommand treats that bit as a request for SoundSelectBit0, and
; that command counts $C928 until it matches $C929. Control returns through
; jp DispatchScriptOpcode.
;
; wSoundSelect is the name from select_sound_command.asm. $C928 and $C929
; are the counter and its match value named in sound_select_bit0.asm.

Opcode20::
    ld a, [bc]
    inc bc
    swap a
    and $0f
    inc a
    ld [wUnknownC929], a
    xor a
    ld [wUnknownC928], a
    ld a, $01
    ld [wSoundSelect], a
    jp DispatchScriptOpcode
