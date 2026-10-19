; Save BC, map bank 3, call $5AAE, then restore the script bank and dispatch.
;
; BC is the script pointer the dispatcher may keep. Bank 3 is stored to
; wCurrentROMBank and rROMB0 before the call, so $5AAE runs from that
; bank. BC is restored afterward. hScriptBank is written back to both
; bank registers, and control leaves through DispatchScriptOpcode.
;
; $2071 is the bank-3 load after BC is already saved. $2073 is the store
; to wCurrentROMBank. $2076 is the store to rROMB0. A caller that already
; wrote the bank can enter at either store. $5AAE is still INCBIN. Its
; file address is $00DAAE. wCurrentROMBank, rROMB0, hScriptBank, and
; DispatchScriptOpcode are the names from the surrounding ROM0 source.

; Bank 3, still INCBIN. CPU address while that bank is mapped.
DEF Bank3_5AAE EQU $5AAE

CallBank3_5AAEThenDispatch::
    push bc
CallBank3_5AAEWithBCSaved::
    ld a, $03
StoreBankThenCall5AAE::
    ld [wCurrentROMBank], a
MapROMB0Call5AAE::
    ld [rROMB0], a
    call Bank3_5AAE
    pop bc
    ld a, [hScriptBank]
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    jp DispatchScriptOpcode
