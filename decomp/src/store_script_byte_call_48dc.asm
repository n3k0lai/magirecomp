; Script entry at $1CFA. StoreScriptByteAtC9D8 copies the next script
; byte to wUnknownC9D8 and advances BC. $1CFE is an entry with A already
; the high byte of the script pointer. BC is saved as hScriptPtr (high
; byte first, 3-byte form).
;
; Bank 7 is written to wCurrentROMBank and rROMB0, then $48DC in that
; bank is called. What $48DC does is still unknown. Its file address is
; $01C8DC.
;
; $1D1C is an entry with A already the high byte of the callback.
; wCallbackBank is $07, and wCallback is planted as $4575. hScriptHandler
; becomes INITIAL_SCRIPT_HANDLER ($0A66). The handler stores are the
; 3-byte form.
;
; StoreScriptByteAtC9D8 is the name from store_script_byte_at_c9d8.asm.
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. wCallback and wCallbackBank
; are the names from default_state.asm. BANK_CALLBACK_4575 and
; Bank7Callback4575 are the names from step_bank7_callback_countdown.asm.

StoreScriptByteCall48DC::
    call StoreScriptByteAtC9D8
    ld a, b

SaveScriptHighThenCall48DC::
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, BANK_CALLBACK_4575
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ComplementColorsEightyPastRow
    ld a, BANK_CALLBACK_4575
    ld [wCallbackBank], a
    ld a, LOW(Bank7Callback4575)
    ld [wCallback], a
    ld a, HIGH(Bank7Callback4575)

PlantCallbackHighInA::
    ld [wCallback + 1], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
