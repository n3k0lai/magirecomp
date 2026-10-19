; Script opcode $1F. DispatchScriptOpcode jumps here with BC still pointing
; at the bytes after the opcode. This opcode takes one operand: the byte is
; read and BC advances past it.
;
; That byte is compared with wSoundIndex ($C920). DE is preserved around the
; compare. The `ld a, a` leaves the operand in A so it can be copied to E.
; When the index differs, the operand is stored as the new index and
; wSoundActive ($C91E) is set to 1. Either way, wSoundSelect ($C92A) is
; cleared and $C92C is set to $0F. Control returns through
; jp DispatchScriptOpcode.
;
; wSoundIndex, wSoundActive, and wSoundSelect are the names from
; select_sound_command.asm. $C92C is the byte handle_start_press.asm calls
; wUnknownC92C.

Opcode1F::
    ld a, [bc]
    inc bc
    push de
    ld a, a
    ld e, a
    ld a, [wSoundIndex]
    cp e
    jr z, .index_unchanged

    ld a, e
    ld [wSoundIndex], a
    ld a, $01
    ld [wSoundActive], a

.index_unchanged:
    xor a
    ld [wSoundSelect], a
    ld a, $0F
    ld [$C92C], a
    pop de
    jp DispatchScriptOpcode
