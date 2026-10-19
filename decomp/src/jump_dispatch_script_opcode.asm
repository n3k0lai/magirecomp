; Script entry at $16BE. It reads no script bytes and jumps straight
; to DispatchScriptOpcode ($0A66).
;
; DispatchScriptOpcode is the name from dispatch_script_opcode.asm.

JumpDispatchScriptOpcode::
    jp DispatchScriptOpcode
