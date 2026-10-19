; Save BC, map bank 3, call $50D0, then restore the script bank and dispatch.
;
; BC is the script pointer the dispatcher may keep. Bank 3 is stored to
; wCurrentROMBank and rROMB0 before the call, so $50D0 runs from that
; bank. BC is restored afterward. hScriptBank is written back to both
; bank registers, and control leaves through DispatchScriptOpcode.
;
; $204B is the store to rROMB0. A caller that already wrote wCurrentROMBank
; can enter there. $2055 restores both bank registers from hScriptBank
; and jumps to the dispatcher. $50D0 is still INCBIN. Its file address
; is $00D0D0. wCurrentROMBank, rROMB0, and hScriptBank are the names
; from reset.asm.

; Bank 3, still INCBIN. CPU address while that bank is mapped.
DEF Bank3_50D0 EQU $50D0

CallBank3ThenDispatchScript::
    push bc
    ld a, $03
    ld [wCurrentROMBank], a
MapROMB0Call50D0::
    ld [rROMB0], a
    call Bank3_50D0
    pop bc
    ld a, [hScriptBank]
RestoreScriptBankAndDispatch::
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp DispatchScriptOpcode
