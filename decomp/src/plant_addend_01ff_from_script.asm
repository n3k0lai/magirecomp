; Script entry at $16C1. Store $01 at wUnknownC6F5, $FF at the next
; byte, and one script byte minus one at $C6F7, then jump to
; DispatchScriptOpcode.
;
; $16C6 is a second entry. It keeps the HL and A the caller already
; set, then writes A, $FF, and the decremented script byte the same way.
; $28E5, still INCBIN, adds $C6F5 to $C6F6 and counts a carry in $C6F7.
; What $01 and $FF mean as that addend is still unknown. BC advances
; one byte. wUnknownC6F5 is the name from write_quad_records.asm.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

PlantAddend01FFFromScript::
    ld hl, wUnknownC6F5
    ld a, $01

PlantAddendFromA::
    ld [hl+], a
    ld a, $FF
    ld [hl+], a
    ld a, [bc]
    inc bc
    dec a
    ld [hl+], a
    jp DispatchScriptOpcode
