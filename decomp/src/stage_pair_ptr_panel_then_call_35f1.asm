; Script entry at $1B3E. Copies the next three script bytes to $C9D5,
; $C9D6, and $C9D7 (little-endian pointer, then its bank). The fourth
; byte goes to $C9D9. BC is saved as hScriptPtr. ROM bank 0 is mapped,
; then $35F1 is called. hScriptHandler becomes INITIAL_SCRIPT_HANDLER
; ($0A66). The pointer and handler stores are the 3-byte form. The
; `ld a, $00` is the byte in the ROM.
;
; $35F1, still INCBIN, maps the bank at $C9D7 when $C9D9 is zero and
; calls $358E with BC loaded from $C9D5. The nonzero path is still
; unknown. $C9D5 is the address load_c9_record_picture.asm calls
; wPairSourcePtr and draw_entry_fields_vram0.asm calls wEntryTailPtr.
; $C9D7 is the bank beside that pointer. $C9D9 is wPanelSlot in
; stage_panel_glyph_dest.asm. Those names are not used here.
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm.

StagePairPtrPanelThenCall35F1::
    ld a, [bc]
    inc bc
    ld [$c9d5], a
    ld a, [bc]
    inc bc
    ld [$c9d6], a
    ld a, [bc]
    inc bc
    ld [$c9d7], a
    ld a, [bc]
    inc bc
    ld [$c9d9], a
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, $00
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call MapPairBankThenCopyTwelveWordPairs
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ret
