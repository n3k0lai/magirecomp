; Script entry at $1A88. Calls StageScriptByteWordAndSavePtr, which
; copies the next script byte into wUnknownC9D8, copies the next script
; word (or the word at $C9E5 when bit 7 of the high byte is set) onto
; wUnknownC9DA, and saves BC as hScriptPtr.
;
; A is then $07 and control falls into MapAThenCall4837. That entry
; stores A in wCurrentROMBank and rROMB0, then calls $4837. From this
; entry the bank is 7, so the call is file address $01C837. $4837 is
; still INCBIN. A caller of $1A8D may arrive with a different bank in A.
;
; wCallback becomes $4575 and wCallbackBank becomes 7. hScriptHandler
; becomes INITIAL_SCRIPT_HANDLER ($0A66). The handler stores are the
; 3-byte form. $1AAF is that ret, and it is also a call target.
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. wCallback and wCallbackBank
; are the names from default_state.asm. wUnknownC9D8 and wUnknownC9DA
; are the names from the helper this calls. Bank7Callback4575 is the
; name from step_bank7_callback_countdown.asm.

; CPU address of the call. Bank 7 when entered at $1A88.
DEF Routine4837 EQU $4837

StageScriptByteWordThenCall4837::
    call StageScriptByteWordAndSavePtr
    ld a, BANK_CALLBACK_4575

MapAThenCall4837::
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call Routine4837
    ld a, BANK_CALLBACK_4575
    ld [wCallbackBank], a
    ld a, LOW(Bank7Callback4575)
    ld [wCallback], a
    ld a, HIGH(Bank7Callback4575)
    ld [wCallback + 1], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a

ReturnAt1AAF::
    ret
