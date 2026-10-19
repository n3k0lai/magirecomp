; Script opcode $27. The bank 1 pointer table at $4303 maps opcode $27
; here. DispatchScriptOpcode jumps here with the opcode byte already
; consumed.
;
; hScriptHandler is set to this routine, so later passes call back here
; instead of DispatchScriptOpcode. $D3C2 is cleared. WaitUntilD3C2Clears
; spins until that byte is zero. hScriptPtr is left alone.
;
; hScriptHandler is the name from reset.asm. $D3C2 is the flag from
; wait_d3c2_clear.asm.

Opcode27::
    ld a, LOW(Opcode27)
    ldh [hScriptHandler], a
    ld a, HIGH(Opcode27)
    ldh [hScriptHandler + 1], a
    xor a
    ld [$D3C2], a
    ret
