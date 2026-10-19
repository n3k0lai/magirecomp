; Script entry at $1705. If [$C6FA] is already nonzero, return and
; leave BC where it is. Otherwise store the next script byte there
; and jump to DispatchScriptOpcode.
;
; $C6FA is wUnknownC6F5 + 5. AddAndShift, already source, shifts
; $C6F8, $C6FA, and $C6FC one byte forward. What the stored script
; byte means is still unknown. BC advances one byte when the store
; runs. wUnknownC6F5 is the name from write_quad_records.asm.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

StoreScriptByteAtC6FA::
    ld a, [wUnknownC6F5 + 5]
    and a
    ret nz
    ld a, [bc]
    inc bc
    ld [wUnknownC6F5 + 5], a
    jp DispatchScriptOpcode
