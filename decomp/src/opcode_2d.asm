; Script opcode $2D. The bank 1 pointer table at $4303 maps opcode $2D
; (table index $0D, opcodes counted from $20) here. Dispatch leaves BC at
; the operands.
;
; CopyScriptToD392 copies the four operand bytes from BC to $D392 in WRAM
; bank 7, plants the initial script handler, and maps ROM bank 2. This
; then clears $D396, the byte after that four-byte copy. Control jumps to
; $752D in bank 2 (file address $B52D).
;
; CopyScriptToD392 is already source. $752D is still INCBIN.

Opcode2D::
    ld a, $04
    call CopyScriptToD392
    xor a
    ld [$D396], a
    jp $752D
