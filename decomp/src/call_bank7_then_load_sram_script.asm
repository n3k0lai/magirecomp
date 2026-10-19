; Save BC, map bank 7, call $4087, then reload the SRAM script.
;
; BC is the script pointer the following jump may keep. Bank 7 is stored
; to wCurrentROMBank and rROMB0 before the call, so $4087 runs from that
; bank. BC is restored afterward. Control leaves through
; LoadSRAMScriptAndDispatch, which may replace BC from SRAM.
;
; $4087 is still INCBIN. Its file address is $01C087. wCurrentROMBank,
; rROMB0, and BANK_INIT are the names from reset.asm.

CallBank7ThenLoadSRAMScript::
    push bc
    ld a, BANK_INIT
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call CheckSaveSignature
    pop bc
    jp LoadSRAMScriptAndDispatch
