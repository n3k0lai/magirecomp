; Script tail at $27C6. BC is the script pointer.
;
; SRAM bank wSRAMBank is selected with `add a, $00` (the flags are unused)
; and enabled. The next script word is stored at SRAM $A123, low byte
; first. SRAM is then disabled.
;
; $27E3 saves BC as hScriptPtr, high byte first, using the 3-byte store.
; hScriptHandler becomes INITIAL_SCRIPT_HANDLER ($0A66), also the 3-byte
; form. Bank 7 is written to wCurrentROMBank and rROMB0, then $40E6 in
; that bank is called. Its file address is $01C0E6. What it does with the
; word at $A123 is still unknown. This tail returns after the call.
;
; $27D0 is the enable store, entered with A already the SRAM enable value.
; rRAMG is the name from reset.asm. rRAMB, wSRAMBank, and SRAM_ENABLE are
; the names from handle_start_press.asm. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names from
; reset.asm. BANK_CALLBACK_4575 is the name from
; step_bank7_callback_countdown.asm.

DEF SRAM_WORD_A123 EQU $A123

StoreScriptWordAtA123::
    ld a, [wSRAMBank]
    add a, $00
    ld [rRAMB], a
    ld a, SRAM_ENABLE

EnableSramStoreScriptWord::
    ld [rRAMG], a
    ld a, [bc]
    ld e, a
    inc bc
    ld a, [bc]
    ld d, a
    inc bc
    ld hl, SRAM_WORD_A123
    ld a, e
    ld [hl+], a
    ld [hl], d
    xor a
    ld [rRAMG], a

SaveScriptPtrCall40E6::
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ld a, BANK_CALLBACK_4575
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call ClearSramAfterScriptWord
    ret

StoreScriptWordAtA123End:
