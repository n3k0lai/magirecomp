; Script opcode $26. The bank 1 pointer table at $4303 maps opcode $26
; (table index 6, opcodes counted from $20) here. Dispatch leaves BC at
; the operands.
;
; $1020, still INCBIN, copies A bytes from BC to $D392. It selects WRAM
; bank 7 first, so those four stores land in that bank. It then writes the
; advanced pointer to hScriptPtr, sets hScriptHandler to
; INITIAL_SCRIPT_HANDLER ($0A66), and maps ROM bank 2 through
; wCurrentROMBank and rROMB0. Control jumps to $73AC in that bank (file
; address $B3AC).
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. wCurrentWRAMBank and rSVBK
; are the names from timer_overflow.asm. CopyHLToDE is the copy $1020
; calls.

Opcode26::
    ld a, $04
    call $1020
    jp $73AC
