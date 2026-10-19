; Map the script bank and call the handler in hScriptHandler.
;
; RunScriptRecord calls this after loading the seven-byte record into HRAM.
; The bank byte is hScriptBank. Bit 7 forces bank 1; otherwise that byte is
; the bank. Both paths meet at `ld a, a`, which keeps A. The bank is stored
; in wCurrentROMBank and written to rROMB0.
;
; BC is the little-endian pointer at hScriptPtr. HL is the handler at
; hScriptHandler, read with the 3-byte form, and the call goes through
; JumpHL. The saved ROM bank is written back before returning.
;
; hScriptBank, hScriptPtr, hScriptHandler, wCurrentROMBank, and rROMB0 are
; the names from reset.asm. JumpHL is the trampoline at $0789. RunScriptHandler
; in run_script_record.asm is the numeric address of this routine.

MapScriptBankAndCall::
    ld a, [wCurrentROMBank]
    push af
    ldh a, [hScriptBank]
    bit 7, a
    jr z, .use_bank
    ld a, $01
.use_bank:
    ld a, a
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ld hl, hScriptPtr
    ld a, [hl+]
    ld b, [hl]
    ld c, a
    ld a, [hScriptHandler + 1]
    ld h, a
    ld a, [hScriptHandler]
    ld l, a
    call JumpHL
    pop af
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    ret
