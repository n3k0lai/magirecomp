; Script opcode $22. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. The pointer table in bank 1 at $42C3 maps
; opcode $22 to this address. This opcode takes one operand: the byte is
; read and BC advances past it.
;
; The low nibble of that byte is stored at $C92C. $C928 and $C929 are
; cleared. wSoundSelect ($C92A) is set to $04, which is bit 2. Bits 0 and 1
; of wSoundSelect are clear, so SelectSoundCommand takes SoundSelectOther.
; That command passes $C92C to ApplyC92C and then clears wSoundSelect.
; Control returns through jp DispatchScriptOpcode.
;
; wSoundSelect is the name from select_sound_command.asm. $C928 and $C929
; are the counter and its match value named in sound_select_bit1.asm.
; $C92C is the byte handle_start_press.asm calls wUnknownC92C.

Opcode22::
    ld a, [bc]
    inc bc
    and $0f
    ld [wUnknownC92C], a
    xor a
    ld [wUnknownC928], a
    ld [wUnknownC929], a
    ld a, $04
    ld [wSoundSelect], a
    jp DispatchScriptOpcode
