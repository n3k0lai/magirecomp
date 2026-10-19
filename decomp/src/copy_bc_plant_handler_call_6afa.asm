; Shared tail after $C9FA and the word at $C9F4 are planted. Copies BC into
; hScriptPtr (C low, B high) and plants INITIAL_SCRIPT_HANDLER ($0A66) as
; hScriptHandler. Both pointer stores and both handler stores are the
; 3-byte form. ROM bank 4 is stored to wCurrentROMBank and rROMB0, then
; $6AFA in that bank is called. What that call does with the planted
; bytes is still unknown.
;
; hScriptPtr, hScriptHandler, INITIAL_SCRIPT_HANDLER, wCurrentROMBank,
; and rROMB0 are the names from reset.asm.

; ROM bank mapped for the call at $6AFA.
DEF CALL_6AFA_BANK EQU $04

CopyBCPlantHandlerCall6AFA::
    ld a, b
    ld [hScriptPtr + 1], a
    ld a, c
    ld [hScriptPtr], a
    ld a, LOW(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler], a
    ld a, HIGH(INITIAL_SCRIPT_HANDLER)
    ld [hScriptHandler + 1], a
    ld a, CALL_6AFA_BANK
    ld [wCurrentROMBank], a
    ld [rROMB0], a
    call $6AFA
    ret
