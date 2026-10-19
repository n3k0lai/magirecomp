; Script entry at $1BA0. The previous routine jumps away at $1B9D, so
; this is the next uncovered byte.
;
; The next script byte is stored at wPanelSlot and BC advances. BC is
; then saved as hScriptPtr (high byte first, 3-byte form). Bank 7 is
; written to wCurrentROMBank and rROMB0, and $4333 in that bank is
; called. What $4333 does is still unknown. Its file address is $01C333.
;
; wCallback is planted as $4575 in bank 7, the same pair
; StepBank7CallbackCountdown writes. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). $1BCE is the store of that handler's
; high byte, then this returns.
;
; wPanelSlot is the name from stage_panel_glyph_dest.asm. hScriptPtr,
; hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0
; are the names from reset.asm. wCallback and wCallbackBank are the
; names from default_state.asm. BANK_CALLBACK_4575 and Bank7Callback4575
; are the names from step_bank7_callback_countdown.asm.

StorePanelSlotCall4333::
    ld a, [bc]
    ld [wPanelSlot], a
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, BANK_CALLBACK_4575
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ComplementPanelSlotPalettes
    ld a, BANK_CALLBACK_4575
    ld [wCallbackBank], a
    ld a, LOW(Bank7Callback4575)
    ld [wCallback], a
    ld a, HIGH(Bank7Callback4575)
    ld [wCallback + 1], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)

StoreHandlerHighAndReturn::
    ld [hScriptHandler + 1], a
    ret
