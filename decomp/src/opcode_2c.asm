; Script opcode $2C. The bank 1 pointer table at $4303 maps opcode $2C
; (table index $0C, opcodes counted from $20) here. Dispatch leaves BC at
; the operands.
;
; CopyScriptToD392 copies A bytes from BC to $D392. It selects WRAM bank 7
; first, so those two stores land in that bank. It then writes the
; advanced pointer to hScriptPtr, sets hScriptHandler to
; INITIAL_SCRIPT_HANDLER ($0A66), and maps ROM bank 2 through
; wCurrentROMBank and rROMB0. Control jumps to $7477 in that bank (file
; address $B477).
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. CopyScriptToD392 is already
; source.

Opcode2C::
    ld a, $02
    call CopyScriptToD392
    jp $7477
