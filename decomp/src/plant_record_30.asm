; Stores $30 at $C9EC and $6BDC at $C9F0, then joins the shared tail at $11D9.
;
; What $C9EC and the word at $C9F0 mean is still unknown. The same shape
; appears later in this hole with other constants, and each one jumps to
; $11D9. That tail is still INCBIN. It clears $C9EB, $C9EE, and $C9EF,
; copies BC to hScriptPtr, and plants INITIAL_SCRIPT_HANDLER ($0A66) as
; hScriptHandler. hScriptPtr, hScriptHandler, and INITIAL_SCRIPT_HANDLER
; are the names from reset.asm. This routine does not write rROMB0.

; Address stored little-endian at $C9F0. Still unknown.
DEF RECORD_30_PTR EQU $6BDC

PlantRecord30::
    ld a, $30
    ld [$C9EC], a
    ld a, LOW(RECORD_30_PTR)
    ld [$C9F0], a
    ld a, HIGH(RECORD_30_PTR)
    ld [$C9F1], a
    jp $11D9
