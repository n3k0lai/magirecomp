; Script opcode $00. DispatchScriptOpcode jumps here after storing the
; advanced script pointer and restoring the script bank.
;
; This handler writes bank 1 to wCurrentROMBank and rROMB0, then leaves
; through jp $4423. That address is in the bank just mapped. What it does
; is still unknown. wCurrentROMBank and rROMB0 are the names from reset.asm.

DEF OPCODE00_BANK EQU $01

Opcode00::
    ld a, OPCODE00_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp Opcode00InBank1
