; Script opcode $2E. The bank 1 pointer table at $4303 maps opcode $2E
; (table index $0E, opcodes counted from $20) here. Dispatch leaves BC at
; the operands.
;
; CopyScriptToD392 copies the five operand bytes from BC to $D392 in WRAM
; bank 7, plants the initial script handler, and maps ROM bank 2. Control
; jumps to $752D in bank 2 (file address $B52D), the same entry opcode $2D
; uses after it clears $D396.
;
; CopyScriptToD392 is already source. $752D is still INCBIN.

Opcode2E::
    ld a, $05
    call CopyScriptToD392
    jp $752D
