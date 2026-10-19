; Script opcode $2A. The bank 1 pointer table at $4303 maps opcode $2A
; (table index $0A, opcodes counted from $20) here. Dispatch leaves BC at
; the operand.
;
; CopyScriptToD392 copies A bytes from BC to $D392. It selects WRAM bank 7
; first, so that one store lands in that bank. It then writes the advanced
; pointer to hScriptPtr, sets hScriptHandler to INITIAL_SCRIPT_HANDLER
; ($0A66), and maps ROM bank 2 through wCurrentROMBank and rROMB0. Control
; jumps to $744A in that bank (file address $B44A).
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. CopyScriptToD392 is already
; source.

Opcode2A::
    ld a, $01
    call CopyScriptToD392
    jp $744A
