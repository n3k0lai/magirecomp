; Script opcode $2B. The bank 1 pointer table at $4303 maps opcode $2B
; (table index $0B, opcodes counted from $20) here. Dispatch leaves BC
; at the operands. Opcode $25 also plants this address as hScriptHandler
; before it jumps to bank 4 at $6416.
;
; There are no operands. $D3C2 is cleared. WaitUntilD3C2Clears spins
; until that byte is zero, so this lets that wait finish. hScriptHandler
; is then set to $0F66, the eight bytes before opcode $2C. That stub,
; still INCBIN, returns while $D3C2 is zero and otherwise jumps to
; DispatchScriptOpcode. hScriptPtr is left alone.
;
; $0F5D is the handler store, and $0F63 stores A as the handler high
; byte. Both fall inside this routine.
;
; hScriptHandler is the name from reset.asm. $D3C2 is the flag from
; wait_d3c2_clear.asm.

Opcode2B::
    xor a
    ld [$D3C2], a
    ld a, LOW($0F66)
    ldh [hScriptHandler], a
    ld a, HIGH($0F66)
    ldh [hScriptHandler + 1], a
    ret
