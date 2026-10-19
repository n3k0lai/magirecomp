; Script opcode $9B. DispatchScriptOpcode jumps here from the bank 1 table.
;
; $24EC returns here only when [wUnknownC6EE] is 2. Otherwise it rewinds
; BC, writes that pointer to hScriptPtr, plants opcode $9D ($23D2) as
; hScriptHandler, and returns to this routine's caller.
;
; On the path that continues, wCallbackBank becomes 1 and wCallback becomes
; bank 1's $470F. hScriptHandler becomes $22C4 with the 3-byte form, then
; this returns to MapScriptBankAndCall.
;
; wCallback and wCallbackBank are the names from default_state.asm.
; hScriptHandler and hScriptPtr are the names from reset.asm.
; wUnknownC6EE is the name from setup_window.asm.

; Bank 1 callback. Still INCBIN. Same pointer opcode $9A stores.
DEF Opcode9BCallback EQU $470F

; Next script handler. Still INCBIN.
DEF Opcode9BContinue EQU $22C4

Opcode9B::
    call ReturnUnlessC6EEIsTwo
    ld a, $01
    ld [wCallbackBank], a
    ld a, LOW(Opcode9BCallback)
    ld [wCallback], a
    ld a, HIGH(Opcode9BCallback)
    ld [wCallback + 1], a
    ld a, LOW(Opcode9BContinue)
    ld [hScriptHandler], a
    ld a, HIGH(Opcode9BContinue)
    ld [hScriptHandler + 1], a
    ret
