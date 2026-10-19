; Script opcode $2F. The bank 1 pointer table at $4303 maps opcode $2F
; (table index $0F, opcodes counted from $20) here. Dispatch leaves BC at
; the operands.
;
; CopyScriptToD392 copies the four operand bytes from BC to $D392 in WRAM
; bank 7, plants the initial script handler, and maps ROM bank 2. Control
; jumps to $7595 in bank 2 (file address $B595).
;
; CopyScriptToD392 is already source. $7595 is still INCBIN.

Opcode2F::
    ld a, $04
    call CopyScriptToD392
    jp $7595
