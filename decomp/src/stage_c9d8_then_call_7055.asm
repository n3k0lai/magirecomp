; Copies one script byte at [BC] into $C9D8, then clears $C9D9.
; BC advances into hScriptPtr. hScriptHandler becomes
; INITIAL_SCRIPT_HANDLER ($0A66). ROM bank 4 is stored to
; wCurrentROMBank and rROMB0, then $7055 in that bank is called.
; The pointer and handler stores are the 3-byte form.
;
; $C9D8 is wUnknownC9D8 from indexed_tail_07.asm. $C9D9 is wPanelSlot
; from stage_panel_glyph_dest.asm. What this bank 4 call does with
; those two bytes is still unknown. hScriptPtr, hScriptHandler,
; INITIAL_SCRIPT_HANDLER, wCurrentROMBank, and rROMB0 are the names
; from reset.asm.

; ROM bank mapped for the call at $7055.
DEF C9D8_CALL_BANK EQU $04

StageC9D8ThenCall7055::
    ld a, [bc]
    ld [$C9D8], a
    inc bc
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    xor a
    ld [$C9D9], a
    ld a, C9D8_CALL_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $7055
    ret
