; Script entry at $16DE. If [$C6FA] is already nonzero, return and
; leave BC where it is. Otherwise store $FF there and jump to
; DispatchScriptOpcode.
;
; $C6FA is wUnknownC6F5 + 5. AddAndShift, already source, shifts
; $C6F8, $C6FA, and $C6FC one byte forward. What $FF means in that
; byte is still unknown. wUnknownC6F5 is the name from
; write_quad_records.asm. DispatchScriptOpcode is the name from
; dispatch_script_opcode.asm.

ArmC6FAUnlessSet::
    ld a, [wUnknownC6F5 + 5]
    and a
    ret nz
    ld a, $FF
    ld [wUnknownC6F5 + 5], a
    jp DispatchScriptOpcode
