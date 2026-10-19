; Script entry at $1A6F. Calls StageScriptByteWordAndSavePtr, which
; copies the next script byte into wUnknownC9D8, copies the next script
; word (or the word at $C9E5 when bit 7 of the high byte is set) onto
; wUnknownC9DA, and saves BC as hScriptPtr.
;
; Bank 7 is then mapped and $4850 is called. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). The handler stores are the 3-byte form.
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. wUnknownC9D8 and wUnknownC9DA
; are the names from the helpers this calls. $4850 is still unnamed.
; Its file address is $01C850.

; Bank 7, still INCBIN. CPU address while bank 7 is mapped.
DEF BANK7_CALL_4850 EQU $07

StageScriptByteWordThenCall4850::
    call StageScriptByteWordAndSavePtr
    ld a, BANK7_CALL_4850
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call FillPanelWordsFromC9DA
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
