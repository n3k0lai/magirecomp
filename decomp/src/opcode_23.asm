; Script opcode $23. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. The pointer table in bank 1 at $42C3 maps
; opcode $23 to this address. This opcode takes one operand: the byte is
; read and BC advances past it.
;
; The high nibble of that byte, plus one, is stored at $C929. $C928 and
; $C92C are cleared. wSoundSelect ($C92A) is set to $02, which is bit 1.
; SelectSoundCommand treats that bit as a request for SoundSelectBit1, and
; that command counts $C928 until it matches $C929, then steps $C92C up
; from zero. Control returns through jp DispatchScriptOpcode.
;
; wSoundSelect is the name from select_sound_command.asm. $C928 and $C929
; are the counter and its match value named in sound_select_bit1.asm.
; $C92C is the byte handle_start_press.asm calls wUnknownC92C.

Opcode23::
    ld a, [bc]
    inc bc
    swap a
    and $0f
    inc a
    ld [wUnknownC929], a
    xor a
    ld [wUnknownC928], a
    ld [wUnknownC92C], a
    ld a, $02
    ld [wSoundSelect], a
    jp DispatchScriptOpcode
