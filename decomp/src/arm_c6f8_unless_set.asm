; Script entry at $16D1. If [$C6F8] is already nonzero, return and
; leave BC where it is. Otherwise store $FF there and jump to
; DispatchScriptOpcode.
;
; $C6F8 is wUnknownC6F5 + 3. AddAndShift, already source, shifts
; $C6F8, $C6FA, and $C6FC one byte forward. What $FF means in that
; byte is still unknown. wUnknownC6F5 is the name from
; write_quad_records.asm. DispatchScriptOpcode is the name from
; dispatch_script_opcode.asm.

ArmC6F8UnlessSet::
    ld a, [wUnknownC6F5 + 3]
    and a
    ret nz
    ld a, $FF
    ld [wUnknownC6F5 + 3], a
    jp DispatchScriptOpcode
