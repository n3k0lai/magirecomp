; Temporary hScriptHandler planted by opcode $2B. While $D3C2 is zero
; this returns, so the script stays parked. A nonzero flag jumps to
; DispatchScriptOpcode. hScriptPtr is left alone.
;
; hScriptHandler is the name from reset.asm. $D3C2 is the flag from
; wait_d3c2_clear.asm. DispatchScriptOpcode is the name from
; dispatch_script_opcode.asm.

ScriptHandlerUntilD3C2::
    ld a, [$D3C2]
    and a
    ret z
    jp DispatchScriptOpcode
