; Script opcode $29. The bank 1 pointer table at $4303 maps opcode $29
; (table index 9, opcodes counted from $20) here. DispatchScriptOpcode
; jumps here with BC already past the opcode byte.
;
; There are no operands. Control jumps to $7449. DispatchScriptOpcode
; restored hScriptBank to wCurrentROMBank and rROMB0 before the jump
; here, and this opcode does not store a bank, so $7449 runs in that
; script bank. Its file address is not fixed from this routine.
;
; hScriptBank, wCurrentROMBank, and rROMB0 are the names from reset.asm.

Opcode29::
    jp $7449
