; Script entry at $1CCA. StoreScriptByteAtC9D8 copies the next script
; byte to wUnknownC9D8 and advances BC. $1CCD is an entry that loads
; B first. $1CCE is an entry with A already the high byte of the
; script pointer. BC is saved as hScriptPtr (high byte first, 3-byte
; form).
;
; $1CD5 is an entry once that pointer is stored. Bank 7 is written to
; wCurrentROMBank and rROMB0, then $481E in that bank is called. What
; $481E does is still unknown. Its file address is $01C81E.
;
; $1CE2 is an entry with A already the callback bank. wCallbackBank
; takes that A, and wCallback is planted as $4575. hScriptHandler
; becomes INITIAL_SCRIPT_HANDLER ($0A66). The handler stores are the
; 3-byte form.
;
; StoreScriptByteAtC9D8 is the name from store_script_byte_at_c9d8.asm.
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm. wCallback and wCallbackBank
; are the names from default_state.asm. BANK_CALLBACK_4575 and
; Bank7Callback4575 are the names from step_bank7_callback_countdown.asm.

StoreScriptByteCall481E::
    call StoreScriptByteAtC9D8

SaveBCThenCall481E::
    ld a, b

SaveScriptHighThenCall481E::
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a

MapBank7Call481E::
    ld a, BANK_CALLBACK_4575
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call RunPanelIndexThrough2EB6
    ld a, BANK_CALLBACK_4575

PlantCallbackBankInA::
    ld [wCallbackBank], a
    ld a, LOW(Bank7Callback4575)
    ld [wCallback], a
    ld a, HIGH(Bank7Callback4575)
    ld [wCallback + 1], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
