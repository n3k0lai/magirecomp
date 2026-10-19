; Script entry at $171F. Point HL at wScriptRecord ($C706) and jump to
; $17A0. That routine, still INCBIN, copies the next three script bytes
; through HL, stores DispatchScriptOpcode ($0A66) in the next two bytes,
; and jumps to DispatchScriptOpcode.
;
; wScriptRecord is the name from finish_startup.asm. It is defined later
; in the scaffold, so the load below uses the address. The sibling entries
; just after this one point HL at $C70D and $C71B and jump to $17A0 too.
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

FillWScriptRecordFromScript::
    ld hl, $C706
    jp $17A0
