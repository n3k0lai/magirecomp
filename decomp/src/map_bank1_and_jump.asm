; Script handler installed by opcode $11.
;
; Opcode11 stores this address in hScriptHandler and returns to the caller of
; the previous handler. The next pass through hScriptHandler starts here.
;
; Bank 1 is saved in wCurrentROMBank and mapped through rROMB0. Control then
; leaves this routine with an unconditional jump to CPU $4456. That address is
; file $4456 while bank 1 is mapped, and that body is still INCBIN.
;
; hScriptHandler, wCurrentROMBank, and rROMB0 are the names from reset.asm.

MapBank1AndJump::
    ld a, $01
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp $4456
